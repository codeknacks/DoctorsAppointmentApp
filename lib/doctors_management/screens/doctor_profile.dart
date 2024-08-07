// import 'dart:io';
// import 'package:path/path.dart' as path;
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:doctor_appointment_app/doctors_management/model/doctor_model.dart';
// import 'package:doctor_appointment_app/selection_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';

// class DoctorProfileScreen extends StatefulWidget {
//   @override
//   _DoctorProfileScreenState createState() => _DoctorProfileScreenState();
// }

// class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _specializationController =
//       TextEditingController();
//   final TextEditingController _clinicAddressController =
//       TextEditingController();
//   final TextEditingController _ratePerHourController = TextEditingController();
//   List<String> _unavailableDays = [];
//   String? _profilePicUrl;
//   bool _isLoading = false;

//   final List<String> _daysOfWeek = [
//     'Monday',
//     'Tuesday',
//     'Wednesday',
//     'Thursday',
//     'Friday',
//     'Saturday',
//     'Sunday'
//   ];

//   Future<void> _pickProfilePic() async {
//     final ImagePicker _picker = ImagePicker();
//     final XFile? pickedFile =
//         await _picker.pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       File file = File(pickedFile.path);
//       String fileName = path.basename(file.path);

//       try {
//         final storageRef =
//             FirebaseStorage.instance.ref().child('profile_pics/$fileName');
//         final uploadTask = storageRef.putFile(file);

//         final snapshot = await uploadTask.whenComplete(() {});

//         final downloadUrl = await snapshot.ref.getDownloadURL();

//         setState(() {
//           _profilePicUrl = downloadUrl;
//         });
//       } catch (e) {
//         // Handle any errors
//         print('Failed to upload profile picture: $e');
//       }
//     }
//   }

//   Future<void> _saveProfile() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });

//       final availability = Map.fromEntries(_daysOfWeek
//           .map((day) => MapEntry(day, !_unavailableDays.contains(day))));

//       final doctorProfile = DoctorProfile(
//         profilePicUrl: _profilePicUrl ?? '',
//         name: _nameController.text,
//         specialization: _specializationController.text,
//         clinicAddress: _clinicAddressController.text,
//         ratePerHour: double.parse(_ratePerHourController.text),
//         availability: availability,
//       );

//       await FirebaseFirestore.instance
//           .collection('doctors')
//           .add(doctorProfile.toMap());

