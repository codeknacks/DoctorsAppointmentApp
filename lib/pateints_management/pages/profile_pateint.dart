import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:doctor_appointment_app/pateints_management/services/pateint_provider.dart';

class PatientProfilePage extends StatefulWidget {
  @override
  _PatientProfilePageState createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String? _profileImageUrl;
  XFile? _image;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  Future<void> _loadPatientData() async {
    final userProvider = Provider.of<PateintProvider>(context, listen: false);
    final String? patientId = userProvider.userId;

    if (patientId != null) {
      final DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('patients')
          .doc(patientId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        _nameController.text = data['name'] ?? '';
        _ageController.text = data['age']?.toString() ?? '';
        _mobileController.text = data['mobile'] ?? '';
        _addressController.text = data['address'] ?? '';
        _profileImageUrl = data['profile_image'];

        setState(() {
          _isEditing = false;
        });
      } else {
        setState(() {
          _isEditing = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Add Details' : 'Patient Profile'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isEditing ? _buildForm() : _buildProfileView(),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: _ageController,
            decoration: InputDecoration(labelText: 'Age'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _mobileController,
            decoration: InputDecoration(labelText: 'Mobile Number'),
            keyboardType: TextInputType.phone,
          ),
          TextField(
            controller: _addressController,
            decoration: InputDecoration(labelText: 'Address'),
          ),
          SizedBox(height: 16),
          _image == null
              ? Text('No image selected.')
              : Image.file(File(_image!.path)),
          ElevatedButton(
            onPressed: _pickImage,
            child: Text('Upload Profile Photo'),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _savePatientData,
            child: Text('Save Patient'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileView() {
    return Center(
      child: Card(
        elevation: 4.0, // Controls the shadow depth of the card
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0), // Rounds the corners of the card
        ),
        margin: const EdgeInsets.all(16.0), // Space around the card
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Space inside the card
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50.0, // Adjust the radius as needed
                  backgroundImage: _profileImageUrl != null
                      ? NetworkImage(_profileImageUrl!)
                      : null,
                  backgroundColor: Colors.grey[200], // Fallback background color
                  child: _profileImageUrl == null
                      ? Icon(Icons.person, size: 50.0, color: Colors.grey[400])
                      : null, // Placeholder icon if no image is available
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Name: ${_nameController.text}',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Age: ${_ageController.text}',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Mobile: ${_mobileController.text}',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Address: ${_addressController.text}',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 200),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Button background color
                    textStyle: TextStyle(color: Colors.white), // Button text color
                    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0), // Button padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0), // Rounded corners
                    ),
                    elevation: 5.0, // Shadow elevation
                  ),
                  child: Text(
                    'Edit Details',
                    style: TextStyle(
                      fontSize: 16.0, // Text size
                      fontWeight: FontWeight.bold, // Text weight
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? selectedImage = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = selectedImage;
    });
  }

  Future<void> _savePatientData() async {
    if (_image == null ||
        _nameController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _mobileController.text.isEmpty ||
        _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final userProvider = Provider.of<PateintProvider>(context, listen: false);
    final String? patientId = userProvider.userId;
    final String? deviceToken = userProvider.deviceToken ?? await FirebaseMessaging.instance.getToken();

    if (patientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Patient ID is not available')));
      return;
    }

    try {
      // Upload Image to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('profile_images/$patientId.jpg');
      await storageRef.putFile(File(_image!.path));
      _profileImageUrl = await storageRef.getDownloadURL();

      // Save Patient Data to Firestore
      await FirebaseFirestore.instance.collection('patients').doc(patientId).set({
        'name': _nameController.text,
        'age': int.parse(_ageController.text),
        'mobile': _mobileController.text,
        'address': _addressController.text,
        'profile_image': _profileImageUrl,
        'device_token': deviceToken,
        'patient_id': patientId,
        'created_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Patient added successfully')));

      setState(() {
        _isEditing = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add patient: $e')));
    }
  }
}
