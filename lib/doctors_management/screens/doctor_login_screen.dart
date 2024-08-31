import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_appointment_app/doctors_management/screens/doctor_signup_screen.dart';
import 'package:doctor_appointment_app/doctors_management/screens/doctors_availability.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:doctor_appointment_app/doctors_management/provider/userprovider.dart';
import 'package:provider/provider.dart';

class DoctorLoginScreen extends StatefulWidget {
  @override
  _DoctorLoginScreenState createState() => _DoctorLoginScreenState();
}

class _DoctorLoginScreenState extends State<DoctorLoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _formKey = GlobalKey<FormState>();
  String? _email, _password;
  bool _isLoading = false;

  void _saveDeviceToken(User? user) async {
    if (user != null) {
      FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        DocumentReference docRef =
            FirebaseFirestore.instance.collection('doctors').doc(user.uid);

        try {
          DocumentSnapshot docSnapshot = await docRef.get();
          if (docSnapshot.exists) {
            await docRef.update({'deviceToken': token});
          } else {
            await docRef.set({'deviceToken': token});
          }
        } catch (e) {
          print("Error saving device token: $e");
        }
      }
    }
  }

  void _loginWithEmail() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _email!,
          password: _password!,
        );
        User? user = userCredential.user;

        // Save FCM token
        _saveDeviceToken(user);

        Provider.of<UserProvider>(context, listen: false).setUser(user);

        setState(() {
          _isLoading = false;
        });
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => DoctorAvailabilityScreen()));
      } catch (e) {
        print(e);
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Login failed.'),
        ));
      }
    }
  }

  void _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      // Save FCM token
      _saveDeviceToken(user);

      Provider.of<UserProvider>(context, listen: false).setUser(user);

      setState(() {
        _isLoading = false;
      });
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => DoctorAvailabilityScreen()));
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Google sign-in failed.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Login'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/Login.jpg',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.lightBlue.shade100.withOpacity(0.3),
                  Colors.lightBlue.shade300.withOpacity(0.3)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Email',
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Enter your email' : null,
                            onSaved: (value) => _email = value,
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Password',
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Enter your password' : null,
                            onSaved: (value) => _password = value,
                            obscureText: true,
                          ),
                          SizedBox(height: 20),
                          _isLoading
                              ? CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: _loginWithEmail,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.lightBlue.shade300,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 100.0, vertical: 15.0),
                                  ),
                                  child: Text(
                                    'Login',
                                    style: TextStyle(fontSize: 18.0),
                                  ),
                                ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _loginWithGoogle,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 100.0, vertical: 15.0),
                            ),
                            child: Text(
                              'Login with Google',
                              style: TextStyle(fontSize: 18.0),
                            ),
                          ),
                          SizedBox(height: 20),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DoctorSignUpScreen()),
                              );
                            },
                            child: Text('Don\'t have an account? Sign Up'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
