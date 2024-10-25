import 'package:chatapp/utilites/calling.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class GroupCallScreen extends StatelessWidget {
  GroupCallScreen({super.key});

  final callingId = TextEditingController(text: 'group_call_id');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Row(
            children: [
              Expanded(
                  child: TextFormField(
                controller: callingId,
                decoration: InputDecoration(labelText: 'Join group call by id'),
              )),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return CallPage(callingId: callingId.text.toString());
                    }));
                  },
                  child: Text('Join'))
            ],
          ),
        ),
      ),
    );
  }
}

class CallPage extends StatefulWidget {
  final String callingId;
  const CallPage({Key? key, required this.callingId}) : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  String? userId;
  String? userName;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    // Get the currently logged-in user's ID from FirebaseAuth
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final uid = currentUser.uid;

      // Fetch user data from Firestore using the user's ID
      final userDoc = await FirebaseFirestore.instance
          .collection('users') // Adjust your collection name if different
          .doc(uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userId = uid;
          userName = userDoc['name']; // Ensure 'name' field exists in Firestore
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null || userName == null) {
      return Scaffold(
        body: Center(
            child:
                CircularProgressIndicator()), // Loading until user data is fetched
      );
    }

    return SafeArea(
      child: ZegoUIKitPrebuiltCall(
        appID: Zegocall.appId,
        appSign: Zegocall.appSignin,
        userID: userId!,
        userName: userName!,
        callID: widget.callingId,
        config: ZegoUIKitPrebuiltCallConfig.groupVideoCall(),
      ),
    );
  }
}
