import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/textbee_service/sms_service.dart';

class OtpHelper {
  static String generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  static Future<bool> sendOtp(String phoneNumber) async {
    final otp = generateOtp();
    final expiry = DateTime.now().add(Duration(minutes: 3));

    final message =
        'PoseidonGuard: Your code is $otp. Do not share this with anyone. Code expires in 3 minutes.';

    // send via TextBee
    final result = await SmsService.sendSMS(phoneNumber, message);

    if (result) {
      print('OTP sent to $phoneNumber: $otp');

      // sign in with user credential

      // save expiry for 3 minutes
      // await FirebaseFirestore.instance.collection('otps').doc(phoneNumber).set({
      //   'otp': otp,
      //   'expiresAt': expiry.toIso8601String(),
      // });
      return true;
    } else {
      print('Failed to send OTP to $phoneNumber');
      return false;
    }
  }

  static Future<bool> verifyOtp(String phoneNumber, String enteredOtp) async {
    try{
      final doc = await FirebaseFirestore.instance.collection('otps').doc(phoneNumber).get();

      if (!doc.exists){
        print('No OTP found for $phoneNumber');
        return false;
      }

      final data = doc.data()!;
      final storedOtp = data['otp'];
      final expiresAt = DateTime.parse(data['expiresAt']);

      if (DateTime.now().isAfter(expiresAt)) {
        print('OTP expired for $phoneNumber');
        return false;
      }

      if (enteredOtp == storedOtp){
        print('OTP verified for $phoneNumber');
        // delete otp after success
        await FirebaseFirestore.instance.collection('otps').doc(phoneNumber).delete();

        return true;
      } else {
        print('OTP incorrect for $phoneNumber');
        return false;
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      return false;
    }
  }
}
