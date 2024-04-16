import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import '../screens/BtScreen.dart';

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
        title: const Text("Bluetooth Chat"),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              allBluetooth.closeConnection();
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ChatBubble(
                    clipper: ChatBubbleClipper6(
                      nipSize: 2,
                      radius: 16,
                      type: message.isMe
                          ? BubbleType.sendBubble
                          : BubbleType.receiverBubble,
                    ),
                    backGroundColor:
                        message.isMe ? Colors.blue : Colors.grey[300],
                    alignment: message.isMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Text(
                      message.message,
                      style: TextStyle(
                        color: message.isMe ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.black),
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                FloatingActionButton(
                  onPressed: () {
                    final message = messageController.text.trim();
                    if (message.isNotEmpty) {
                      allBluetooth.sendMessage(message);
                      messageController.clear();
                      messages.add(
                        Message(
                          message: message,
                          isMe: true,
                        ),
                      );
                      setState(() {});
                    }
                  },
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
