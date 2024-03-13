// import 'dart:convert';
// import 'package:flutter/material.dart';
// class BluetoothChatScreen extends StatefulWidget {
//   const BluetoothChatScreen({super.key});

//   @override
//   State<BluetoothChatScreen> createState() => _BluetoothChatScreenState();
// }

// class _BluetoothChatScreenState extends State<BluetoothChatScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';

import '../main.dart';

class Message {
  final String message;
  final bool isMe;

  Message({required this.message, required this.isMe});
}

class BluetoothChatScreen extends StatefulWidget {
  const BluetoothChatScreen({super.key});

  @override
  State<BluetoothChatScreen> createState() => _BluetoothChatScreenState();
}

class _BluetoothChatScreenState extends State<BluetoothChatScreen> {
  final messageController = TextEditingController();

  final messages = <Message>[];
  @override
  void initState() {
    super.initState();
    allBluetooth.listenForData.listen((event) {
      messages.add(Message(
        message: event.toString(),
        isMe: false,
      ));
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            ElevatedButton(
              onPressed: () {
                allBluetooth.closeConnection();
              },
              child: const Text("CLOSE"),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  // ignore: non_constant_identifier_names
                  final Message = messages[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ChatBubble(
                      clipper: ChatBubbleClipper4(
                        type: Message.isMe
                            ? BubbleType.sendBubble
                            : BubbleType.receiverBubble,
                      ),
                      alignment:
                          Message.isMe ? Alignment.topRight : Alignment.topLeft,
                      child: Text(Message.message),
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final message = messageController.text;
                    allBluetooth.sendMessage(message);
                    messageController.clear();
                    messages.add(
                      Message(
                        message: message,
                        isMe: true,
                      ),
                    );
                    setState(() {});
                  },
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ],
        ));
  }
}
