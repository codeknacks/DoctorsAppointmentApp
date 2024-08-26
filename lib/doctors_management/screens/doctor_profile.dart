import 'dart:io';
import 'package:doctor_appointment_app/doctors_management/screens/doctor_home_screen.dart';
import 'package:doctor_appointment_app/doctors_management/screens/doctor_navigation_bar.dart';
import 'package:doctor_appointment_app/doctors_management/screens/doctors_availability.dart';
import 'package:doctor_appointment_app/doctors_management/screens/chatlistscreen.dart';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_appointment_app/doctors_management/model/doctor_model.dart';
import 'package:doctor_appointment_app/selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorProfileScreen extends StatefulWidget {
  @override
  _DoctorProfileScreenState createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  int _selectedIndex = 1;
  late String doctorId;

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
    if (index == 3) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DoctorChatPatientListScreen()));
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
  int _reviewCount = 0;

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
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot reviewSnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('doctorId', isEqualTo: user.uid)
          .get();

      setState(() {
        _reviewCount = reviewSnapshot.size;
      });
    }
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
    });

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      doctorId = user.uid;
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(user.uid)
          .get();

      if (docSnapshot.exists) {
        var data = docSnapshot.data() as Map<String, dynamic>;

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
          _docId = docSnapshot.id;
        });
      }
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

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentReference doctorRef =
            FirebaseFirestore.instance.collection('doctors').doc(user.uid);

        await doctorRef.set(doctorProfile.toMap(), SetOptions(merge: true));
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

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out from Firebase
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                UserSelectionScreen()), // Redirect to login screen
      );
    } catch (e) {
      print('Error logging out: $e');
      // You can show an error message to the user if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Profile',
            style: TextStyle(color: Colors.white),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.cyan],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: _logout, // Call the logout method on press
            ),
          ]),
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
                        backgroundColor: Colors.grey[300],
                        child: _profilePicUrl == null
                            ? Icon(Icons.add_a_photo, color: Colors.white)
                            : null,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(color: Colors.blueGrey[800]),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueGrey[800]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueAccent),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter name' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _specializationController,
                      decoration: InputDecoration(
                        labelText: 'Specialization',
                        labelStyle: TextStyle(color: Colors.blueGrey[800]),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueGrey[800]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueAccent),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter specialization' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _clinicAddressController,
                      decoration: InputDecoration(
                        labelText: 'Clinic Address',
                        labelStyle: TextStyle(color: Colors.blueGrey[800]),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueGrey[800]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueAccent),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter clinic address' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _ratePerHourController,
                      decoration: InputDecoration(
                        labelText: 'Rate Per Hour',
                        labelStyle: TextStyle(color: Colors.blueGrey[800]),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueGrey[800]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueAccent),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter rate per hour' : null,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Unavailable Days:',
                      style: TextStyle(
                          color: Colors.blueGrey[800],
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
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
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueGrey[800]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueAccent),
                        ),
                      ),
                      validator: (value) => value == null
                          ? 'Please select unavailable days'
                          : null,
                    ),
                    // Add this under the Save Profile button or wherever suitable in the layout
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DoctorReviewsScreen(doctorId: doctorId),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Reviews',
                              style: TextStyle(
                                color: Colors.blueGrey[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$_reviewCount Review${_reviewCount > 1 ? 's' : ''}',
                              style: TextStyle(
                                color: Colors.blueAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 32),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue, Colors.cyan],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors
                              .transparent, // Make the button's background color transparent
                          elevation:
                              0, // Remove the button's shadow to show the gradient properly
                        ),
                        child: Text(
                          'Save Profile',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
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

class DoctorReviewsScreen extends StatefulWidget {
  final String doctorId;

  DoctorReviewsScreen({required this.doctorId});

  @override
  _DoctorReviewsScreenState createState() => _DoctorReviewsScreenState();
}

class _DoctorReviewsScreenState extends State<DoctorReviewsScreen> {
  List<Review> _reviews = [];

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    QuerySnapshot reviewSnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('doctorId', isEqualTo: widget.doctorId)
        .get();

    List<Review> reviews =
        await Future.wait(reviewSnapshot.docs.map((doc) async {
      double rating =
          (doc['rating'] as num).toDouble(); // Ensure rating is a double
      String description = doc['description'];
      String patientId = doc['patientId'];

      // Fetch patient name from 'appointments' collection based on patientId
      DocumentSnapshot patientSnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .doc(patientId)
          .get();

      String patientName = patientSnapshot['name'] ?? 'Unknown Patient';

      return Review(
        patientName: patientName,
        rating: rating,
        description: description,
      );
    }).toList());

    setState(() {
      _reviews = reviews;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Reviews'),
      ),
      body: _reviews.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                Review review = _reviews[index];
                int roundedRating =
                    review.rating.round(); // Round the rating to an integer

                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review.patientName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18.0),
                        ),
                        SizedBox(height: 8.0),
                        Row(
                          children: List.generate(roundedRating, (index) {
                            return Icon(Icons.star, color: Colors.amber);
                          }),
                        ),
                        SizedBox(height: 8.0),
                        Text(review.description),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class Review {
  final String patientName;
  final double rating;
  final String description;

  Review({
    required this.patientName,
    required this.rating,
    required this.description,
  });
}
