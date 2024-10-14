import 'package:chatapp/auth/signup.dart';
import 'package:chatapp/model/listmodel.dart';
import 'package:chatapp/utilites/colors.dart';
import 'package:chatapp/view/chatscreen.dart';
import 'package:chatapp/widget/bootomsheet.dart';
import 'package:chatapp/widget/button.dart';
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    iconSize: height * 0.03,
                    onPressed: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            actions: [
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const signupScreen(),
                                            ));
                                      },
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Create a new user"),
                                          Icon(Icons.add_circle_outline)
                                        ],
                                      )),
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
                                            const Text("Create a group"),
                                            Icon(
                                              Icons.add_circle_outline,
                                              color: Mycolor().fcontainercolor,
                                            )
                                          ])),
                                  Appbutton(
                                      ontap: () {
                                        Navigator.pop(context);
                                      },
                                      text: "Cancel",
                                      btnwidth: width * 0.2,
                                      btncolor: Mycolor().btncolor,
                                      borderSide: Border.all(
                                          color: Mycolor().btncolor)),
                                ],
                              )
                            ],
                          ),
                        ),
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: Mycolor().titlecolor,
                    )),
                Text(
                  "Messages",
                  style: GoogleFonts.poppins(
                      fontSize: height * 0.04,
                      fontWeight: FontWeight.w600,
                      color: Mycolor().titlecolor),
                ),
                Icon(
                  Icons.search,
                  size: height * 0.045,
                  color: Mycolor().titlecolor,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: width * 0.04, bottom: height * 0.02),
            child: Text("R e c e n t",
                style: GoogleFonts.poppins(
                    fontSize: height * 0.023,
                    fontWeight: FontWeight.w500,
                    color: Mycolor().titlecolor.withOpacity(0.58))),
          ),
          SizedBox(
            height: height * 0.16,
            width: width,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: height * 0.04,
                          child: const Image(
                            image: AssetImage("assets/images/man.png"),
                          ),
                        ),
                        SizedBox(
                          height: height * 0.007,
                        ),
                        Text(
                          "Men",
                          style: GoogleFonts.poppins(
                            fontSize: height * 0.02,
                            fontWeight: FontWeight.w500,
                            color: Mycolor().titlecolor,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
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
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
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
                                  child: Image.asset(chats[index].imageUrl),
                                ),
                                Expanded(
                                  child: Column(
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
                                        chats[index].message,
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
                                  chats[index].time,
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