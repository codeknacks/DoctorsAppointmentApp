
import 'package:doctor_appointment_app/pateints_management/pages/doctor_detail_page.dart';
import 'package:doctor_appointment_app/pateints_management/pages/login_page.dart';
import 'package:doctor_appointment_app/pateints_management/pages/notification_page.dart';
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
    fetchSpecializations();
  }

  void fetchSpecializations() async {
    final result = await FirebaseFirestore.instance.collection('doctors').get();
    final uniqueSpecializations = result.docs
        .where((doc) => doc.data().containsKey('specialization'))
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

  void navigateToNotificationScreen() async {
    // Assuming you want to fetch the patientId from the chats collection
    final chatSnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .where('sender', isEqualTo: 'doctor')
        .get();

    if (chatSnapshot.docs.isNotEmpty) {
      final patientId = chatSnapshot.docs.first['patientId'];
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NotificationsScreen(patientId: patientId)
        ),
      );
    } else {
      // Handle the case where no chat is found
      print('No chats found');
    }
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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.graphic_eq),
                SizedBox(width: 8),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedSpecialization.isEmpty
                        ? null
                        : selectedSpecialization,
                    onChanged: (value) {
                      setState(() {
                        selectedSpecialization = value!;
                        searchDoctors(searchQuery, selectedSpecialization);
                      });
                    },
                    hint: Text("Filter"),
                    items: [
                      DropdownMenuItem(
                          value: "", child: Text("All Specializations")),
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.notifications),
        onPressed: navigateToNotificationScreen,
      ),
    );
  }
}
