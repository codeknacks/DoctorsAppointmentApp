import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

class DoctorPage extends StatefulWidget {
  const DoctorPage({super.key});

  @override
  State<DoctorPage> createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  Query dbref = FirebaseDatabase.instance.ref('doctordata');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: FirebaseAnimatedList(
                query: dbref,
                itemBuilder: (context, snapshot, animation, index) {
                 return ListTile(
                  title: Text(
                    snapshot.child('name').value.toString()),
                 );
            
                  
                }),
          ),
        ],
      ),
    );
  }

  // Widget listItem({required Map doctor}) {
  //   return Container(
  //     margin: const EdgeInsets.all(10),
  //     padding: const EdgeInsets.all(10),
  //     height: 110,
  //     color: Colors.amberAccent,
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           doctor['name'],
  //           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
  //         ),
  //         const SizedBox(
  //           height: 5,
  //         ),
  //         Text(
  //           doctor['age'],
  //           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
  //         ),
  //         const SizedBox(
  //           height: 5,
  //         ),
  //         Text(
  //           doctor['ratings'],
  //           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
