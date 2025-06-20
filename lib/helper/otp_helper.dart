import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/textbee_service/sms_service.dart';

class OtpHelper {
  static String generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  static Future<String> sendOtp(String phoneNumber) async {
    final now = DateTime.now();
    final expiry = DateTime.now().add(Duration(minutes: 3));

    final existingDoc = await FirebaseFirestore.instance
        .collection('otps')
        .doc(phoneNumber)
        .get();

    if (existingDoc.exists){
      final data = existingDoc.data()!;
      final lastSentAt = data['lastSentAt'] != null ? DateTime.parse(data['lastSentAt']) : null;

      if (lastSentAt != null &&
          now.difference(lastSentAt).inSeconds < 60) {
        print('Too soon to resend OTP to $phoneNumber');
        return 'cooldown';
      }
    }

    final otp = generateOtp();
    final message =
        'PoseidonGuard: Your code is $otp. Do not share this with anyone. Code expires in 3 minutes.';

    // send via TextBee
    final result = await SmsService.sendSMS(phoneNumber, message);

    if (result) {
      print('OTP sent to $phoneNumber: $otp');

      // save expiry for 3 minutes and lastSentAt
      await FirebaseFirestore.instance.collection('otps').doc(phoneNumber).set({
        'otp': otp,
        'expiresAt': expiry.toIso8601String(),
        'lastSentAt': now.toIso8601String(),
      });
      return 'success';
    } else {
      print('Failed to send OTP to $phoneNumber');
      return 'failed';
    }
  }

  static Future<String> verifyOtp(String phoneNumber, String enteredOtp) async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('otps')
              .doc(phoneNumber)
              .get();

      if (!doc.exists) {
        print('No OTP found for $phoneNumber');
        return 'not_found';
      }

      final data = doc.data()!;
      final storedOtp = data['otp'];
      final expiresAt = DateTime.parse(data['expiresAt']);

      if (DateTime.now().isAfter(expiresAt)) {
        print('OTP expired for $phoneNumber');
        return 'expired';
      }

      if (enteredOtp == storedOtp) {
        print('OTP verified for $phoneNumber');
        // delete otp after success
        await FirebaseFirestore.instance
            .collection('otps')
            .doc(phoneNumber)
            .delete();

        return 'success';
      } else {
        print('OTP incorrect for $phoneNumber');
        return 'invalid';
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      return 'error';
    }
  }
}
