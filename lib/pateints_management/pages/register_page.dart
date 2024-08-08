// import 'package:doctor_appointment_app/pateints_management/components/Button.dart';
// import 'package:doctor_appointment_app/pateints_management/components/my_textfield.dart';
// import 'package:doctor_appointment_app/pateints_management/pages/login_page.dart';
// import 'package:flutter/material.dart';




// class RegisterPage extends StatefulWidget {
//   const RegisterPage({super.key});

//   @override
//   State<RegisterPage> createState() => _RegisterPageState();
// }

// class _RegisterPageState extends State<RegisterPage> {
//   final TextEditingController _emailController = TextEditingController();

//   final TextEditingController _pwController = TextEditingController();

//   final TextEditingController _cpwController = TextEditingController();

    
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: const Color.fromARGB(255, 126, 126, 236),
//         body: Center(
//           child: Stack(
//             children: [
//               // Positioned(
//               //   top: 0,
//               //   left: 0,
//               //   right: 0,
//               //   bottom: 0,
//               //   child: Image.asset(
//               //     'lib/assets/loginbg1.jpg',
//               //     fit: BoxFit.cover,
//               //   )),

//               Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   //logo
              
//                   const Icon(
//                     size: 80,
//                     Icons.medical_information_outlined,
//                     color: Color.fromARGB(255, 255, 255, 255),
//                   ),
//                   const SizedBox(
//                     height: 20,
//                   ),
              
//                   const Text(
//                     'Pateint Registration >>',
//                     style: TextStyle(
//                       fontSize: 20,
//                       color: Colors.white,
//                     ),
//                   ),
              
//                   const SizedBox(
//                     height: 20,
//                   ),
              
//                   //emailtextfield
              
//                   MyTextfield(
//                     hintText: 'Enter your email',
//                     obscureText: false,
//                     controller: _emailController,
//                     hintColor: Colors.white,
//                     color: Colors.white,
                    
//                   ),
              
//                   const SizedBox(
//                     height: 8,
//                   ),
              
//                   //pwtextfield
              
//                   MyTextfield(
//                     hintText: 'password',
//                     obscureText: true,
//                     controller: _pwController,
//                     hintColor: Colors.white,
//                     color: Colors.white,
                   
//                   ),
              
//                   const SizedBox(
//                     height: 8,
//                   ),
              
//                   MyTextfield(
//                     hintText: 'Confirm password',
//                     obscureText: true,
//                     controller: _cpwController,
//                     hintColor: Colors.white,
//                     color: Colors.white,
                    
//                   ),
              
//                   const SizedBox(
//                     height: 30,
//                   ),
              
//                   // login
//                   Button(text: 'Register', onTap: () {}),
              
//                   const SizedBox(
//                     height: 30,
//                   ),
              
//                   //register
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text(
//                         'Already member?',
//                         style: TextStyle(
//                           color: Color.fromARGB(255, 255, 255, 255),
//                         ),
//                       ),
//                       InkWell(
//                         onTap: () {
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => const LoginPage()));
//                         },
//                         child: const Text(
//                           'Login now',
//                           style: TextStyle(
//                             color: Color.fromARGB(255, 255, 255, 255),
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ));
//   }
// }
