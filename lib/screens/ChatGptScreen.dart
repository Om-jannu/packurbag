import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatGptScreen extends StatefulWidget {
  const ChatGptScreen({Key? key}) : super(key: key);

  @override
  State<ChatGptScreen> createState() => _ChatGptScreenState();
}

class _ChatGptScreenState extends State<ChatGptScreen> {
  TextEditingController _messageController = TextEditingController();
  List<String> messages = [];

  Future<void> sendMessage(String message) async {
    setState(() {
      messages.add('You: $message');
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer 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', // Replace with your API key
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': messages.map((msg) => {'role': 'system', 'content': msg}).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final chatResponse = data['choices'][0]['message']['content'];

        setState(() {
          messages.add('AI: $chatResponse');
        });
      } else {
        print('Failed to get response. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with GPT'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    final message = _messageController.text.trim();
                    if (message.isNotEmpty) {
                      sendMessage(message);
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
