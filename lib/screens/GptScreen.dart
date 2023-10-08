import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'AiImageGeneratorTab.dart';
import 'ChatGptTab.dart';

class GptScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('GPT Screen'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'ChatGPT'),
              Tab(text: 'Text-to-Image'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ChatGptTab(),
            AiImageGeneratorScreen(),
          ],
        ),
      ),
    );
  }
}

// class ChatGptTab extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text('ChatGPT Tab Content'),
//     );
//   }
// }

// class TextToImageTab extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text('Text-to-Image Tab Content'),
//     );
//   }
// }
