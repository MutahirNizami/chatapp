import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String recipientID;
  final String text;
  final Timestamp timestamp;

  Message({
    required this.senderID,
    required this.recipientID,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'recipientID': recipientID,
      'text': text,
      'timestamp': timestamp,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderID: map['senderID'],
      recipientID: map['recipientID'],
      text: map['text'],
      timestamp: map['timestamp'],
    );
  }
}
