import 'package:chatapp/utilites/calling.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class AudioCallingScreen extends StatefulWidget {
  const AudioCallingScreen({super.key});

  @override
  State<AudioCallingScreen> createState() => _AudioCallingScreenState();
}

class _AudioCallingScreenState extends State<AudioCallingScreen> {
  final callIdController = TextEditingController(text: '1');

  //  @override
  // void initState() {
  //   super.initState();
  //   initZego();
  // }

  // // Initialize ZEGOCLOUD for signaling................
  // void initZego() {
  //   ZegoUIKitPrebuiltCall.init(appID: Zegocall.appId, appSign: Zegocall.appSignin);
  //
  //   ZegoUIKitPrebuiltCall.instance.onIncomingCallReceived = (callID, inviter, extendedData) {
  //
  //     _showIncomingCallDialog(callID, inviter.userID);
  //   };
  // }

  // void _showIncomingCallDialog(String callID, String inviterID) {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text("Incoming Call"),
  //         content: Text("User $inviterID is calling you"),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: Text("Decline"),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (context) => AudioCallingPage(callingId: callID),
  //                 ),
  //               );
  //             },
  //             child: Text("Accept"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Calling'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              controller: callIdController,
              decoration: const InputDecoration(
                  hintText: 'Enter callign id', border: OutlineInputBorder()),
            ),
            const SizedBox(
              height: 20,
            ),
            TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AudioCallingPage(
                              callingId: callIdController.text.toString())));
                },
                child: const Text('Call'))
          ],
        ),
      ),
    );
  }
}

class AudioCallingPage extends StatefulWidget {
  final String callingId;
  const AudioCallingPage({super.key, required this.callingId});

  @override
  State<AudioCallingPage> createState() => _AudioCallingPageState();
}

class _AudioCallingPageState extends State<AudioCallingPage> {
  String? userId;
  String? userName;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    // Get the currently logged-in user's ID from FirebaseAuth.........
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final uid = currentUser.uid;

      // Fetch user data from Firestore using the user's ID......
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        setState(() {
          userId = uid;
          userName = userDoc['name'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userId == null || userName == null) {
      return const Scaffold(
        body: Center(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return SafeArea(
        child: ZegoUIKitPrebuiltCall(
            appID: Zegocall.appId,
            appSign: Zegocall.appSignin,
            userID: userId!,
            userName: userName!,
            callID: widget.callingId,
            config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),

            //call ended........................
            events: ZegoUIKitPrebuiltCallEvents(onCallEnd: (v, e) {
              Navigator.pop(context);
              Get.snackbar(userName!, "called ended");
            })
            // ..onOnlySelfInRoom = (context){
            //   Navigator.pop(context);
            // },
            ));
  }
}
