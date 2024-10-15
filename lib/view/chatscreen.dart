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
    // final chatId = getChatID(currentUserId, widget.userModel["id"]);
    final chatId = getChatID(currentUserId, widget.userModel["creatorId"]);

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
                    // widget.userModel['name'],
                    widget.userModel['groupName'],
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
                    // list of messages get from firebase............
                    final messagesList = snapshot.data!.docs;

                    return ListView.builder(
                      reverse: true,
                      itemCount: messagesList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final message = messagesList[index];
                        print(message.data());
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

    if (text.isNotEmpty) {
      try {
        final senderId = FirebaseAuth.instance.currentUser!.uid;
        await FirebaseFirestore.instance
            .collection("chat")
            .doc(chatId)
            .collection("messages")
            .add({
          "message": text.isNotEmpty ? text : '',
          "image": imageMessage ?? '',
          "senderId": senderId,
          // "receiverId": widget.userModel["id"],
          "receiverId": widget.userModel["creatorId"],
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
// import 'dart:developer';
// import 'dart:io';
// import 'package:chatapp/utilites/colors.dart';
// import 'package:chatapp/widget/chatbubble.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';

// class ChatScreen extends StatefulWidget {
//   final QueryDocumentSnapshot<Object?> userModel;

//   const ChatScreen({
//     super.key,
//     required this.userModel,
//   });

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final ImagePicker _picker = ImagePicker();
//   String imageurl = '';

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   String getChatID(String senderID, String receiverID) {
//     return senderID.hashCode <= receiverID.hashCode
//         ? '$senderID\_$receiverID'
//         : '$receiverID\_$senderID';
//   }

//   Future<void> pickMedia(String chatId) async {
//     final XFile? pickedFile =
//         await _picker.pickImage(source: ImageSource.gallery);

//     if (pickedFile == null) return;

//     String uniquefilename = DateTime.now().millisecondsSinceEpoch.toString();

//     Reference referenceRoot = FirebaseStorage.instance.ref();
//     Reference referenceDirimages = referenceRoot.child('images');
//     //create refrence for the store data...............

//     Reference referenceimagetoupload = referenceDirimages.child(uniquefilename);

//     try {
//       await referenceimagetoupload.putFile(File(pickedFile.path));
//       imageurl = await referenceimagetoupload.getDownloadURL();
//       log('Image URL: $imageurl');
//       _sendMessage(chatId, imageMessage: imageurl);
//     } catch (error) {
//       log("Error uploading image: $error");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     double height = MediaQuery.of(context).size.height;

//     final currentUserId = FirebaseAuth.instance.currentUser!.uid;

//     // Fetch userModel data and cast it as a Map<String, dynamic>
//     final data = widget.userModel.data() as Map<String, dynamic>;

//     // Check if 'creatorId' exists to differentiate between group and one-to-one chats
//     final chatId = data.containsKey('creatorId')
//         ? getChatID(currentUserId, widget.userModel['creatorId']) // Group Chat
//         : getChatID(currentUserId, widget.userModel['id']); // One-to-One Chat

//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Mycolor().backcolor,
//         body: Padding(
//           padding: EdgeInsets.symmetric(
//               horizontal: width * 0.04, vertical: height * 0.04),
//           child: Column(
//             children: [
//               // Chat Header
//               Row(
//                 children: [
//                   InkWell(
//                     onTap: () {
//                       Navigator.pop(context);
//                     },
//                     child: Icon(
//                       Icons.arrow_back_ios,
//                       color: Mycolor().titlecolor,
//                     ),
//                   ),
//                   CircleAvatar(
//                     backgroundImage: const AssetImage("assets/images/man.png"),
//                     radius: height * 0.03,
//                   ),
//                   SizedBox(width: width * 0.03),
//                   Text(
//                     data.containsKey('creatorId')
//                         ? widget
//                             .userModel['groupName'] // Group Name for group chat
//                         : widget
//                             .userModel['name'], // User Name for one-to-one chat
//                     style: GoogleFonts.poppins(
//                       fontSize: height * 0.025,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const Spacer(),
//                   Icon(
//                     Icons.search,
//                     size: height * 0.045,
//                     color: Mycolor().titlecolor,
//                   ),
//                 ],
//               ),

//               // Messages List
//               Expanded(
//                 child: StreamBuilder<QuerySnapshot>(
//                   stream: FirebaseFirestore.instance
//                       .collection('chat')
//                       .doc(chatId)
//                       .collection("messages")
//                       .orderBy("timeStamp", descending: true)
//                       .snapshots(),
//                   builder: (context, snapshot) {
//                     if (snapshot.hasError) {
//                       return Center(
//                         child: Text('Error: ${snapshot.error}'),
//                       );
//                     }

//                     if (!snapshot.hasData) {
//                       return const Center(
//                         child: CircularProgressIndicator(),
//                       );
//                     }

//                     // list of messages get from firebase
//                     final messagesList = snapshot.data!.docs;

//                     return ListView.builder(
//                       reverse: true,
//                       itemCount: messagesList.length,
//                       itemBuilder: (BuildContext context, int index) {
//                         final message = messagesList[index];
//                         final isSentByMe = message["senderId"] == currentUserId;
//                         return ChatBubble(
//                           time: _formatTimestamp(message["timeStamp"]),
//                           isSentByMe: isSentByMe,
//                           message: message['message'],
//                           imageurl: message['image'],
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),

//               // Text Input Area
//               Container(
//                 margin: EdgeInsets.only(top: height * 0.03),
//                 decoration: BoxDecoration(
//                   color: Mycolor().fcontainercolor,
//                   borderRadius: BorderRadius.circular(height * 0.05),
//                 ),
//                 child: TextFormField(
//                   controller: _controller,
//                   decoration: InputDecoration(
//                     prefix: Padding(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: width * 0.015,
//                       ),
//                       child: InkWell(
//                         onTap: () {
//                           pickMedia(chatId);
//                         },
//                         child: CircleAvatar(
//                           backgroundColor: Mycolor().iconcontainer,
//                           radius: height * 0.025,
//                           child: Icon(
//                             Icons.camera_alt_outlined,
//                             size: height * 0.03,
//                           ),
//                         ),
//                       ),
//                     ),
//                     border: InputBorder.none,
//                     hintText: 'Message..',
//                     hintStyle: TextStyle(
//                         color: Mycolor().nonfcontainercolor,
//                         fontSize: height * 0.025),
//                     suffixIcon: InkWell(
//                       onTap: () => _sendMessage(chatId),
//                       child: Icon(
//                         Icons.send_outlined,
//                         color: Mycolor().iconcontainer,
//                       ),
//                     ),
//                   ),
//                   style: TextStyle(color: Mycolor().titlecolor),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Date and time formatting
//   String _formatTimestamp(dynamic timestamp) {
//     if (timestamp is Timestamp) {
//       DateTime dateTime = timestamp.toDate().toLocal();
//       return DateFormat('h:mm a').format(dateTime);
//     } else if (timestamp is int) {
//       DateTime dateTime =
//           DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
//       return DateFormat('h:mm a').format(dateTime);
//     } else {
//       return "loading..";
//     }
//   }

//   // Function to send a message..........................
//   void _sendMessage(String chatId, {String? imageMessage}) async {
//     final text = _controller.text.trim();

//     if (text.isNotEmpty || imageMessage != null) {
//       try {
//         final senderId = FirebaseAuth.instance.currentUser!.uid;

//         final data = widget.userModel.data() as Map<String, dynamic>;

//         final bool isGroupChat = data.containsKey('creatorId');

//         List<String> receiverIds = [];

//         // Group chat handling
//         if (isGroupChat) {
//           // Fetch the list of members in the group and exclude the sender
//           if (data.containsKey('members')) {
//             receiverIds = List<String>.from(data['members'])
//                 .where((memberId) => memberId != senderId)
//                 .toList();
//           } else {
//             log('Group does not have members field');
//             return;
//           }

//           if (receiverIds.isEmpty) {
//             log('No other members in the group besides the sender.');
//             return;
//           }
//         }

//         // Create the message map to be added to Firestore
//         Map<String, dynamic> messageData = {
//           "message": text.isNotEmpty ? text : '',
//           "image": imageMessage ?? '',
//           "senderId": senderId,
//           "timeStamp": FieldValue.serverTimestamp(),
//         };

//         // Save the message for the sender
//         await FirebaseFirestore.instance
//             .collection("chat")
//             .doc(chatId)
//             .collection("messages")
//             .add(messageData);

//         // For group chat, send the message to each member (except the sender)
//         if (isGroupChat) {
//           for (String receiverId in receiverIds) {
//             Map<String, dynamic> groupMessageData = {
//               "message": text.isNotEmpty ? text : '',
//               "image": imageMessage ?? '',
//               "senderId": senderId,
//               "receiverId": receiverId,
//               "timeStamp": FieldValue.serverTimestamp(),
//             };

//             await FirebaseFirestore.instance
//                 .collection("chat")
//                 .doc(chatId)
//                 .collection("messages")
//                 .add(groupMessageData);
//           }
//         }

//         _controller.clear(); // Clear the input field
//         log("Message sent to ${isGroupChat ? 'group' : 'user'}");
//       } catch (e) {
//         log("Failed to send message: $e");
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: const Text('Error'),
//               content: const Text('Failed to send message. Please try again.'),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('OK'),
//                 ),
//               ],
//             );
//           },
//         );
//       }
//     } else {
//       log("Message is empty or media not selected.");
//     }
//   }
// }
