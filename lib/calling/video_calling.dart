import 'package:chatapp/utilites/calling.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class VideoCalling extends StatefulWidget {
  const VideoCalling({super.key, required String callID});

  @override
  State<VideoCalling> createState() => _VideoCallingState();
}

// final String localUserID = math.Random().nextInt(10000).toString();

class _VideoCallingState extends State<VideoCalling> {
  final callIDTextCtrl = TextEditingController(text: "call_id");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextFormField(
                  controller: callIDTextCtrl,
                  decoration:
                      const InputDecoration(labelText: "join a call by id"),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return CallPage(callID: callIDTextCtrl.text);
                    }),
                  );
                },
                child: const Text("join"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CallPage extends StatefulWidget {
  final String callID;

  const CallPage({
    super.key,
    required this.callID,
  });

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  String? userId;
  String? userName;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    // Get the currently logged-in user's ID from FirebaseAuth........
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final uid = currentUser.uid;

      // Fetch user data from Firestore using the user's ID........
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
      // Show loading indicator while fetching user data
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userId == null || userName == null) {
      return Scaffold(
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
          callID: widget.callID,
          config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()

          // ZegoUIKitPrebuiltCallConfig.groupVideoCall()
          //   ..onOnlySelfInRoom = (context) {
          //     Navigator.of(context).pop();
          //   },
          ),
    );
  }
}
