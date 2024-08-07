import 'package:doctor_appointment_app/doctors_management/screens/doctor_login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  EmailVerificationScreen({required this.email});

  @override
  _EmailVerificationScreenState createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isVerified = false;
  bool _isLoading = false;

  void _checkEmailVerified() async {
    setState(() {
      _isLoading = true;
    });
    User? user = FirebaseAuth.instance.currentUser;
    await user!.reload();
    user = FirebaseAuth.instance.currentUser;
    setState(() {
      _isVerified = user!.emailVerified;
      _isLoading = false;
    });
    if (_isVerified) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DoctorLoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please verify your email first.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Your Email'),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'A verification email has been sent to ${widget.email}.',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _checkEmailVerified,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue.shade300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 100.0, vertical: 15.0),
                          ),
                          child: Text(
                            'I have verified',
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
