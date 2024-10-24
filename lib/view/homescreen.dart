import 'package:chatapp/utilites/colors.dart';
import 'package:chatapp/view/chatscreen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
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
                vertical: height * 0.015, horizontal: width * 0.04),
            child: Row(
              children: [
                Text(
                  "Messages",
                  style: GoogleFonts.poppins(
                      fontSize: height * 0.04,
                      fontWeight: FontWeight.w600,
                      color: Mycolor().titlecolor),
                ),
                const Spacer(),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: width * 0.04, bottom: height * 0.02),
            child: Text("All Users",
                style: GoogleFonts.poppins(
                    fontSize: height * 0.023,
                    fontWeight: FontWeight.w500,
                    color: Mycolor().titlecolor.withOpacity(0.58))),
          ),
          SizedBox(
            height: height * 0.14,
            width: width,
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where("id",
                        isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: width * 0.04),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: height * 0.035,
                                backgroundColor: Mycolor().subtitlecolor,
                                // child: const Icon(Icons.person),
                                child: const Image(
                                  image: AssetImage("assets/images/man.png"),
                                ),
                              ),
                              SizedBox(
                                height: height * 0.007,
                              ),
                              Text(
                                snapshot.data!.docs[index]["name"],
                                style: GoogleFonts.poppins(
                                  fontSize: height * 0.02,
                                  fontWeight: FontWeight.w500,
                                  color: Mycolor().titlecolor,
                                ),
                              ),
                            ],
                          ),
                        );
                      });
                }),
          ),

          //list of users.....................................

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(height * 0.065),
                  topRight: Radius.circular(height * 0.065),
                ),
                color: Mycolor().fcontainercolor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding:
                        EdgeInsets.only(left: width * 0.07, top: height * 0.03),
                    child: Text(
                      "My chats",
                      style: GoogleFonts.poppins(
                        fontSize: height * 0.025,
                        color: Mycolor().titlecolor,
                      ),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .where("id",
                              isNotEqualTo:
                                  FirebaseAuth.instance.currentUser!.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          padding: EdgeInsets.only(
                            top: height * 0.01,
                            bottom: height * 0.01,
                          ),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: height * 0.015,
                                horizontal: width * 0.03,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        userModel: snapshot.data!.docs[index],
                                      ),
                                    ),
                                  );
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: width * 0.03),
                                      child: CircleAvatar(
                                        radius: height * 0.035,
                                        child: const Image(
                                          image: AssetImage(
                                              "assets/images/man.png"),
                                        ),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          snapshot.data!.docs[index]["name"],
                                          style: GoogleFonts.poppins(
                                            fontSize: height * 0.018,
                                            fontWeight: FontWeight.w600,
                                            color: Mycolor().titlecolor,
                                          ),
                                        ),
                                        SizedBox(height: height * 0.005),
                                        Text(
                                          "last message............",
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
                                    const Spacer(),
                                    Text(
                                      "time....",
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
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    ));
  }
}
