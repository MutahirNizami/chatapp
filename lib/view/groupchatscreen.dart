import 'dart:developer';
import 'dart:io';
import 'package:chatapp/utilites/colors.dart';
import 'package:chatapp/widget/chatbubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class Goupchatscreen extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> groupModel;
  final QueryDocumentSnapshot<Object?>? userModel;

  const Goupchatscreen({
    super.key,
    required this.groupModel,
    this.userModel,
  });

  @override
  State<Goupchatscreen> createState() => _GoupchatscreenState();
}

class _GoupchatscreenState extends State<Goupchatscreen> {
  final TextEditingController _controller = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  String imageurl = '';
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> pickMedia(String chatId) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    String uniquefilename = DateTime.now().millisecondsSinceEpoch.toString();

    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirimages = referenceRoot.child('images');
    //create refrence for the store data............

    Reference referenceimagetoupload = referenceDirimages.child(uniquefilename);

    try {
      await referenceimagetoupload.putFile(File(pickedFile.path));
      imageurl = await referenceimagetoupload.getDownloadURL();
      print('$imageurl');
      _sendMessage(chatId, imageMessage: imageurl);
    } catch (error) {
      log("error got ");
    }
    // setState(() {
    //   _selectedmedia = File(pickedFile.path); // Store the selected file
    // });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    final chatId = widget.groupModel["groupName"];
    print("chat is is ${chatId}");

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
                      Navigator.pop(context);
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
                    widget.groupModel['groupName'],
                    style: GoogleFonts.poppins(
                      fontSize: height * 0.025,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.search,
                    size: height * 0.045,
                    color: Mycolor().titlecolor,
                  ),
                ],
              ),

              // Messages List
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('groupchat')
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
                    // list of messages get from firebase............
                    final messagesList = snapshot.data!.docs;
                    // final Sendername = widget.userModel;
                    return ListView.builder(
                      reverse: true,
                      itemCount: messagesList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final message = messagesList[index];
                        print(message.data());
                        final isSentByMe = message["senderId"] == currentUserId;
                        return ChatBubble(
                          // senderName: Sendername,
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
              // Expanded(
              //   child: StreamBuilder<QuerySnapshot>(
              //     stream: FirebaseFirestore.instance
              //         .collection('groupchat')
              //         .doc(chatId)
              //         .collection("messages")
              //         .orderBy("timeStamp", descending: true)
              //         .snapshots(),
              //     builder: (context, snapshot) {
              //       if (snapshot.hasError) {
              //         return Center(
              //           child: Text('Error: ${snapshot.error}'),
              //         );
              //       }

              //       if (!snapshot.hasData) {
              //         return const Center(
              //           child: CircularProgressIndicator(),
              //         );
              //       }

              //       final messagesList = snapshot.data!.docs;

              //       return ListView.builder(
              //         reverse: true,
              //         itemCount: messagesList.length,
              //         itemBuilder: (BuildContext context, int index) {
              //           final message = messagesList[index];
              //           final isSentByMe = message["senderId"] == currentUserId;

              //           return Column(
              //             crossAxisAlignment: isSentByMe
              //                 ? CrossAxisAlignment.end
              //                 : CrossAxisAlignment.start,
              //             children: [
              //               // Display sender name for other users (not for self)
              //               if (!isSentByMe)
              //                 Padding(
              //                   padding:
              //                       EdgeInsets.only(left: 8.0, bottom: 4.0),
              //                   child: Text(
              //                     message['senderName'] ?? 'Unknown',
              //                     style: TextStyle(
              //                       color: Colors.white,
              //                       fontSize: 14,
              //                       fontWeight: FontWeight.bold,
              //                     ),
              //                   ),
              //                 ),
              //               ChatBubble(
              //                 time: _formatTimestamp(message["timeStamp"]),
              //                 senderName: widget.userModel![index]["name "],
              //                 isSentByMe: isSentByMe,
              //                 message: message['message'],
              //                 imageurl: message['image'],
              //               ),
              //             ],
              //           );
              //         },
              //       );
              //     },
              //   ),
              // ),

              // Text Input Area

              Container(
                margin: EdgeInsets.only(top: height * 0.03),
                decoration: BoxDecoration(
                  color: Mycolor().fcontainercolor,
                  borderRadius: BorderRadius.circular(height * 0.05),
                ),
                child: TextFormField(
                  controller: _controller,
                  decoration: InputDecoration(
                    prefix: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.015,
                      ),
                      child: InkWell(
                        onTap: () {
                          pickMedia(chatId);
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
                      onTap: () => _sendMessage(chatId),
                      child: Icon(
                        Icons.send_outlined,
                        color: Mycolor().iconcontainer,
                      ),
                    ),
                  ),
                  style: TextStyle(color: Mycolor().titlecolor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

//date and time....................................
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

  // Function to send a message.............................
  void _sendMessage(String chatId, {String? imageMessage}) async {
    final text = _controller.text.trim();

    if (text.isNotEmpty || imageMessage != null) {
      try {
        final senderId = FirebaseAuth.instance.currentUser!.uid;
        // final senderDoc = await FirebaseFirestore.instance
        //     .collection('users')
        //     .doc(senderId)
        //     .get();

        // String senderName = senderDoc['name'] ?? 'Unknown';
        await FirebaseFirestore.instance
            .collection("groupchat")
            .doc(chatId)
            .collection("messages")
            .add({
          "message": text.isNotEmpty ? text : '',
          "image": imageMessage ?? '',
          "senderId": senderId,
          // "senderName": senderName,
          "timeStamp": FieldValue.serverTimestamp(),
        });

        _controller.clear();
        log("Message sent");
      } catch (e) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Failed to send message. Please try again.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }
}
