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

class ChatScreen extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> userModel;

  const ChatScreen({
    super.key,
    required this.userModel,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String imageurl = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String getChatID(String senderID, String receiverID) {
    return senderID.hashCode <= receiverID.hashCode
        ? '$senderID\_$receiverID'
        : '$receiverID\_$senderID';
  }

  Future<void> pickMedia(String chatId) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    String uniquefilename = DateTime.now().millisecondsSinceEpoch.toString();

    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirimages = referenceRoot.child('images');
    //create refrence for the store data...............

    Reference referenceimagetoupload = referenceDirimages.child(uniquefilename);

    try {
      await referenceimagetoupload.putFile(File(pickedFile.path));
      imageurl = await referenceimagetoupload.getDownloadURL();
      log('Image URL: $imageurl');
      _sendMessage(chatId, imageMessage: imageurl);
    } catch (error) {
      log("Error uploading image: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    //save the user id from firebaseauth.....................
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    //id of user...................
    final chatId = getChatID(currentUserId, widget.userModel['id']);

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
                    widget.userModel['name'],
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

              // Messages List............................
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

                    // list of messages get from firebase......................
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
                          // senderName: message['senderName'],
                        );
                      },
                    );
                  },
                ),
              ),

              // Text Input Area..............................
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

  // Date and time formate...........................
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

  // Function to send a message..........................
  void _sendMessage(String chatId, {String? imageMessage}) async {
    final text = _controller.text.trim();

    if (text.isNotEmpty || imageMessage != null) {
      try {
        final senderId = FirebaseAuth.instance.currentUser!.uid;
        // final senderName = FirebaseAuth.instance.currentUser!.displayName;
        await FirebaseFirestore.instance
            .collection("chat")
            .doc(chatId)
            .collection("messages")
            .add({
          "message": text.isNotEmpty ? text : '',
          "image": imageMessage ?? '',
          "senderId": senderId,
          // "senderName": senderName,
          "receiverId": widget.userModel["id"],
          "timeStamp": FieldValue.serverTimestamp(),
        });

        _controller.clear();
        log("Message sent");
      } catch (e) {
        showDialog(
          // ignore: use_build_context_synchronously
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

  // for display sendername............

  // Future<void> getusername() async {
  //   // final senderName = FirebaseFirestore.instance.collection('users').where('id',isEqualTo:FirebaseAuth.instance.currentUser!.uid ).get();

  //   final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  //   var userSnapshot = await FirebaseFirestore.instance
  //       .collection('users')
  //       .where('id', isEqualTo: currentUserId)
  //       .get();
  //   if (userSnapshot.docs.isNotEmpty) {
  //     var senderName = userSnapshot.docs.first.data();

  //     // _sendMessage(senderName);
  //   } else {
  //     print('No user found with this ID.');
  //   }
  // }
}
