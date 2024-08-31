import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:doctor_appointment_app/pateints_management/services/pateint_provider.dart';
import 'package:flutter/scheduler.dart';

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPatientData();
  }

  Future<void> _loadPatientData() async {
    final userProvider = Provider.of<PateintProvider>(context, listen: false);
    final String? patientId = userProvider.userId;

    if (patientId != null && patientId.isNotEmpty) {
      final DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('patients')
          .doc(patientId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        setState(() {
          _nameController.text = data['fullname'] ?? '';
          _ageController.text = data['age']?.toString() ?? '';
          _mobileController.text = data['mobile'] ?? '';
          _addressController.text = data['address'] ?? '';
          _profileImageUrl = data['profile_image'];
          _isEditing = false;
        });
      } else {
        setState(() {
          _isEditing = true;
        });
      }
    } else {
      setState(() {
        _isEditing = true;
      });
      // Delay the SnackBar display until after the current frame
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Patient ID is not available or is empty')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Profile' : 'Patient Profile'),
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
            child: Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileView() {
    return Center(
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        margin: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50.0,
                  backgroundImage: _profileImageUrl != null
                      ? NetworkImage(_profileImageUrl!)
                      : null,
                  backgroundColor: Colors.grey[200],
                  child: _profileImageUrl == null
                      ? Icon(Icons.person, size: 50.0, color: Colors.grey[400])
                      : null,
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
                    backgroundColor: Colors.blue,
                    textStyle: TextStyle(color: Colors.white),
                    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    elevation: 5.0,
                  ),
                  child: Text(
                    'Edit Details',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
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
    if (_nameController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _mobileController.text.isEmpty ||
        _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill all required fields')));
      return;
    }

    final userProvider = Provider.of<PateintProvider>(context, listen: false);
    final String? patientId = userProvider.userId;

    if (patientId == null || patientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Patient ID is not available')));
      return;
    }

    try {
      // Upload Image to Firebase Storage
      if (_image != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images/$patientId.jpg');
        await storageRef.putFile(File(_image!.path));
        _profileImageUrl = await storageRef.getDownloadURL();
      }

      // Save Patient Data to Firestore
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(patientId)
          .update({
        'fullname': _nameController.text,
        'age': int.parse(_ageController.text),
        'mobile': _mobileController.text,
        'address': _addressController.text,
        'profile_image': _profileImageUrl ?? '', // Use empty string if no image is uploaded
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')));

      setState(() {
        _isEditing = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')));
    }
  }
}
