// import 'dart:developer';

// import 'package:chatapp/router/bottomnavigation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class LoginController extends GetxController {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();

//   var isPasswordVisible = false.obs;
//   var isLoading = false.obs;

//   // Function to handle login
//   Future<void> loginWithEmailAndPassword() async {
//     if (emailController.text.isEmpty || passwordController.text.isEmpty) {
//       Get.snackbar("Error", "Please enter email and password");
//       return;
//     }

//     isLoading(true);
//     try {
//       await _auth.signInWithEmailAndPassword(
//         email: emailController.text.trim(),
//         password: passwordController.text.trim(),
//       );

//       Get.snackbar("Success", "Login Successful");
//       emailController.clear();
//       passwordController.clear();
//       Get.offAll(() => const DashboardScreen());
//     } on FirebaseAuthException catch (e) {
//       Get.snackbar("Login failed", "Please SignUp you accout");
//       log("$e");
//     } finally {
//       isLoading(false);
//     }
//   }

//   // Function to toggle password visibility
//   void togglePasswordVisibility() {
//     isPasswordVisible(!isPasswordVisible.value);
//   }
// }

import 'dart:developer';
import 'package:chatapp/router/bottomnavigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isPasswordVisible = false.obs;
  var isLoading = false.obs;

  // Function to handle login
  Future<void> loginWithEmailAndPassword() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar("Error", "Please enter email and password");
      return;
    }

    isLoading(true);
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        // Get the FCM token.........
        String? fcmToken = await _firebaseMessaging.getToken();

        // Store the token in Firestore users collection............
        if (fcmToken != null) {
          await _firestore.collection('users').doc(user.uid).update({
            'fcmToken': fcmToken,
          });
          log('FCM Token saved successfully.');
        }

        Get.snackbar("Success", "Login Successful");
        emailController.clear();
        passwordController.clear();
        Get.offAll(() => const DashboardScreen());
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Login failed", "Please SignUp your account");
      log("$e");
    } finally {
      isLoading(false);
    }
  }

  // Function to toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible(!isPasswordVisible.value);
  }
}
