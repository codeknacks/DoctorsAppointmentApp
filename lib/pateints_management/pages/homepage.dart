import 'package:doctor_appointment_app/pateints_management/pages/chat_page.dart';
import 'package:doctor_appointment_app/pateints_management/pages/doctor_detail_page.dart';
import 'package:doctor_appointment_app/pateints_management/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchQuery = "";
  String selectedSpecialization = "";
  List<QueryDocumentSnapshot> doctors = [];
  List<String> specializations = [];

  @override
  void initState() {
    super.initState();
    fetchSpecializations(); // Fetch specializations when the widget is initialized
  }

  void fetchSpecializations() async {
  final result = await FirebaseFirestore.instance.collection('doctors').get();
  final uniqueSpecializations = result.docs
      .where((doc) => doc.data().containsKey('specialization')) // Check if the specialization field exists
      .map((doc) => doc['specialization'] as String)
      .toSet()
      .toList();

  setState(() {
    specializations = uniqueSpecializations;
  });
}

  void searchDoctors(String query, String specialization) async {
    Query result = FirebaseFirestore.instance.collection('doctors');

    if (query.isNotEmpty) {
      result = result.where('name', isEqualTo: query);
    }

    if (specialization.isNotEmpty) {
      result = result.where('specialization', isEqualTo: specialization);
    }

    final querySnapshot = await result.get();
  
    setState(() {
      searchQuery = query;
      doctors = querySnapshot.docs;
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Search Doctors"),
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
        ),
      ],
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (value) {
              searchDoctors(value, selectedSpecialization);
            },
            decoration: InputDecoration(
              hintText: "Search by name",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: Row(

            mainAxisAlignment: MainAxisAlignment.end, // Aligns the dropdown to the end
            children: [
              
              Icon(Icons.graphic_eq), // Adds the filter icon
              SizedBox(width: 8), // Space between the icon and the dropdown
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedSpecialization.isEmpty ? null : selectedSpecialization,
                  onChanged: (value) {
                    setState(() {
                      selectedSpecialization = value!;
                      searchDoctors(searchQuery, selectedSpecialization);
                    });
                  },
                  hint: Text("Filter"),
                  items: [
                    DropdownMenuItem(value: "", child: Text("All Specializations")),
                    ...specializations.map((specialization) {
                      return DropdownMenuItem(
                        value: specialization,
                        child: Text(specialization),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(thickness: 2),
        Expanded(
          child: ListView.builder(
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(doctors[index]['name']),
                subtitle: Text(doctors[index]['specialization']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DoctorDetailsPage(
                        doctor: doctors[index],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
     
  );
}

}
