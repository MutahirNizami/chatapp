class Chat {
  final String name;
  final String message;
  final String imageUrl;
  final String time;

  Chat({
    required this.name,
    required this.message,
    required this.imageUrl,
    required this.time,
  });
}

// List of chats......................

List<Chat> chats = [
  Chat(
    name: "Danny Hopkins",
    message: "dannylove@gmail.com",
    imageUrl: "assets/images/man.png",
    time: "08:43 AM",
  ),
  Chat(
    name: "Bobby Langford",
    message: "Will do, super, thank you",
    imageUrl: "assets/images/women.png",
    time: "Tue",
  ),
  Chat(
    name: "William Wiles",
    message: "Uploaded file.",
    imageUrl: "assets/images/man.png",
    time: "Sun",
  ),
  Chat(
    name: "James Edelen",
    message: "Here is another tutorial, if you...",
    imageUrl: "assets/images/man.png",
    time: "23 Mar",
  ),
];
