import 'dart:developer';

import 'package:chatapp/router/bottomnavigation.dart';
import 'package:chatapp/utilites/colors.dart';
import 'package:chatapp/widget/button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateGroupBottomSheet extends StatefulWidget {
  const CreateGroupBottomSheet({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CreateGroupBottomSheetState createState() => _CreateGroupBottomSheetState();
}

class _CreateGroupBottomSheetState extends State<CreateGroupBottomSheet> {
  List<String> selectedUserIds = [];
  final TextEditingController _groupNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Mycolor().backcolor,
        body: Padding(
          padding: EdgeInsets.symmetric(
              vertical: height * 0.03, horizontal: width * 0.03),
          child: Column(
            // mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    EdgeInsets.only(right: width * 0.07, left: width * 0.03),
                child: TextFormField(
                  controller: _groupNameController,
                  decoration: InputDecoration(
                    fillColor: Mycolor().nonfcontainercolor,
                    filled: true,
                    hintText: 'Group Name',
                    hintStyle: TextStyle(color: Mycolor().subtitlecolor),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(height * 0.02)),
                  ),
                  style: TextStyle(color: Mycolor().titlecolor),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final users = snapshot.data!.docs;
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        var user = users[index];
                        return CheckboxListTile(
                          checkColor: Mycolor().titlecolor,
                          activeColor: Mycolor().btncolor,
                          title: Text(
                            user['name'],
                            style: TextStyle(color: Mycolor().titlecolor),
                          ),
                          value: selectedUserIds.contains(user.id),
                          onChanged: (isSelected) {
                            setState(() {
                              if (isSelected!) {
                                selectedUserIds.add(user.id);
                              } else {
                                log("add user into group");
                              }
                            });
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Appbutton(
                    ontap: _cancle,
                    text: "cancle",
                    btnwidth: width * 0.3,
                    fontSize: height * 0.02,
                    borderradius: height * 0.2,
                    btncolor: Mycolor().nonfcontainercolor,
                  ),
                  Appbutton(
                    ontap: _createGroup,
                    text: "Create Group",
                    fontSize: height * 0.018,
                    btncolor: Mycolor().btncolor,
                    btnheight: height * 0.05,
                    btnwidth: width * 0.3,
                    borderradius: height * 0.2,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // Function to create a group in Firestore
  Future<void> _createGroup() async {
    if (_groupNameController.text.isEmpty || selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a group name and select users.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('groups').add({
        'groupName': _groupNameController.text,
        'memberIds': selectedUserIds,
        'creatorId': FirebaseAuth.instance.currentUser!.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group created successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to create group. Please try again.')),
      );
    }
  }

  // cancle ......................
  _cancle() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardScreen(),
        ));
  }
}
