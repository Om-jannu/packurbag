import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatGptTab extends StatefulWidget {
  const ChatGptTab({super.key});

  @override
  _ChatGptTabState createState() => _ChatGptTabState();
}

class _ChatGptTabState extends State<ChatGptTab> {
  final TextEditingController _messageController = TextEditingController();
  List<String> messages = [];
  String selectedModel = 'text-davinci-002'; // Default model

  List<String> availableModels = ['gpt-3.5-turbo', 'text-davinci-002']; // Add more models as needed

  Future<void> sendMessage(String message) async {
    setState(() {
      messages.add('You: $message');
    });

    try {
      final response = await http.post(
        Uri.parse('http://your-backend-server-url.com/send-message'), // Replace with your backend server URL
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': selectedModel,
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final chatResponse = data['response']; // Assuming your backend sends back the response in a 'response' field

        setState(() {
          messages.add('AI: $chatResponse');
        });
      } else {
        print('Failed to get response from backend. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton<String>(
          value: selectedModel,
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                selectedModel = newValue;
              });
            }
          },
          items: availableModels.map((String model) {
            return DropdownMenuItem<String>(
              value: model,
              child: Text(model),
            );
          }).toList(),
        ),
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
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
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
    );
  }
}
