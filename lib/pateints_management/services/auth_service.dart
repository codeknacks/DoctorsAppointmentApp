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
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
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

        Provider.of<PateintProvider>(context, listen: false).setUserDetails(
          userId: user.uid,
          deviceToken: deviceToken,
        );

        Navigator.pushReplacementNamed(context, '/homepage');
      }
    } catch (e) {
      print('Error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: ${e.toString()}')),
        );
      }
    }
  }

  static Future<void> signupUser(
    String email, 
    String password, 
    String name, 
    BuildContext context
  ) async {
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

        Provider.of<PateintProvider>(context, listen: false).setUserDetails(
          userId: user.uid,
          deviceToken: deviceToken,
        );

        Navigator.pushReplacementNamed(context, '/homepage');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration Successful')));
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = e.code == 'email-already-in-use'
          ? 'The email provided is already in use.'
          : 'An error occurred. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: ${e.toString()}')),
        );
      }
    }
  }

  static Future<void> signinUser(
    String email, 
    String password, 
    BuildContext context
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot patientDoc = await _firestore.collection('patients').doc(user.uid).get();
        Map<String, dynamic>? data = patientDoc.data() as Map<String, dynamic>?;

        String deviceToken = data?['deviceToken'] ?? '';
        String patientId = data?['patientId'] ?? '';

        Provider.of<PateintProvider>(context, listen: false).setUserDetails(
          userId: patientId,
          deviceToken: deviceToken,
        );

        Navigator.pushReplacementNamed(context, '/homepage');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You are logged in')));
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = e.code == 'user-not-found'
          ? 'No user found with this email.'
          : e.code == 'wrong-password'
              ? 'The password did not match.'
              : 'An error occurred.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An unexpected error occurred')));
    }
  }
}
