// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';

// class FCMService {
//   static final FirebaseMessaging _firebaseMessaging =
//       FirebaseMessaging.instance;

//   static Future<void> initialize() async {
//     // Request permissions (iOS)
//     await _firebaseMessaging.requestPermission();

//     // Get the device token
//     String? token = await _firebaseMessaging.getToken();
//     print("Device Token: $token");

//     // Handle messages when the app is in the foreground
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('Message data: ${message.data}');
//       if (message.notification != null) {
//         print('Message notification: ${message.notification!.title}');
//       }
//     });

//     // Handle messages when the app is in the background or terminated
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('Message clicked! ${message.data}');
//     });
//   }
// }
