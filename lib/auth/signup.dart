// // ignore_for_file: use_build_context_synchronously

// import 'dart:developer';
// import 'package:chatapp/auth/Login.dart';
// import 'package:chatapp/router/bottomnavigation.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:chatapp/utilites/colors.dart';

// // ignore: camel_case_types
// class signupScreen extends StatefulWidget {
//   const signupScreen({super.key});

//   @override
//   State<signupScreen> createState() => _signupScreenState();
// }

// // ignore: camel_case_types
// class _signupScreenState extends State<signupScreen> {
//   String email = '', name = '', password = '';
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _isPasswordVisible = false;
//   bool _isLoading = false;
//   final bool _haserror = false;

//   Future<void> _signup() async {
//     setState(() {
//       _isLoading = true;
//     });
//     if (_formKey.currentState!.validate()) {
//       email = _emailController.text.trim();
//       name = _nameController.text.trim();
//       password = _passwordController.text.trim();
//       try {
//         UserCredential userCredential = await FirebaseAuth.instance
//             .createUserWithEmailAndPassword(
//                 email: _emailController.text.trim(),
//                 password: _passwordController.text.trim());

//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(userCredential.user!.uid)
//             .set({
//           'id': userCredential.user!.uid,
//           'name': name,
//           'email': email,
//         });
// //navigat to dashboard ...............................
//         Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const DashboardScreen(),
//             ));

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Account created successfully!')),
//         );
//       } on FirebaseAuthException catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('U,have account plz login')),
//         );
//         log("firebase is not working $e");
//       } finally {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     double height = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: Mycolor().backcolor,
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: width * 0.08),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Center(
//                   child: Text(
//                     "Signup",
//                     style: GoogleFonts.poppins(
//                       fontSize: height * 0.045,
//                       fontWeight: FontWeight.w600,
//                       color: Mycolor().titlecolor,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: height * 0.02),
//                 TextFormField(
//                   controller: _nameController,
//                   decoration: InputDecoration(
//                     hintText: "Enter your name",
//                     prefixIcon:
//                         Icon(Icons.person, color: Mycolor().subtitlecolor),
//                     filled: true,
//                     fillColor: Mycolor().fcontainercolor,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(
//                           color: _haserror
//                               ? Mycolor().titlecolor
//                               : Mycolor().fcontainercolor),
//                     ),
//                   ),
//                   style: TextStyle(color: Mycolor().titlecolor),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your name';
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: height * 0.02),
//                 TextFormField(
//                   controller: _emailController,
//                   decoration: InputDecoration(
//                     hintText: "Enter your email",
//                     prefixIcon:
//                         Icon(Icons.email, color: Mycolor().subtitlecolor),
//                     filled: true,
//                     fillColor: Mycolor().fcontainercolor,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(
//                           color: _haserror
//                               ? Mycolor().titlecolor
//                               : Mycolor().fcontainercolor),
//                     ),
//                   ),
//                   style: TextStyle(color: Mycolor().titlecolor),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your email';
//                     } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
//                       return 'Please enter a valid email address';
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: height * 0.02),
//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: !_isPasswordVisible,
//                   decoration: InputDecoration(
//                     hintText: "Enter your password",
//                     prefixIcon:
//                         Icon(Icons.lock, color: Mycolor().subtitlecolor),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _isPasswordVisible
//                             ? Icons.visibility
//                             : Icons.visibility_off,
//                         color: Mycolor().subtitlecolor,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _isPasswordVisible = !_isPasswordVisible;
//                         });
//                       },
//                     ),
//                     filled: true,
//                     fillColor: Mycolor().fcontainercolor,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(
//                           color: _haserror
//                               ? Colors.transparent
//                               : Mycolor().fcontainercolor),
//                     ),
//                   ),
//                   style: TextStyle(color: Mycolor().titlecolor),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your password';
//                     } else if (value.length < 6) {
//                       return 'Password must be at least 6 characters';
//                     }
//                     return null;
//                   },
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(vertical: height * 0.02),
//                   child: SizedBox(
//                     width: width,
//                     height: height * 0.07,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Mycolor().btncolor,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(height * 0.02),
//                         ),
//                       ),
//                       onPressed: _isLoading
//                           ? null
//                           : () {
//                               if (_formKey.currentState!.validate()) {
//                                 _signup();
//                               }
//                             },
//                       child: _isLoading
//                           ? CircularProgressIndicator(
//                               color: Mycolor().titlecolor,
//                             )
//                           : Text(
//                               "Sign up",
//                               style: GoogleFonts.poppins(
//                                 fontSize: height * 0.022,
//                                 fontWeight: FontWeight.w600,
//                                 color: Mycolor().titlecolor,
//                               ),
//                             ),
//                     ),
//                   ),
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       "Already have an account?",
//                       style: GoogleFonts.poppins(
//                         fontSize: height * 0.018,
//                         color: Mycolor().subtitlecolor,
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => const LoginScreen(),
//                             ));
//                       },
//                       child: Text(
//                         "Login",
//                         style: GoogleFonts.poppins(
//                           fontSize: height * 0.018,
//                           color: Mycolor().btncolor,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:chatapp/auth/Login.dart';

import 'package:chatapp/utilites/colors.dart';
import 'package:chatapp/controllers/signup_controller.dart'; // Import your controller
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: camel_case_types
class signupScreen extends StatefulWidget {
  const signupScreen({super.key});

  @override
  State<signupScreen> createState() => _signupScreenState();
}

// ignore: camel_case_types
class _signupScreenState extends State<signupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  // Instantiate the SignupController
  final SignupController _signupController = Get.put(SignupController());

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
                    "Signup",
                    style: GoogleFonts.poppins(
                      fontSize: height * 0.045,
                      fontWeight: FontWeight.w600,
                      color: Mycolor().titlecolor,
                    ),
                  ),
                ),
                SizedBox(height: height * 0.02),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: "Enter your name",
                    prefixIcon:
                        Icon(Icons.person, color: Mycolor().subtitlecolor),
                    filled: true,
                    fillColor: Mycolor().fcontainercolor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: TextStyle(color: Mycolor().titlecolor),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: height * 0.02),
                TextFormField(
                  controller: _emailController,
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
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: "Enter your password",
                    prefixIcon:
                        Icon(Icons.lock, color: Mycolor().subtitlecolor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Mycolor().subtitlecolor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
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
                ),
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
                          onPressed: _signupController.isLoading.value
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    _signupController.signup(
                                      _emailController.text.trim(),
                                      _nameController.text.trim(),
                                      _passwordController.text.trim(),
                                    );
                                  }
                                },
                          child: _signupController.isLoading.value
                              ? CircularProgressIndicator(
                                  color: Mycolor().titlecolor,
                                )
                              : Text(
                                  "Sign up",
                                  style: GoogleFonts.poppins(
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
                      "Already have an account?",
                      style: GoogleFonts.poppins(
                        fontSize: height * 0.018,
                        color: Mycolor().subtitlecolor,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.to(() => LoginScreen());
                      },
                      child: Text(
                        "Login",
                        style: GoogleFonts.poppins(
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
