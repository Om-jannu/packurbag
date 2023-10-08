import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:stability_image_generation/stability_image_generation.dart';

class AiImageGeneratorScreen extends StatefulWidget {
  @override
  _AiImageGeneratorScreenState createState() => _AiImageGeneratorScreenState();
}

class _AiImageGeneratorScreenState extends State<AiImageGeneratorScreen> {
  final TextEditingController _queryController = TextEditingController();
  final FocusNode _queryFocus = FocusNode();
  final StabilityAI _ai = StabilityAI();
  bool run = false;
  ImageAIStyle selectedStyle = ImageAIStyle.aivazovskyPainter; // Default style

  Future<Uint8List> _generate(String query, ImageAIStyle style) async {
    try {
      Uint8List image = await _ai.generateImage(
        apiKey: 'sk-DrsLBV9XL1yMvjUbVNFhHJamLwQZcTmJ8dEPIkOKIvMYM5MD',
        imageAIStyle: style,
        prompt: query,
      );
      return image;
    } catch (e) {
      print('Error generating image: $e');
      throw e;
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    _queryFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey.shade900, // Dark background color
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: double.infinity,
                height: 50,
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black54,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _queryController,
                  focusNode: _queryFocus,
                  style: TextStyle(color: Colors.white60),
                  decoration: InputDecoration(
                    hintText: 'Enter query text...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(left: 12),
                  ),
                  onSubmitted: (_) {
                    _queryFocus.unfocus(); // Dismiss the keyboard
                    _submitQuery();
                  },
                ),
              ),
              DropdownButton<ImageAIStyle>(
                value: selectedStyle,
                onChanged: (ImageAIStyle? style) {
                  if (style != null) {
                    setState(() {
                      selectedStyle = style;
                    });
                  }
                },
                items: ImageAIStyle.values.map((style) {
                  return DropdownMenuItem<ImageAIStyle>(
                    value: style,
                    child: Text(
                      style.toString().split('.').last,
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                dropdownColor: Colors.grey.shade800,
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  height: size,
                  width: size,
                  child: run
                      ? FutureBuilder<Uint8List>(
                          future: _generate(_queryController.text, selectedStyle),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(
                                child: const CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return Text(
                                'Error: ${snapshot.error}',
                                style: TextStyle(color: Colors.white),
                              );
                            } else if (snapshot.hasData) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(snapshot.data!),
                              );
                            } else {
                              return Container();
                            }
                          },
                        )
                      : const Center(
                          child: Text(
                            'Enter Text and Click the button to generate',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _submitQuery,
        tooltip: 'Generate',
        child: const Icon(Icons.gesture),
      ),
    );
  }

  void _submitQuery() {
    String query = _queryController.text;
    if (query.isNotEmpty) {
      setState(() {
        run = true;
      });
    } else {
      if (bool.fromEnvironment("dart.vm.product")) {
        print('Query is empty !!');
      }
    }
  }
}



