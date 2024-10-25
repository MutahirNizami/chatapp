import 'package:chatapp/calling/Audio_calling.dart';
import 'package:chatapp/calling/video_calling.dart';
import 'package:chatapp/controllers/chat_controller.dart';
import 'package:chatapp/utilites/colors.dart';
import 'package:chatapp/widget/button.dart';
import 'package:chatapp/widget/chatbubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatelessWidget {
  final QueryDocumentSnapshot<Object?> userModel;

  ChatScreen({super.key, required this.userModel});

  final ChatController chatController = Get.put(ChatController());

  String getChatID(String senderID, String receiverID) {
    return senderID.hashCode <= receiverID.hashCode
        ? '$senderID\_$receiverID'
        : '$receiverID\_$senderID';
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final chatId = getChatID(currentUserId, userModel['id']);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Mycolor().backcolor,
        body: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: width * 0.04, vertical: height * 0.04),
          child: Column(
            children: [
              // Chat Header
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Mycolor().titlecolor,
                    ),
                  ),
                  CircleAvatar(
                    backgroundImage: const AssetImage("assets/images/man.png"),
                    radius: height * 0.03,
                  ),
                  SizedBox(width: width * 0.03),
                  Text(
                    userModel['name'],
                    style: GoogleFonts.poppins(
                      fontSize: height * 0.025,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),

                  //calling.....................

                  IconButton(
                      onPressed: () => showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              contentPadding: const EdgeInsets.all(8),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Get.to(() => AudioCallingPage(
                                            callingId: getChatID(
                                                FirebaseAuth
                                                    .instance.currentUser!.uid,
                                                userModel['id']),
                                          ));
                                    },
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Audio call",
                                              style: TextStyle(
                                                  color: Mycolor()
                                                      .fcontainercolor)),
                                          Icon(
                                            Icons.call_outlined,
                                            color: Mycolor().fcontainercolor,
                                          )
                                        ])),
                                TextButton(
                                    onPressed: () {
                                      Get.to(() => VideoCalling(
                                            callID: getChatID(
                                                FirebaseAuth
                                                    .instance.currentUser!.uid,
                                                userModel['id']),
                                          ));
                                    },
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("video call",
                                              style: TextStyle(
                                                  color: Mycolor()
                                                      .fcontainercolor)),
                                          Icon(
                                            Icons.video_call,
                                            color: Mycolor().fcontainercolor,
                                          )
                                        ])),
                                Center(
                                  child: Appbutton(
                                      ontap: () {
                                        Get.back();
                                      },
                                      text: "Cancel",
                                      btnwidth: width * 0.2,
                                      btncolor: Mycolor().btncolor,
                                      borderSide: Border.all(
                                          color: Mycolor().btncolor)),
                                )
                              ],
                            ),
                          ),
                      icon: Icon(
                        Icons.add_call,
                        color: Mycolor().titlecolor,
                      )),
                ],
              ),

              // Messages List.............................
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chat')
                      .doc(chatId)
                      .collection("messages")
                      .orderBy("timeStamp", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final messagesList = snapshot.data!.docs;

                    return ListView.builder(
                      reverse: true,
                      itemCount: messagesList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final message = messagesList[index];
                        final isSentByMe = message["senderId"] == currentUserId;
                        return ChatBubble(
                          time: _formatTimestamp(message["timeStamp"]),
                          isSentByMe: isSentByMe,
                          message: message['message'],
                          imageurl: message['image'],
                        );
                      },
                    );
                  },
                ),
              ),

              // Text Input Area
              Container(
                margin: EdgeInsets.only(top: height * 0.03),
                decoration: BoxDecoration(
                  color: Mycolor().fcontainercolor,
                  borderRadius: BorderRadius.circular(height * 0.05),
                ),
                child: TextFormField(
                  controller: chatController.messageController,
                  decoration: InputDecoration(
                    prefix: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.015,
                      ),
                      child: InkWell(
                        onTap: () {
                          chatController.pickMedia(chatId);
                        },
                        child: CircleAvatar(
                          backgroundColor: Mycolor().iconcontainer,
                          radius: height * 0.025,
                          child: Icon(
                            Icons.camera_alt_outlined,
                            size: height * 0.03,
                          ),
                        ),
                      ),
                    ),
                    border: InputBorder.none,
                    hintText: 'Message..',
                    hintStyle: TextStyle(
                        color: Mycolor().nonfcontainercolor,
                        fontSize: height * 0.025),
                    suffixIcon: InkWell(
                      onTap: () => chatController.sendMessage(chatId),
                      child: Icon(
                        Icons.send_outlined,
                        color: Mycolor().iconcontainer,
                      ),
                    ),
                  ),
                  style: TextStyle(
                      color: Mycolor().titlecolor, fontSize: height * 0.032),
                  onFieldSubmitted: (value) {
                    chatController.sendMessage(chatId);
                    chatController.messageController.clear();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate().toLocal();
      return DateFormat('h:mm a').format(dateTime);
    } else if (timestamp is int) {
      DateTime dateTime =
          DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
      return DateFormat('h:mm a').format(dateTime);
    } else {
      return "loading..";
    }
  }
}
