const firestore = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

exports.onSensorDataAdded = firestore.onDocumentCreated(
    "sensorData/{docId}",
    async (event) => {
      const data = event.data.data();
      const level = data.level;

      if (level !== "ALERT" && level !== "DANGER") {
        console.log("No alert needed.");
        return;
      }

      const usersSnapshot = await db
          .collection("users")
          .where("alertChannels", "!=", [])
          .get();

      const alertMethods = {}; // Will be shared across users for simplicity
      // Prepare FCM notifications if level is DANGER
      const fcmPromises = [];
      const timestamp = admin.firestore.Timestamp.now();

      usersSnapshot.forEach(async (userDoc) => {
        const user = userDoc.data();
        const userId = userDoc.id;
        const fcmToken = user.fcmToken;
        const channels = user.alertChannels || [];

        channels.forEach((channel) => {
          if (!alertMethods[channel]) {
            alertMethods[channel] = {
              sent: false,
              sentAt: null,
              acknowledged: null,
            };
          }
        });

        if (level === "DANGER" && channels.includes("push") && fcmToken) {
          const fcmPayload = {
            token: fcmToken,
            notification: {
              title: "🚨 DANGER ALERT",
              body: "Critical water level detected. Please take action!",
            },
            data: {
              level: "danger",
              location: data.location || "Unknown",
              sensorDataId: event.params.docId,
            },
            android: {
              priority: "high",
            },
          };
          const sendPromise = admin
              .messaging()
              .send(fcmPayload)
              .then(() => {
                alertMethods["push"].sent = true;
                alertMethods["push"].sentAt = timestamp;
                console.log(`FCM sent to user ${userId}`);
              })
              .catch((error) => {
                console.error(`FCM error for user ${userId}:`, error);
              });
          fcmPromises.push(sendPromise);
        }

        await Promise.all(fcmPromises);

        // Create alert document
        const alert = {
          sensorDataId: event.params.docId,
          alertLevel: level,
          timestamp: timestamp,
          acknowledged: false,
          acknowledgedAt: null,
          message: `Water level is ${level}`,
          methods: alertMethods,
        };

        const alertRef = await db.collection("alerts").add(alert);
        console.log(`Alert saved to Firestore with ID: ${alertRef.id}`);
      });
    },
);
