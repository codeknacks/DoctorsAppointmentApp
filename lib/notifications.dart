import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'dart:convert'; // Import the jsonEncode method

class PushNotificationsService {
  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "doctor-appointmentapp-fa256",
      "private_key_id": "YOUR_PRIVATE_KEY_ID",
      "private_key": "YOUR_PRIVATE_KEY",
      "client_email": "YOUR_CLIENT_EMAIL",
      "client_id": "YOUR_CLIENT_ID",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "YOUR_CLIENT_X509_CERT_URL",
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    final auth.ServiceAccountCredentials credentials =
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson);
    final auth.AccessCredentials accessCredentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
      credentials,
      scopes,
      http.Client(),
    );

    return accessCredentials.accessToken.data;
  }

  static Future<void> sendNotificationToDoctor(
      String deviceToken, String title, String body) async {
    final String serverKey = await getAccessToken();
    final String endpointFirebaseCloudMessaging =
        'https://fcm.googleapis.com/v1/projects/doctor-appointmentapp-fa256/messages:send';

    final Map<String, dynamic> message = {
      'message': {
        'token': deviceToken,
        'notification': {
          'title': title,
          'body': body,
        },
      },
    };

    final http.Response response = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers: <String, String>{
        'Authorization': 'Bearer $serverKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(message), // Encode the message to JSON
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send notification: ${response.body}');
    }
  }
}
