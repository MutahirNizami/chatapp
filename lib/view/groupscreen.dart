import 'package:chatapp/model/listmodel.dart';
import 'package:chatapp/utilites/colors.dart';
import 'package:chatapp/view/chatscreen.dart';
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
                vertical: height * 0.015, horizontal: width * 0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Groups",
                  style: GoogleFonts.poppins(
                      fontSize: height * 0.035,
                      fontWeight: FontWeight.w600,
                      color: Mycolor().titlecolor),
                ),
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.search,
                      size: height * 0.03,
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
                          arrayContains: FirebaseAuth.instance.currentUser!
                              .uid) // Query groups where the current user is a member
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
                      return const Center(
                        child: Text('No groups found.'),
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
                                  builder: (context) => ChatScreen(
                                    userModel: snapshot.data!.docs[index],
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
                                  child: Image.asset(chats[index]
                                      .imageUrl), // Modify this to fetch an appropriate image for the group
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
                                        'Last message...', // Placeholder, modify to show the last message if you have that data
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
                                  chats[index]
                                      .time, // Placeholder for the time, modify if you have timestamp info
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
