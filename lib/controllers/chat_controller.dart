// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:get/get.dart';

// import 'dart:developer';
// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_state_manager/src/simple/get_controllers.dart';
// import 'package:image_picker/image_picker.dart';

// class Homecontroller extends GetxController {
//   var users = <QueryDocumentSnapshot>[].obs;
//   var isLoading = true.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchUsers(); // Call fetchUsers on initialization
//   }

//   void fetchUsers() {
//     FirebaseFirestore.instance
//         .collection('users')
//         .where("id", isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
//         .snapshots()
//         .listen((snapshot) {
//       users.assignAll(snapshot.docs); // Update users list
//       isLoading.value = false; // Update loading state
//     });
//   }
// }

// class ChatController extends GetxController {
//   final TextEditingController messageController = TextEditingController();
//   final ImagePicker _picker = ImagePicker();
//   String imageUrl = '';

//   void pickMedia(String chatId) async {
//     final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

//     if (pickedFile == null) return;

//     String uniqueFilename = DateTime.now().millisecondsSinceEpoch.toString();
//     Reference referenceRoot = FirebaseStorage.instance.ref();
//     Reference referenceDirImages = referenceRoot.child('images');
//     Reference referenceImageToUpload = referenceDirImages.child(uniqueFilename);

//     try {
//       await referenceImageToUpload.putFile(File(pickedFile.path));
//       imageUrl = await referenceImageToUpload.getDownloadURL();
//       log('Image URL: $imageUrl');
//       _sendMessage(chatId, imageMessage: imageUrl);
//     } catch (error) {
//       log("Error uploading image: $error");
//     }
//   }

//   void _sendMessage(String chatId, {String? imageMessage}) async {
//     final text = messageController.text.trim();
//     final senderId = FirebaseAuth.instance.currentUser!.uid;

//     if (text.isNotEmpty || imageMessage != null) {
//       try {
//         await FirebaseFirestore.instance
//             .collection("chat")
//             .doc(chatId)
//             .collection("messages")
//             .add({
//           "message": text.isNotEmpty ? text : '',
//           "image": imageMessage ?? '',
//           "senderId": senderId,
//           "receiverId": chatId.split('_').first == senderId ? chatId.split('_').last : chatId.split('_').first,
//           "timeStamp": FieldValue.serverTimestamp(),
//         });

//         messageController.clear();
//         log("Message sent");
//       } catch (e) {
//         Get.defaultDialog(
//           title: 'Error',
//           content: Text('Failed to send message. Please try again.'),
//         );
//       }
//     }
//   }
// }

import 'dart:developer';
import 'dart:io';
import 'package:chatapp/auth/firebase_notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ChatController extends GetxController {
  final TextEditingController messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  var imageUrl = ''.obs;
  var isLoading = false.obs;

  String getChatID(String senderID, String receiverID) {
    return senderID.hashCode <= receiverID.hashCode
        ? '$senderID\_$receiverID'
        : '$receiverID\_$senderID';
  }

  Future<void> pickMedia(String chatId) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    String uniqueFilename = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('images');
    Reference referenceImageToUpload = referenceDirImages.child(uniqueFilename);

    try {
      isLoading.value = true;
      await referenceImageToUpload.putFile(File(pickedFile.path));
      imageUrl.value = await referenceImageToUpload.getDownloadURL();
      log('Image URL: $imageUrl');
      sendMessage(chatId, imageMessage: imageUrl.value);
    } catch (error) {
      log("Error uploading image: $error");
    } finally {
      isLoading.value = false;
    }
  }

  // void sendMessage(String chatId, {String? imageMessage}) async {
  //   final text = messageController.text.trim();

  //   if (text.isNotEmpty || imageMessage != null) {
  //     try {
  //       final senderId = FirebaseAuth.instance.currentUser!.uid;
  //       await FirebaseFirestore.instance
  //           .collection("chat")
  //           .doc(chatId)
  //           .collection("messages")
  //           .add({
  //         "message": text.isNotEmpty ? text : '',
  //         "image": imageMessage ?? '',
  //         "senderId": senderId,
  //         "receiverId": chatId.split('_')[1],
  //         "timeStamp": FieldValue.serverTimestamp(),
  //       });

  //       messageController.clear();
  //       log("Message sent");
  //     } catch (e) {
  //       Get.snackbar("Error", "Failed to send message. Please try again.");
  //     }
  //   }
  // }
  void sendMessage(String chatId, {String? imageMessage}) async {
    final text = messageController.text.trim();

    if (text.isNotEmpty || imageMessage != null) {
      try {
        final senderId = FirebaseAuth.instance.currentUser!.uid;
        final receiverId =
            chatId.split('_')[1]; // Assumes chatId structure is 'user1_user2'

        // Save message in Firestore
        await FirebaseFirestore.instance
            .collection("chat")
            .doc(chatId)
            .collection("messages")
            .add({
          "message": text.isNotEmpty ? text : '',
          "image": imageMessage ?? '',
          "senderId": senderId,
          "receiverId": receiverId,
          "timeStamp": FieldValue.serverTimestamp(),
        });

        messageController.clear();
        log("Message sent");

        // Trigger push notification
        await sendPushNotification(
            receiverId, text.isNotEmpty ? text : 'Image');
      } catch (e) {
        Get.snackbar("Error", "Failed to send message. Please try again.");
      }
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}
