const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

exports.onSensorDataAdded = onDocumentCreated(
    "sensorData/{docId}",
    async (event) => {
      const data = event.data.data();
      const level = data.level;
      const sensorId = data.sensorId;
      const docId = event.params.docId;
      const serverTimestamp = admin.firestore.FieldValue.serverTimestamp();

      if (!sensorId || !level) {
        console.log("Missing sensorId or level, skipping.");
        return;
      }
      console.log(
          `SensorData created with level: ${level}, sensorId: ${sensorId}`,
      );

      if (level === "SAFE") {
        const unresolvedAlertSnap = await db
            .collection("alerts")
            .where("sensorId", "==", sensorId)
            .where("resolvedAt", "==", null)
            .orderBy("timestamp", "desc")
            .limit(1)
            .get();

        if (!unresolvedAlertSnap.empty) {
          const previousAlert = unresolvedAlertSnap.docs[0];
          await previousAlert.ref.update({resolvedAt: serverTimestamp});

          console.log(`Resolved previous alert for sensor ${sensorId}`);

          const usersSnapshot = await db
              .collection("users")
              .where("alertChannels", "array-contains", "push")
              .get();

          for (const userDoc of usersSnapshot.docs) {
            const user = userDoc.data();
            if (!user.fcmToken) continue;

            const payload = {
              token: user.fcmToken,
              notification: {
                title: "Water Level Normalized",
                body: `Sensor ${sensorId} reports SAFE level.`,
              },
              android: {
                priority: "normal",
                notification: {
                  channel_id: "default_channel",
                },
              },
            };

            try {
              await admin.messaging().send(payload);
              console.log(`Sent SAFE notification to ${userDoc.id}`);
            } catch (err) {
              console.error(
                  `Failed to send SAFE notification to ${userDoc.id}:`,
                  err,
              );
            }
          }
        }
        return;
      }

      // ALERT or DANGER

      if (level !== "ALERT" && level !== "DANGER") {
        console.log("No alert needed.");
        return;
      }

      // Check for duplicate unresolved alerts within 10 minutes
      const tenMinutesAgo = admin.firestore.Timestamp.fromDate(
          new Date(Date.now() - 10 * 60 * 1000),
      );

      const existingAlertSnap = await db
          .collection("alerts")
          .where("sensorId", "==", sensorId)
          .where("alertLevel", "==", level)
          .where("resolvedAt", "==", null)
          .where("timestamp", ">", tenMinutesAgo)
          .orderBy("timestamp", "desc")
          .limit(1)
          .get();

      if (!existingAlertSnap.empty) {
        console.log(
            `Recent unresolved ${level} alert exists for ${sensorId}. Skipping.`,
        );
        return;
      }

      const usersSnapshot = await db
          .collection("users")
          .where("alertChannels", "array-contains", "push")
          .get();

      let pushSent = false;
      const fcmPromises = [];

      for (const userDoc of usersSnapshot.docs) {
        const user = userDoc.data();
        const userId = userDoc.id;

        if (user.fcmToken) {
          const payload = {
            token: user.fcmToken,
            notification: {
              title: level === "DANGER" ? "🚨 DANGER ALERT" : "⚠️ ALERT",
              body:
              level === "DANGER" ?
                `Critical water level at sensor ${sensorId}. Take action!` :
                `Elevated water level at sensor ${sensorId}. Stay alert.`,
            },
            data: {
              level,
              sensorId,
              sensorDataId: docId,
            },
            android: {
              priority: level === "DANGER" ? "high" : "normal",
              notification: {
                channel_id:
                level === "DANGER" ? "critical_channel_id" : "default_channel",
                sound: level === "DANGER" ? "alarm" : undefined,
              },
            },
          };

          const sendPromise = admin
              .messaging()
              .send(payload)
              .then(() => {
                pushSent = true;
                console.log(`Sent ${level} FCM to user ${userId}`);
              });

          fcmPromises.push(sendPromise);
        }
      }

      await Promise.all(fcmPromises);

      const alert = {
        sensorId,
        sensorDataId: docId,
        alertLevel: level,
        timestamp: serverTimestamp,
        resolvedAt: null,
        acknowledged: false,
        acknowledgedAt: null,
        message: `Water level is ${level} at sensor ${sensorId}`,
        methods: {
          push: {
            sent: pushSent,
            sentAt: pushSent ? serverTimestamp : null,
            acknowledged: null,
          },
        },
      };

      const alertRef = await db.collection("alerts").add(alert);
      console.log(`${level} alert saved to Firestore: ${alertRef.id}`);
    },
);
