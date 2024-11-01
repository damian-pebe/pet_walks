import 'dart:convert';
import 'package:http/http.dart' as http;

class TwilioService {
  final String accountSid;
  final String authToken;
  final String fromNumber;

  TwilioService({
    required this.accountSid,
    required this.authToken,
    required this.fromNumber,
  });

  Future<void> sendSms(String to, String message) async {
    final String url =
        'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization':
            'Basic ' + base64Encode(utf8.encode('$accountSid:$authToken')),
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'From': fromNumber,
        'To': '+$to',
        'Body': message,
      },
    );

    if (response.statusCode == 201) {
      print('SMS sent successfully!');
    } else {
      print('Failed to send SMS: ${response.body}');
    }
  }
}


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class SendSMSButton extends StatelessWidget {
//   Future<void> sendSMS(String phoneNumber, String message) async {
//     final url = Uri.parse('https://[your-cloud-run-url]/send-sms'); // Replace with your Cloud Run URL
//     final response = await http.post(
//       url,
//       headers: {
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode({
//         'to': phoneNumber,
//         'body': message,
//       }),
//     );

//     if (response.statusCode == 200) {
//       print('SMS sent successfully');
//     } else {
//       print('Failed to send SMS');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: () {
//         sendSMS('+18777804236', 'Hello, this is a test message');
//       },
//       child: Text('Send SMS'),
//     );
//   }
// }
