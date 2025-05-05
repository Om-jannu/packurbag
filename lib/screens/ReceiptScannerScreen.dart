import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReceiptScannerScreen extends StatefulWidget {
  final String serverIp;
  final String userId;
  final List<Map<String, dynamic>> categories;

  const ReceiptScannerScreen({
    Key? key,
    required this.serverIp,
    required this.userId,
    required this.categories,
  }) : super(key: key);

  @override
  _ReceiptScannerScreenState createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends State<ReceiptScannerScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  String? _extractedText;
  bool _isProcessing = false;
  String? _error;
  double? _extractedAmount;
  String? _selectedCategoryId;

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _image = File(image.path);
          _extractedText = null;
          _extractedAmount = null;
          _error = null;
        });
        _processImage();
      }
    } catch (e) {
      setState(() {
        _error = 'Error picking image: $e';
      });
    }
  }

  Future<void> _processImage() async {
    if (_image == null) return;

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final inputImage = InputImage.fromFile(_image!);
      final textRecognizer = TextRecognizer();
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      // Log all blocks of text
      print('=== OCR Results ===');
      for (TextBlock block in recognizedText.blocks) {
        print('Block Text: ${block.text}');
        print('Block Languages: ${block.recognizedLanguages}');
        print('Block Bounding Box: ${block.boundingBox}');
        print('---');
        
        // Log individual lines in the block
        for (TextLine line in block.lines) {
          print('Line Text: ${line.text}');
          print('Line Languages: ${line.recognizedLanguages}');
          print('Line Bounding Box: ${line.boundingBox}');
          print('---');
          
          // Log individual elements in the line
          for (TextElement element in line.elements) {
            print('Element Text: ${element.text}');
            print('Element Bounding Box: ${element.boundingBox}');
            print('---');
          }
        }
      }
      print('=== End OCR Results ===');

      // Extract potential amounts with more detailed logging
      final List<double> potentialAmounts = _extractAllAmounts(recognizedText.text);
      print('Potential amounts found: $potentialAmounts');

      setState(() {
        _extractedText = recognizedText.text;
        _extractedAmount = potentialAmounts.isNotEmpty ? potentialAmounts.first : null;
        _isProcessing = false;
      });
    } catch (e) {
      print('Error processing image: $e');
      setState(() {
        _error = 'Error processing image: $e';
        _isProcessing = false;
      });
    }
  }

  List<double> _extractAllAmounts(String text) {
    // Look for various amount patterns
    final List<RegExp> amountPatterns = [
      RegExp(r'\$?\d+\.\d{2}'), // Standard format: $XX.XX or XX.XX
      RegExp(r'\$?\d+'), // Whole numbers: $XX or XX
      RegExp(r'TOTAL:?\s*\$?\d+\.?\d*', caseSensitive: false), // Total: $XX.XX
      RegExp(r'AMOUNT:?\s*\$?\d+\.?\d*', caseSensitive: false), // Amount: $XX.XX
      RegExp(r'SUBTOTAL:?\s*\$?\d+\.?\d*', caseSensitive: false), // Subtotal: $XX.XX
    ];

    final List<double> amounts = [];
    
    for (var pattern in amountPatterns) {
      final matches = pattern.allMatches(text);
      for (var match in matches) {
        final amountStr = match.group(0)!
            .replaceAll(RegExp(r'[^\d.]'), '') // Remove non-numeric characters except decimal
            .trim();
        final amount = double.tryParse(amountStr);
        if (amount != null) {
          print('Found amount: $amount from pattern: ${pattern.pattern}');
          amounts.add(amount);
        }
      }
    }

    // Sort amounts in descending order (usually the total is the largest)
    amounts.sort((a, b) => b.compareTo(a));
    return amounts;
  }

  Future<void> _addExpense() async {
    if (_extractedAmount == null || _selectedCategoryId == null) {
      setState(() {
        _error = 'Please select a category and ensure amount is extracted';
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${widget.serverIp}/expenses/${widget.userId}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': _extractedAmount,
          'description': _extractedText ?? 'Receipt expense',
          'category': widget.categories.firstWhere(
            (cat) => cat['_id'].toString() == _selectedCategoryId,
          )['categoryName'],
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        setState(() {
          _error = 'Failed to add expense';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error adding expense: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Receipt'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_image != null) ...[
              Image.file(
                _image!,
                height: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_library),
              label: const Text('Pick Receipt Image'),
            ),
            const SizedBox(height: 16),
            if (_isProcessing)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              )
            else if (_extractedText != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Raw Extracted Text:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _extractedText!,
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ),
                      if (_extractedAmount != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Detected Amount: \$${_extractedAmount!.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Category',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCategoryId,
                items: widget.categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category['_id'].toString(),
                    child: Text(category['categoryName']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addExpense,
                child: const Text('Add Expense'),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 