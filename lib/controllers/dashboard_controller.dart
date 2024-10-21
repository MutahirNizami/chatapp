import 'package:chatapp/view/groupscreen.dart';
import 'package:chatapp/view/homescreen.dart';
import 'package:chatapp/view/profilescreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  // Observable for selected index
  var selectedIndex = 0.obs;

  // Pages list
  final List<Widget> pages = [
    const Homescreen(),
    const Groupscreen(),
    ProfileScreen(),
  ];

  // Method to update selected index
  void onItemTapped(int index) {
    selectedIndex.value = index;
  }
}
