import 'package:chatapp/utilites/colors.dart';

import 'package:chatapp/view/groupscreen.dart';
import 'package:chatapp/view/homescreen.dart';
import 'package:chatapp/view/profilescreen.dart';

import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;

  List<Widget> get _pages => [
        const Homescreen(),
        const Groupscreen(),
        const ProfileScreen(),
      ];

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: _pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Mycolor().nonfcontainercolor,
        selectedFontSize: height * 0.015,
        elevation: height * 0.02,
        items: [
          BottomNavigationBarItem(
            icon: selectedIndex == 0
                ? const Icon(Icons.home_rounded)
                : const Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: selectedIndex == 1
                ? const Icon(Icons.group)
                : const Icon(Icons.group_outlined),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            icon: selectedIndex == 2
                ? const Icon(Icons.person)
                : const Icon(Icons.person_2_outlined),
            label: 'Profile',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Mycolor().btncolor,
        unselectedItemColor: Mycolor().titlecolor,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
