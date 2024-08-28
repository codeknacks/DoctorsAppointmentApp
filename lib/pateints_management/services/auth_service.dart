import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_appointment_app/pateints_management/services/pateint_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      if (gUser == null) return;

      final GoogleSignInAuthentication gAuth = await gUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot patientDoc = await _firestore.collection('patients').doc(user.uid).get();
        String deviceToken;
        if (!patientDoc.exists) {
          deviceToken = await _firebaseMessaging.getToken() ?? '';
          await _firestore.collection('patients').doc(user.uid).set({
            'email': user.email,
            'fullname': user.displayName ?? 'Unknown',
            'deviceToken': deviceToken,
            'patientId': user.uid,
          });
        } else {
          deviceToken = patientDoc['deviceToken'];
        }

        // Store in global state
        Provider.of<PateintProvider>(context, listen: false).setUserDetails(
          userId: user.uid,
          deviceToken: deviceToken,
        );

        Navigator.pushReplacementNamed(context, '/homepage');
      }
    } catch (e) {
      print('Error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred: ${e.toString()}')));
      }
    }
  }

  static Future<void> signupUser(String email, String password, String name, BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        String deviceToken = await _firebaseMessaging.getToken() ?? '';
        await _firestore.collection('patients').doc(user.uid).set({
          'email': email,
          'fullname': name,
          'deviceToken': deviceToken,
          'patientId': user.uid,
        });

        // Store in global state
        Provider.of<PateintProvider>(context, listen: false).setUserDetails(
          userId: user.uid,
          deviceToken: deviceToken,
        );

        Navigator.pushReplacementNamed(context, '/homepage');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration Successful')));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Email Provided already Exists')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred. Please try again.')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred: ${e.toString()}')));
      }
    }
  }
static Future<void> signinUser(String email, String password, BuildContext context) async {
  try {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    User? user = userCredential.user;

    if (user != null) {
      DocumentSnapshot patientDoc = await _firestore.collection('patients').doc(user.uid).get();

      // Cast the document data to a Map
      Map<String, dynamic>? data = patientDoc.data() as Map<String, dynamic>?;

      // Safely access fields with default values if they are missing
      String deviceToken = data?.containsKey('deviceToken') == true
          ? data!['deviceToken']
          : ''; // Provide a default value if the field is missing

      String patientId = data?.containsKey('patientId') == true
          ? data!['patientId']
          : ''; // Provide a default value if the field is missing

      // Store in global state
      Provider.of<PateintProvider>(context, listen: false).setUserDetails(
        userId: patientId,
        deviceToken: deviceToken,
      );

      Navigator.pushReplacementNamed(context, '/homepage');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You are Logged in')));
    }
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No user found with this Email')));
    } else if (e.code == 'wrong-password') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password did not match')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred')));
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An unexpected error occurred')));
  }
}


}
