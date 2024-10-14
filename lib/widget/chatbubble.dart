import 'package:chatapp/utilites/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatBubble extends StatelessWidget {
  final bool isSentByMe;
  final String message;
  final String time;
  final String? imageurl;
  final String? senderName;

  const ChatBubble({
    super.key,
    required this.isSentByMe,
    required this.message,
    required this.time,
    this.imageurl,
    this.senderName,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment:
          isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        // if (senderName != null)
        // Text(isGroupchat?senderName:null),
        Center(
          child: Text(
            time,
            style: GoogleFonts.poppins(
              color: Mycolor().titlecolor,
              fontSize: height * 0.016,
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: width * 0.7,
          ),
          child: Container(
            margin: EdgeInsets.symmetric(vertical: height * 0.015),
            padding: EdgeInsets.symmetric(
                horizontal: width * 0.015, vertical: height * 0.015),
            decoration: BoxDecoration(
              color: isSentByMe
                  ? Mycolor().nonfcontainercolor
                  : Mycolor().fcontainercolor,
              borderRadius: BorderRadius.circular(height * 0.02),
            ),
            child: Column(
              crossAxisAlignment: isSentByMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (imageurl != null && imageurl!.isNotEmpty)
                  Image.network(
                    imageurl!,
                    fit: BoxFit.cover,
                  ),
                Text(
                  message,
                  style: GoogleFonts.poppins(
                      color: Mycolor().titlecolor, fontSize: height * 0.017),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
