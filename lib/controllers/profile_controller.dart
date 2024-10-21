// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';

// class ProfileController extends GetxController {
//   final formKey = GlobalKey<FormState>();
//   var name = ''.obs;
//   var email = ''.obs;
//   File? imageFile;
//   final ImagePicker picker = ImagePicker();

//   @override
//   void onInit() {
//     super.onInit();
//     loadUserData();
//   }

//   Future<void> loadUserData() async {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       name.value = user.displayName ?? '';
//       email.value = user.email ?? '';
//     }
//   }

//   Future<void> pickImage() async {
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       imageFile = File(pickedFile.path);
//       update(); // Update the UI after picking the image
//     }
//   }

//   Future<String> uploadImage(File image) async {
//     String fileName =
//         'profile_images/${FirebaseAuth.instance.currentUser!.uid}';
//     try {
//       UploadTask uploadTask =
//           FirebaseStorage.instance.ref(fileName).putFile(image);
//       TaskSnapshot snapshot = await uploadTask;
//       return await snapshot.ref.getDownloadURL();
//     } catch (e) {
//       print("Error uploading image: $e");
//       return "";
//     }
//   }

//   Future<void> updateUserProfile() async {
//     if (formKey.currentState!.validate()) {
//       User? user = FirebaseAuth.instance.currentUser;
//       String? imageUrl;

//       if (imageFile != null) {
//         imageUrl = await uploadImage(imageFile!);
//       }

//       if (user != null) {
//         await user.updateProfile(displayName: name.value);
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .update({
//           'name': name.value,
//           'email': email.value,
//           'imageUrl': imageUrl,
//         });
//         Get.snackbar("Success", "Profile updated successfully");
//       }
//     }
//   }

//   void signOut() {
//     FirebaseAuth.instance.signOut();
//     Get.offAllNamed('/wrapper');
//   }
// }
