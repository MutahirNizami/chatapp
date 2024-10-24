import 'dart:async';
import 'package:chatapp/router/bottomnavigation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> handlebackgroundmessage(RemoteMessage message) async {
  print('Title : ${message.notification?.title}');
  print('body : ${message.notification?.body}');
  print('payload : ${message.data}');

  // if (message == null) return;
  // navigatorkey.currentState?.pushNamed(
  //   NotificatonScreen.route,
  //   arguments: message,
  // );
}

Future<void> initpushnotification() async {
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  //foreground notification.......................
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print(
        'Message received: ${message.notification?.title} - ${message.notification?.body}');
    // Handle foreground notification
  });

//background.............
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Notification clicked!');
    Get.to(() => DashboardScreen());
  });

  //terminated..........

  FirebaseMessaging.onBackgroundMessage(handlebackgroundmessage);
}

class FirebaseNotification {
  final _messaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _messaging.requestPermission();
    final fcmToken = await _messaging.getToken();
    print('Token : $fcmToken');
  }
}

Future<void> sendPushNotification(String recipientId, String message) async {
  // Fetch recipient's FCM token from Firestore
  DocumentSnapshot userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(recipientId)
      .get();

  if (userDoc.exists && userDoc.data() != null) {
    var userData = userDoc.data() as Map<String, dynamic>;
    String? fcmToken = userData['fcmToken'];

    if (fcmToken != null) {
      // Firebase Cloud Messaging API URL
      final String serverKey = 'YOUR_SERVER_KEY';
      final String fcmUrl = 'https://fcm.googleapis.com/fcm/send';

      // Prepare notification payload
      Map<String, dynamic> notificationData = {
        'notification': {
          'title': 'New Message',
          'body': message,
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'sound': 'default'
        },
        'priority': 'high',
        'to': fcmToken,
        'data': {
          'type': 'message',
          'senderId': 'currentUserUid',
        }
      };

      // Send the notification via HTTP request to FCM
      try {
        var response = await http.post(
          Uri.parse(fcmUrl),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'key=$serverKey',
          },
          body: jsonEncode(notificationData),
        );

        if (response.statusCode == 200) {
          print('Notification sent successfully.');
        } else {
          print('Error sending notification: ${response.body}');
        }
      } catch (e) {
        print('Error sending notification: $e');
      }
    } else {
      print('No FCM token found for the recipient.');
    }
  } else {
    print('Recipient not found.');
  }
}
