import 'package:chatapp/controllers/authcontroller/login_controller.dart';

import 'package:flutter/material.dart';
import 'package:chatapp/auth/Signup.dart';

import 'package:chatapp/utilites/colors.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final LoginController loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Mycolor().backcolor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.08),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Login",
                    style: TextStyle(
                      fontSize: height * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Mycolor().titlecolor,
                    ),
                  ),
                ),
                SizedBox(height: height * 0.04),
                TextFormField(
                  controller: loginController.emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Enter your email",
                    prefixIcon:
                        Icon(Icons.email, color: Mycolor().subtitlecolor),
                    filled: true,
                    fillColor: Mycolor().fcontainercolor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: TextStyle(color: Mycolor().titlecolor),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: height * 0.02),
                Obx(() => TextFormField(
                      controller: loginController.passwordController,
                      obscureText: !loginController.isPasswordVisible.value,
                      decoration: InputDecoration(
                        hintText: "Enter your password",
                        prefixIcon:
                            Icon(Icons.lock, color: Mycolor().subtitlecolor),
                        suffixIcon: IconButton(
                          icon: Icon(
                            loginController.isPasswordVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Mycolor().subtitlecolor,
                          ),
                          onPressed: () =>
                              loginController.togglePasswordVisibility(),
                        ),
                        filled: true,
                        fillColor: Mycolor().fcontainercolor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      style: TextStyle(color: Mycolor().titlecolor),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        } else if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    )),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: height * 0.02),
                  child: SizedBox(
                    width: width,
                    height: height * 0.07,
                    child: Obx(() => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Mycolor().btncolor,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(height * 0.02),
                            ),
                          ),
                          onPressed: loginController.isLoading.value
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    loginController.loginWithEmailAndPassword();
                                  }
                                },
                          child: loginController.isLoading.value
                              ? CircularProgressIndicator(
                                  color: Mycolor().titlecolor,
                                )
                              : Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: height * 0.022,
                                    fontWeight: FontWeight.w600,
                                    color: Mycolor().titlecolor,
                                  ),
                                ),
                        )),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(
                        fontSize: height * 0.018,
                        color: Mycolor().subtitlecolor,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.to(() => const signupScreen());
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: height * 0.018,
                          color: Mycolor().btncolor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
