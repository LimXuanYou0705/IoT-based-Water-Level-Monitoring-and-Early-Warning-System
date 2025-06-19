import 'dart:convert';
import 'package:http/http.dart' as http;

class SmsService {
  static const String _baseUrl = 'https://api.textbee.dev/api/v1';
  static const String _deviceId = '684e80824080863dda265605';
  static const String _apiKey = '7a0fe9d7-8144-4c0f-ae6c-b99883695cdc';

  static Future<bool> sendSMS(String phoneNumber, String message) async {
    final url = Uri.parse('$_baseUrl/gateway/devices/$_deviceId/send-sms');

    final headers = {'x-api-key': _apiKey, 'Content-Type': 'application/json'};

    final body = jsonEncode({
      'recipients': [phoneNumber],
      'message': message,
    });

    try{
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201){
        final responseData = json.decode(response.body);

        final success = responseData['data']['success'];
        final message = responseData['data']['message'];

        print("Response data: $responseData");

        if (success == true) {
          print('SMS sent successfully!');
          return true;
        } else {
          print('SMS delivery failed: $message');
          return false;
        }
      } else {
        print('Failed to send SMS: ${response.statusCode}');
        print('Body: ${response.body}');
        return false;
      }
    } catch(e) {
      print('Error sending SMS: $e');
      return false;
    }
  }
}
