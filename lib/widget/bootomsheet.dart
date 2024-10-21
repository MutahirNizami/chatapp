// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'package:chatapp/utilites/colors.dart';
import 'package:chatapp/widget/button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateGroupBottomSheet extends StatefulWidget {
  const CreateGroupBottomSheet({super.key});

  @override
  _CreateGroupBottomSheetState createState() => _CreateGroupBottomSheetState();
}

class _CreateGroupBottomSheetState extends State<CreateGroupBottomSheet> {
  List<String> selectedUserIds = [];
  final TextEditingController _groupNameController = TextEditingController();
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();

    selectedUserIds.add(currentUserId);
  }

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

                        // Exclude the current user from the list
                        if (user.id == currentUserId) {
                          return Container(); // Return empty container for the current user
                        }

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
                                selectedUserIds.remove(user.id);
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
                    ontap: _cancel,
                    text: "Cancel",
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
    if (_groupNameController.text.isEmpty || selectedUserIds.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a group name and select users.')),
      );
      return;
    }

    try {
      // Create the group in Firestore
      await FirebaseFirestore.instance.collection('groups').add({
        'groupName': _groupNameController.text,
        'memberIds': selectedUserIds,
        'creatorId': currentUserId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Navigate back to the dashboard
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

  // Cancel action
  _cancel() {
    Navigator.pop(context);
  }
}
