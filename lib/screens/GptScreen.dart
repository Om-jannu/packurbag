import 'package:flutter/material.dart';
import 'AiImageGeneratorTab.dart';
import 'ChatGptTab.dart';

class GptScreen extends StatelessWidget {
  const GptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('GPT Screen'),
          bottom: const TabBar(
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
