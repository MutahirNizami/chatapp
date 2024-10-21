import 'dart:developer';

import 'package:chatapp/router/bottomnavigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
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
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      Get.snackbar("Success", "Login Successful");
      emailController.clear();
      passwordController.clear();
      Get.offAll(() => const DashboardScreen());
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Login failed", "Please SignUp you accout");
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
