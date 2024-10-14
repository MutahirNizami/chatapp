import 'dart:developer';

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
  TextEditingController groupNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, top: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: groupNameController,
                decoration: const InputDecoration(
                  labelText: 'Group Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
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
                        title: Text(user['name']),
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
            Appbutton(
              ontap: _createGroup,
              text: "Create Group",
              fontSize: height * 0.02,
              btncolor: Mycolor().btncolor,
              btnheight: height * 0.05,
              btnwidth: width * 0.5,
              borderradius: height * 0.2,
            ),
          ],
        ),
      ),
    );
  }

  // Function to create a group in Firestore
  Future<void> _createGroup() async {
    if (groupNameController.text.isEmpty || selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a group name and select users.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('groups').add({
        'groupName': groupNameController.text,
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
}
