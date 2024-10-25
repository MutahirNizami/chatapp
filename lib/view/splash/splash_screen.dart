import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:chatapp/router/wrapper.dart';
import 'package:chatapp/utilites/colors.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return AnimatedSplashScreen(
      nextScreen: const Wrapper(),
      splash: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flutter_dash,
            size: height * 0.2,
            color: Colors.white,
          ),
          SizedBox(height: height * 0.05),
          const Text(
            "Gup shup",
            style: TextStyle(
                fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      backgroundColor: Mycolor().btncolor,
      splashIconSize: 250,
      duration: 3000,
      centered: true,
      splashTransition: SplashTransition.rotationTransition,
      animationDuration: const Duration(seconds: 3),
    );
  }
}
