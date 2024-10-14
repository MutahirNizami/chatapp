// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class FirebaseService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // Send a message to a group
//   Future<void> sendMessage(String groupId, String message) async {
//     if (message.isNotEmpty) {
//       await _firestore
//           .collection('groups')
//           .doc(groupId)
//           .collection('messages')
//           .add({
//         'text': message,
//         'senderId  ': _auth.currentUser!.uid,
//         'senderName': _auth.currentUser!.displayName,
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//     }
//   }

//   // Add a user to a group
//   Future<void> addUserToGroup(String groupId, String userId) async {
//     await _firestore
//         .collection('groups')
//         .doc(groupId)
//         .collection('participants')
//         .doc(userId)
//         .set({
//       'userId': userId,
//     });
//   }

//   // Fetch users from Firestore
//   Stream<List<DocumentSnapshot>> fetchUsers() {
//     return _firestore
//         .collection('users')
//         .snapshots()
//         .map((query) => query.docs);
//   }

//   // Fetch messages from a group
//   Stream<QuerySnapshot> fetchMessages(String groupId) {
//     return _firestore
//         .collection('groups')
//         .doc(groupId)
//         .collection('messages')
//         .orderBy('timestamp', descending: true)
//         .snapshots();
//   }
// }