//       setState(() {
//         _isLoading = false;
//       });

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => DoctorHomeScreen()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Doctor Profile Management')),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               GestureDetector(
//                 onTap: _pickProfilePic,
//                 child: CircleAvatar(
//                   radius: 50,
//                   backgroundImage: _profilePicUrl != null
//                       ? NetworkImage(_profilePicUrl!)
//                       : null,
//                   child:
//                       _profilePicUrl == null ? Icon(Icons.add_a_photo) : null,
//                 ),
//               ),
//               TextFormField(
//                 controller: _nameController,
//                 decoration: InputDecoration(labelText: 'Name'),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Please enter name' : null,
//               ),
//               TextFormField(
//                 controller: _specializationController,
//                 decoration: InputDecoration(labelText: 'Specialization'),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Please enter specialization' : null,
//               ),
//               TextFormField(
//                 controller: _clinicAddressController,
//                 decoration: InputDecoration(labelText: 'Clinic Address'),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Please enter clinic address' : null,
//               ),
//               TextFormField(
//                 controller: _ratePerHourController,
//                 decoration: InputDecoration(labelText: 'Rate Per Hour'),
//                 keyboardType: TextInputType.number,
//                 validator: (value) =>
//                     value!.isEmpty ? 'Please enter rate per hour' : null,
//               ),
//               SizedBox(height: 16),
//               Text('Unavailable Days:'),
//               DropdownButtonFormField<String>(
//                 value: _unavailableDays.isEmpty ? null : _unavailableDays.first,
//                 items: _daysOfWeek.map((day) {
//                   return DropdownMenuItem<String>(
//                     value: day,
//                     child: Text(day),
//                   );
//                 }).toList(),
//                 onChanged: (String? newValue) {
//                   setState(() {
//                     if (newValue != null) {
//                       if (_unavailableDays.contains(newValue)) {
//                         _unavailableDays.remove(newValue);
//                       } else {
//                         _unavailableDays.add(newValue);
//                       }
//                     }
//                   });
//                 },
//                 hint: Text('Select unavailable days'),
//                 isExpanded: true,
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               SizedBox(height: 16),
//               _isLoading
//                   ? Center(child: CircularProgressIndicator())
//                   : ElevatedButton(
//                       onPressed: _saveProfile,
//                       child: Text('Save Profile'),
//                     ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class DoctorHomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Doctor Home')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => UserSelectionScreen()),
//                 );
//               },
//               child: Text('Logout'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => DoctorProfileScreen()),
//                 );
//               },
//               child: Text('Profile Screen'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:doctor_appointment_app/doctors_management/screens/doctor_home_screen.dart';
import 'package:doctor_appointment_app/doctors_management/screens/doctor_navigation_bar.dart';
import 'package:doctor_appointment_app/doctors_management/screens/doctors_availability.dart';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_appointment_app/doctors_management/model/doctor_model.dart';
import 'package:doctor_appointment_app/selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DoctorProfileScreen extends StatefulWidget {
  @override
  _DoctorProfileScreenState createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => DoctorHomeScreen()));
    }
    if (index == 1) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => DoctorProfileScreen()));
    }
    if (index == 2) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => DoctorAvailabilityScreen()));
    }
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _specializationController =
      TextEditingController();
  final TextEditingController _clinicAddressController =
      TextEditingController();
  final TextEditingController _ratePerHourController = TextEditingController();
  List<String> _unavailableDays = [];
  String? _profilePicUrl;
  bool _isLoading = false;
  bool _isProfileExists = false;
  String? _docId;

  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
    });

    // Assuming there is only one doctor profile per user.
    final QuerySnapshot result =
        await FirebaseFirestore.instance.collection('doctors').limit(1).get();

    final List<DocumentSnapshot> documents = result.docs;

    if (documents.isNotEmpty) {
      var doc = documents.first;
      var data = doc.data() as Map<String, dynamic>;

      _nameController.text = data['name'];
      _specializationController.text = data['specialization'];
      _clinicAddressController.text = data['clinicAddress'];
      _ratePerHourController.text = data['ratePerHour'].toString();
      _profilePicUrl = data['profilePicUrl'];
      _unavailableDays = _daysOfWeek
          .where((day) => !data['availability'][day])
          .toList()
          .cast<String>();

      setState(() {
        _isProfileExists = true;
        _docId = doc.id;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickProfilePic() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      String fileName = path.basename(file.path);

      try {
        final storageRef =
            FirebaseStorage.instance.ref().child('profile_pics/$fileName');
        final uploadTask = storageRef.putFile(file);

        final snapshot = await uploadTask.whenComplete(() {});

        final downloadUrl = await snapshot.ref.getDownloadURL();

        setState(() {
          _profilePicUrl = downloadUrl;
        });
      } catch (e) {
        // Handle any errors
        print('Failed to upload profile picture: $e');
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final availability = Map.fromEntries(_daysOfWeek
          .map((day) => MapEntry(day, !_unavailableDays.contains(day))));

      final doctorProfile = DoctorProfile(
        profilePicUrl: _profilePicUrl ?? '',
        name: _nameController.text,
        specialization: _specializationController.text,
        clinicAddress: _clinicAddressController.text,
        ratePerHour: double.parse(_ratePerHourController.text),
        availability: availability,
      );

      if (_isProfileExists) {
        // Update existing profile
        await FirebaseFirestore.instance
            .collection('doctors')
            .doc(_docId)
            .update(doctorProfile.toMap());
      } else {
        // Add new profile
        await FirebaseFirestore.instance
            .collection('doctors')
            .add(doctorProfile.toMap());
      }

      setState(() {
        _isLoading = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DoctorHomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Doctor Profile Management')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    GestureDetector(
                      onTap: _pickProfilePic,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _profilePicUrl != null
                            ? NetworkImage(_profilePicUrl!)
                            : null,
                        child: _profilePicUrl == null
                            ? Icon(Icons.add_a_photo)
                            : null,
                      ),
                    ),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter name' : null,
                    ),
                    TextFormField(
                      controller: _specializationController,
                      decoration: InputDecoration(labelText: 'Specialization'),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter specialization' : null,
                    ),
                    TextFormField(
                      controller: _clinicAddressController,
                      decoration: InputDecoration(labelText: 'Clinic Address'),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter clinic address' : null,
                    ),
                    TextFormField(
                      controller: _ratePerHourController,
                      decoration: InputDecoration(labelText: 'Rate Per Hour'),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter rate per hour' : null,
                    ),
                    SizedBox(height: 16),
                    Text('Unavailable Days:'),
                    DropdownButtonFormField<String>(
                      value: _unavailableDays.isEmpty
                          ? null
                          : _unavailableDays.first,
                      items: _daysOfWeek.map((day) {
                        return DropdownMenuItem<String>(
                          value: day,
                          child: Text(day),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          if (newValue != null) {
                            if (_unavailableDays.contains(newValue)) {
                              _unavailableDays.remove(newValue);
                            } else {
                              _unavailableDays.add(newValue);
                            }
                          }
                        });
                      },
                      hint: Text('Select unavailable days'),
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _saveProfile,
                            child: Text(_isProfileExists
                                ? 'Update Profile'
                                : 'Save Profile'),
                          ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: DoctorNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
