import 'package:chatapp/router/bottomnavigation.dart';
import 'package:chatapp/utilites/colors.dart';
import 'package:chatapp/view/groupchatscreen.dart';
import 'package:chatapp/widget/bootomsheet.dart';
import 'package:chatapp/widget/button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Groupscreen extends StatefulWidget {
  const Groupscreen({super.key});

  @override
  State<Groupscreen> createState() => _GroupscreenState();
}

class _GroupscreenState extends State<Groupscreen> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
        child: Scaffold(
      backgroundColor: Mycolor().backcolor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: height * 0.015, horizontal: width * 0.01),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DashboardScreen(),
                          ));
                    },
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: height * 0.03,
                      color: Mycolor().titlecolor,
                    )),
                Text(
                  "My Groups",
                  style: GoogleFonts.poppins(
                      fontSize: height * 0.032,
                      fontWeight: FontWeight.w600,
                      color: Mycolor().titlecolor),
                ),
                const Spacer(),

                // for alerat dialog..................................
                IconButton(
                    iconSize: height * 0.03,
                    onPressed: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            contentPadding: EdgeInsets.all(8),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const CreateGroupBottomSheet()));
                                  },
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Create a group",
                                            style: TextStyle(
                                                color:
                                                    Mycolor().fcontainercolor)),
                                        Icon(
                                          Icons.add_circle_outline,
                                          color: Mycolor().fcontainercolor,
                                        )
                                      ])),
                              Center(
                                child: Appbutton(
                                    ontap: () {
                                      Navigator.pop(context);
                                    },
                                    text: "Cancel",
                                    btnwidth: width * 0.2,
                                    btncolor: Mycolor().btncolor,
                                    borderSide:
                                        Border.all(color: Mycolor().btncolor)),
                              )
                            ],
                          ),
                        ),
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: Mycolor().titlecolor,
                    )),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(top: height * 0.04),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(height * 0.065),
                      topRight: Radius.circular(height * 0.065)),
                  color: Mycolor().fcontainercolor),
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('groups')
                      .where("memberIds",
                          arrayContains: FirebaseAuth.instance.currentUser!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Error fetching groups.'),
                      );
                    } else if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          'create group with users ... ',
                          style: GoogleFonts.poppins(
                              fontSize: height * 0.02,
                              color: Mycolor().titlecolor),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var group = snapshot.data!.docs[index];
                        // String groupId = group.id;
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Goupchatscreen(
                                    groupModel: snapshot.data!.docs[index],
                                  ),
                                ));
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                                right: width * 0.05,
                                top: height * 0.01,
                                bottom: height * 0.02,
                                left: width * 0.02),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  height: height * 0.07,
                                  width: width * 0.2,
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Mycolor().subtitlecolor,
                                        blurRadius: height * 0.003,
                                      ),
                                    ],
                                    shape: BoxShape.circle,
                                    color: Mycolor().subtitlecolor,
                                  ),
                                  // child: const Icon(Icons.person),
                                  child: Image(
                                      image:
                                          AssetImage("assets/images/man.png")),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        group["groupName"],
                                        style: GoogleFonts.poppins(
                                          fontSize: height * 0.018,
                                          fontWeight: FontWeight.w600,
                                          color: Mycolor().titlecolor,
                                        ),
                                      ),
                                      SizedBox(height: height * 0.005),
                                      Text(
                                        'Last message...',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: height * 0.02,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'Time...',
                                  style: GoogleFonts.poppins(
                                    fontSize: height * 0.015,
                                    color: Mycolor().subtitlecolor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
            ),
          )
        ],
      ),
    ));
  }
}
