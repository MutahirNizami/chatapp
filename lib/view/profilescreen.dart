// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'package:chatapp/router/bottomnavigation.dart';
import 'package:chatapp/router/wrapper.dart';
import 'package:chatapp/utilites/colors.dart';
import 'package:chatapp/widget/button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  // ignore: unused_field
  String? _imageUrl;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        _name = user.displayName ?? '';
        _email = user.email ?? '';
        _imageUrl = null;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickMedia();

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    String fileName =
        'profile_images/${FirebaseAuth.instance.currentUser!.uid}';

    try {
      // Upload the file to Firebase Storage...............
      UploadTask uploadTask =
          FirebaseStorage.instance.ref(fileName).putFile(image);
      TaskSnapshot snapshot = await uploadTask;

      // Get the download URL....................
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return "";
    }
  }

  Future<void> _updateUserProfile() async {
    if (_formKey.currentState!.validate()) {
      // Update user profile.......................
      User? user = FirebaseAuth.instance.currentUser;

      String? imageUrl;

      // Upload image if selected.....................
      if (_imageFile != null) {
        imageUrl = await _uploadImage(_imageFile!);
      }

      if (user != null) {
        await user.updateProfile(displayName: _name);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'name': _name,
          'email': _email,
          'imageUrl': imageUrl,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Mycolor().backcolor,
      appBar: AppBar(
        backgroundColor: Mycolor().backcolor,
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DashboardScreen(),
                  ));
            },
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: height * 0.03,
              color: Mycolor().titlecolor,
            )),
        title: Text(
          'Profile',
          style: TextStyle(fontSize: height * 0.03),
        ),
        titleTextStyle: TextStyle(color: Mycolor().titlecolor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: height * 0.07,
                  backgroundImage:
                      _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null
                      ? Icon(Icons.person, size: height * 0.1)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(
                    fillColor: Mycolor().nonfcontainercolor,
                    filled: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none),
                    hintText: 'Name'),
                onChanged: (value) => _name = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                style: TextStyle(color: Mycolor().titlecolor),
              ),
              TextFormField(
                initialValue: _email,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Mycolor().nonfcontainercolor,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none),
                  hintText: 'Email',
                ),
                onChanged: (value) => _email = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                style: TextStyle(color: Mycolor().titlecolor),
              ),
              Appbutton(
                ontap: _updateUserProfile,
                text: 'Update',
                btncolor: Mycolor().btncolor,
                btnwidth: width * 0.4,
                borderradius: height * 0.03,
                textcolor: Mycolor().titlecolor,
              ),
              Padding(
                padding: EdgeInsets.only(top: height * 0.05, left: width * 0.7),
                child: Appbutton(
                  ontap: _signout,
                  text: 'Logout',
                  btncolor: Mycolor().btncolor,
                  btnwidth: width * 0.2,
                  borderradius: height * 0.03,
                  textcolor: Mycolor().titlecolor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _signout() {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Wrapper(),
        ));
  }
}
