import 'dart:math';

import '../services/textbee_service/sms_service.dart';

class OtpHelper {
  static String generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  static Future<bool> sendOtp(String phoneNumber) async {
    final otp = generateOtp();
    final message = 'Otp code is: $otp -> Valid 3 mins';

    // send via TextBee
    final result = await SmsService.sendSMS(phoneNumber, message);

    if (result) {
      print('OTP sent to $phoneNumber: $otp');

      // Optional: store the OTP temporarily (in memory or Firebase)
    } else {
      print('Failed to send OTP to $phoneNumber');
    }

    return result;
  }
}