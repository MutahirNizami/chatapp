import 'package:chatapp/utilites/colors.dart';
import 'package:flutter/material.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Mycolor().backcolor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: CircleAvatar(
              backgroundColor: Mycolor().nonfcontainercolor,
              radius: 50,
            ),
          ),
        ],
      ),
    );
  }
}
