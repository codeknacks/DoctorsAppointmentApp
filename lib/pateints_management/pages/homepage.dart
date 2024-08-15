import 'package:doctor_appointment_app/pateints_management/pages/doctor_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class HomePage extends StatefulWidget {
  
  



  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String searchQuery = "";
  List<QueryDocumentSnapshot> doctors = [];

  void searchDoctors(String query) async {
    final result = await FirebaseFirestore.instance
        .collection('doctors')
        .where('name', isEqualTo: query)
        .get();
    setState(() {
      searchQuery = query;
      doctors = result.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Doctors"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                searchDoctors(value);
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
          Expanded(
            child: ListView.builder(
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(doctors[index]['name']),
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
