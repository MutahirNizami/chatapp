import 'package:chatapp/router/bottomnavigation.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

class SignupController extends GetxController {
  var isLoading = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signup(String email, String name, String password) async {
    isLoading.value = true;

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user data in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'id': userCredential.user!.uid,
        'name': name,
        'email': email,
      });

      Get.snackbar('Success', 'Account created successfully!');
      Get.offAll(() => DashboardScreen());
    } catch (e) {
      log("Firebase error: $e");
      Get.snackbar('go to login', 'Already have account, please login .');
    } finally {
      isLoading.value = false;
    }
  }
}
