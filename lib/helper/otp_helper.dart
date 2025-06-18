import 'dart:math';

class OtpHelper {
  static String generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }
}