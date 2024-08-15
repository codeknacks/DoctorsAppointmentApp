// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:googleapis_auth/auth_io.dart' as auth;
// import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;

// class NotificationService {
//   static Future<String> getaccessToken() async {
//     try {
//       final serviceAccountJson = {
//         "type": "service_account",
//         "project_id": "doctor-appointmentapp-fa256",
//         "private_key_id": "6a9186094bfba4fa01ac785fd39d4ed38d118264",
//         "private_key":
//             "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCz2I5yfZNUGiYP\nrDW1UQhukmWa7tLvHNc0Gm1FjKqiGdJNvEAa3bHBeCTBB9K6luNzIfUAo73XVZF7\nJwMSQFT4965w+aLb2l89L34SE8mic7aR7UtrLIDbuLukT88Rk8szW28ecfEIhJ4R\nJ2TEW0IFfzxSPgcFd5nMQirM24BTrJKdxybd2oYKv/X7vzCNdkeDWjy0ZBacoZGE\nJcT/lOVKw50wQ9i6wU1apc7MtaVg9X3AhbTmJ/4c6PVHDjy0TY3ndyL/cbE3UJrO\np/mGERho+n7S3u6nhwzrwAfbfmy05q1bYOVIoEUYgCS5ESCYTo6WF0MyQHd2H/ED\nJocWx4A3AgMBAAECggEAC9CERWDj6z0vX8R8zZwQKeI9AacCfTw4yvfiCYKc3d9E\nqs3KrEtuoGhVZTTmgJvBP2La+Q0R0bskB6IWmEcPoECIkGxBRHvUa9q12eng3YtR\nUlfzXR5SCC9tR6wt8XzzCWGp4l372OJnsr9b5gHCcGpK8buYjsWHnfg38QD3m1Ce\nAi9svZ8JMcHXsjenTSKt5DKeOai6+iuTNxn4+8RiAoTsmgTk/n2n7J7ghAKR8WE8\nz2l5wAMkteEn2SpX7uwhk92hmTcVu7IbyEpJHtcnJo1zDefWz9p4GiveAZDhPKoz\ngJ6NF8J/++VuLdv0dS6E+0T6zOniyqbY0imKiWNPUQKBgQDd8EqJsw6rf8qnWIbq\nlqDPmLi6Q4c4PZo7AYJklRk68fpWTUqGmRe8+LAZn9rxFB906npVvrUNW+7RUS13\nWAD4Lztdhhe+eSe6W2Trotzwaf5uAVa1+Vi6jQCx8zbElWijqXGixTJ9/iVe91z0\nGDM0YJP31uEIdhQS2gmQMypSXwKBgQDPcn3tLtpdZYMYukdYgwdn/x+YJ0b2K5qV\nupsmG5+aIvXS1mo6v6OgijF5x5PJQlfUC9/T2TzSO0fuw/po+8weHeAP67txcYXY\nuNQDwSiJRqsaJDC6OTPwdTnMoHTz7g20YMh3IrVtbZFlerLN6gBLyhOCslvKO8sA\nOSEaJ3gRKQKBgDrndcEKRxB5gF3d/yDwDYpLrGuzVIY2w2J5yhPMBsBATQLuzKLg\nqw46qvKCHOfzQU4UlZeAYClFhyMC+qA8OTWlw4nU9yRUn5i0fRqVRTKBz0d/D3aI\n0WXh2pdgR97xEK6vYDulPvt1opGL8Z3PdnemUl9rJprKTBWczQD6s3bdAoGAUjNr\nBL4pFxMvdG/z73XUTHhCm7cMnmU+1w/fhKUzhA9QW2BNLcRcYTQBUOEthXV9ee/O\nnJKbUC7fXRRZOJp2EoUCESz21IgIYo0yrd4vYt4W1L/8cv5Rv3mkEpqOXU46Lfyf\n0t11CMx+7bhF++Q6g82qF4L3blZtJUR+AnAbWqkCgYEAuE59XjlF9nR1mGQUqbMt\nwOLPTyS6RjF2N6aN5l4cv90HzlLxFeSLhhd+5yV5cw/M1Kuf2bU2bfwut6ipjA5K\nPNPFDbMahieC5NkT4Un5YihQA51olDMFXrgmMK7TzASCEtHJt7QJr33TR2O9fB0N\nzAl+rVoEWwCCjd3ngwChKRQ=\n-----END PRIVATE KEY-----\n",
//         "client_email":
//             "raj-323@doctor-appointmentapp-fa256.iam.gserviceaccount.com",
//         "client_id": "105099299328150371166",
//         "auth_uri": "https://accounts.google.com/o/oauth2/auth",
//         "token_uri": "https://oauth2.googleapis.com/token",
//         "auth_provider_x509_cert_url":
//             "https://www.googleapis.com/oauth2/v1/certs",
//         "client_x509_cert_url":
//             "https://www.googleapis.com/robot/v1/metadata/x509/raj-323%40doctor-appointmentapp-fa256.iam.gserviceaccount.com",
//         "universe_domain": "googleapis.com"
//       };

//       List<String> scopes = [
//         "https://www.googleapis.com/auth/firebase.email",
//         "https://www.googleapis.com/auth/firebase.database",
//         "https://www.googleapis.com/auth/firebase.messaging"
//       ];

//       http.Client client = await auth.clientViaServiceAccount(
//           auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes);

//       // Get access token
//       auth.AccessCredentials credentials =
//           await auth.obtainAccessCredentialsViaServiceAccount(
//               auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
//               scopes,
//               client);
//       client.close();

//       return credentials.accessToken.data;
//     } catch (e) {
//       print("Error obtaining access token: $e");
//       return '';
//     }
//   }

//   static Future<void> sendNotificationToDoctor(
//       String deviceToken, BuildContext context, String doctorId) async {
//     try {
//       final String serverkey = await getaccessToken();
//       if (serverkey.isEmpty) {
//         print("Failed to get access token");
//         return;
//       }

//       String endpointFirebaseCloudMessaging =
//           'https://fcm.googleapis.com/v1/projects/doctor-appointmentapp-fa256/messages:send';

//       final Map<String, dynamic> message = {
//         'message': {
//           'token': deviceToken,
//           'notification': {
//             'title': "New appointment",
//             'body': "Request"
//           },
//           'data': {'doctorId': doctorId},
//           'android': {
//             'priority': 'high'
//           },
//           'apns': {
//             'headers': {'apns-priority': '10'}
//           }
//         }
//       };

//       final http.Response response = await http.post(
//           Uri.parse(endpointFirebaseCloudMessaging),
//           headers: <String, String>{
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer $serverkey'
//           },
//           body: jsonEncode(message));

//       if (response.statusCode == 200) {
//         print("Notification sent successfully");
//       } else {
//         print(
//             "Failed to send notification: ${response.statusCode}, ${response.body}");
//       }
//     } catch (e) {
//       print("Error sending notification: $e");
//     }
//   }
// }
