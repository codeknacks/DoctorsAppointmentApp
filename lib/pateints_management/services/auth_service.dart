import 'package:doctor_appointment_app/pateints_management/services/firebasefunctions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';


class AuthService {
  Future<void> signInWithGoogle(BuildContext context) async {
    // Google Sign-In
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    // Obtain auth details
    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    // Sign in
    await FirebaseAuth.instance.signInWithCredential(credential);

    // Navigate to homepage
    Navigator.pushReplacementNamed(context, '/homepage');

    
  }
 static Future<void> signupUser(
      String email, String password, String name, BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: 
 email, password: password); 


      // Update user profile (optional, as displayName is updated automatically with createUserWithEmailAndPassword)
      await userCredential.user!.updateDisplayName(name);

      // Save user data to Firestore
      await FirestoreServices.saveUser(name, email, userCredential.user!.uid);
Navigator.pushReplacementNamed(context, '/homepage');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Registration Successful')));
    } on FirebaseAuthException catch 
 (e) {
       if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Email Provided already Exists'))); 

      } else {
        // Handling other FirebaseAuthExceptions
        print('FirebaseAuthException: ${e.code}');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An error occurred. Please try again.')));
      }
    } catch (e) {
      print('Error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred: ${e.toString()}')));
      }
    }

  }

  static signinUser(String email, String password, BuildContext context) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
Navigator.pushReplacementNamed(context, '/homepage');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('You are Logged in')));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No user Found with this Email')));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Password did not match')));
      }
    }
  }
  
}
