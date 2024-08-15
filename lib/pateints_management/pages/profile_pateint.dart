import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String? _patientId;

  @override
  void initState() {
    super.initState();
    _loadPatientId();
  }

  Future<void> _loadPatientId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _patientId = prefs.getString('patient_id');

    if (_patientId != null) {
      _loadPatientData();
    } else {
      setState(() {
        _isEditing = true;
      });
    }
  }

  Future<void> _loadPatientData() async {
    if (_patientId == null) return;

    final DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('patients')
        .doc(_patientId)
        .get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;

      _nameController.text = data['name'] ?? '';
      _ageController.text = data['age'].toString();
      _mobileController.text = data['mobile'] ?? '';
      _addressController.text = data['address'] ?? '';
      _profileImageUrl = data['profile_image'];

      setState(() {
        _isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Add details' : 'Patient Profile')),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_profileImageUrl != null)
          Image.network(_profileImageUrl!),
        Text('Name: ${_nameController.text}'),
        Text('Age: ${_ageController.text}'),
        Text('Mobile: ${_mobileController.text}'),
        Text('Address: ${_addressController.text}'),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _isEditing = true;
            });
          },
          child: Text('Edit Details'),
        ),
      ],
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
    if (_image == null || _nameController.text.isEmpty || _ageController.text.isEmpty || 
        _mobileController.text.isEmpty || _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final String? deviceToken = await FirebaseMessaging.instance.getToken();
    if (_patientId == null) {
      _patientId = FirebaseFirestore.instance.collection('patients').doc().id;
    }

    try {
      // Upload Image to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('profile_images/$_patientId.jpg');
      await storageRef.putFile(File(_image!.path));
      _profileImageUrl = await storageRef.getDownloadURL();

      // Save Patient Data to Firestore
      await FirebaseFirestore.instance.collection('patients').doc(_patientId).set({
        'name': _nameController.text,
        'age': int.parse(_ageController.text),
        'mobile': _mobileController.text,
        'address': _addressController.text,
        'profile_image': _profileImageUrl,
        'device_token': deviceToken,
        'patient_id': _patientId,
        'created_at': FieldValue.serverTimestamp(),
      });

      // Save patient ID to SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('patient_id', _patientId!);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Patient added successfully')));

      setState(() {
        _isEditing = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add patient: $e')));
    }
  }
}
