



// import 'package:curved_navigation_bar/curved_navigation_bar.dart';
// import 'package:doctor_appointment_app/display_appointment.dart';
// import 'package:doctor_appointment_app/pateints_management/pages/appointment_details.dart';
// import 'package:doctor_appointment_app/pateints_management/pages/homepage.dart';
// import 'package:flutter/material.dart';

// class NavBAr extends StatefulWidget {
//   const NavBAr({super.key});

//   @override
//   State<NavBAr> createState() => _NavBArState();
// }

// class _NavBArState extends State<NavBAr> {

//   int Index = 0 ;
  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//        bottomNavigationBar: CurvedNavigationBar(
//         backgroundColor:   const Color.fromARGB(255,168, 221, 133),
//         color:const Color.fromARGB(255, 111, 164, 115) ,
//         animationDuration: const Duration(milliseconds: 500),
//         index: Index,
//         onTap: (selectedIndex){
//           setState(() {
//             Index = selectedIndex;
//           });
//         },
//         items: const [
        
//       Icon(Icons.home),
//       Icon(Icons.location_on_outlined),
//       Icon(Icons.av_timer_sharp)
//       ]
//       ),
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         alignment: Alignment.center,
//         child: selectedWidget(index: Index)
//       ),
//     ); 
    
    
//   }
//   Widget selectedWidget ({required int index}){
//     Widget widget;
//     switch(index){
//       case 0:
//       widget = HomePage(); 
//       break;
//        case 1:
//       widget =  BookedAppointmentsPage();
//       break;
//       case 2:
//       widget = AppointmentDetailsPage();
//       default: 
//        widget = HomePage();
//       break;
//     }
//     return widget;
//   }
// }