import 'package:doctor_appointment_app/pateints_management/components/sqaure_tile.dart';
import 'package:doctor_appointment_app/pateints_management/services/auth_service.dart';
import 'package:flutter/material.dart';





class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // final TextEditingController _emailController = TextEditingController();

  // final TextEditingController _pwController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String fullname = '';
  bool login = false;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    } else if (value.length < 8) {
      // Minimum password length of 8 characters
      return 'Password must be at least 8 characters long';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
     
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/Login.jpg',fit: BoxFit.cover),
        
          Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //logo

                  const Icon(
                    size: 80,
                    Icons.person_3_outlined,
                    color: Color.fromARGB(255, 58, 58, 208),
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                  const Text(
                    'Pateint Login >>',
                    style: TextStyle(
                      fontSize: 20,
                      color:Color.fromARGB(255, 58, 58, 208),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  //old code removes from here

                  // new code starts from here
                  login
                      ? Container()
                      : TextFormField(
                          key: const ValueKey('fullname'),
                          decoration: const InputDecoration(
                            hintText: 'Enter Full Name',
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please Enter Full Name';
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) {
                            setState(() {
                              fullname = value!;
                            });
                          },
                        ),
 // ======== Email ========
                        TextFormField(
                key:const ValueKey('email'),
                decoration:const InputDecoration(
                  hintText: 'Enter Email',
                ),
                validator: _validateEmail,
                 onSaved: (value) {
                  setState(() {
                    email = value!;
                  });
                },
              ),
               // ======== Password ========
              TextFormField(
                key: const ValueKey('password'),
                obscureText: true,
                decoration:const InputDecoration(
                  hintText: 'Enter Password',
                ),
                validator: _validatePassword,
                onSaved: (value) {
                  setState(() {
                    password = value!;
                  });
                },
              ),
               const SizedBox(
                height: 30,
              ),
              Container(
                height: 55,
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        login
                            ? AuthService.signinUser(email, password, context)
                            : AuthService.signupUser(
                                email, password, fullname, context);
                      }
                    },
                    child: Text(login ? 'Login' : 'Signup')),
              ),
              const SizedBox(
                height: 10,
              ),
              TextButton(
                  onPressed: () {
                    setState(() {
                      login = !login;
                    });
                  },
                  child: Text(login
                      ? "Don't have an account? Signup"
                      : "Already have an account? Login")),

                  const SizedBox(
                    height: 25,
                  ),
                  const Text("Or continue with"),
                  SqaureTile(
                    imagePath: "assets/google_logo.png",
                    onTap: () => AuthService().signInWithGoogle(context),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
