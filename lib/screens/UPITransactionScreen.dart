import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class UPITransactionScreen extends StatefulWidget {
  final String serverIp;
  final String userId;
  final List<Map<String, dynamic>> categories;
  final Map<String, dynamic>? sharedData;

  const UPITransactionScreen({
    Key? key,
    required this.serverIp,
    required this.userId,
    required this.categories,
    this.sharedData,
  }) : super(key: key);

  @override
  _UPITransactionScreenState createState() => _UPITransactionScreenState();
}

class _UPITransactionScreenState extends State<UPITransactionScreen> {
  File? _image;
  bool _isProcessing = false;
  String? _error;
  double? _extractedAmount;
  String? _selectedCategoryId;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.sharedData != null) {
      _handleSharedData();
    }
  }

  void _handleSharedData() {
    // Handle shared image if present
    if (widget.sharedData!['image'] != null) {
      setState(() {
        _image = File(widget.sharedData!['image']);
      });
      _processImage();
    }

    // Handle shared metadata
    if (widget.sharedData!['amount'] != null) {
      _amountController.text = widget.sharedData!['amount'].toString();
      _extractedAmount = double.tryParse(widget.sharedData!['amount'].toString());
    }

    if (widget.sharedData!['description'] != null) {
      _descriptionController.text = widget.sharedData!['description'];
    }

    if (widget.sharedData!['transactionId'] != null) {
      _descriptionController.text += ' (Txn: ${widget.sharedData!['transactionId']})';
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

      print('=== GPay Transaction OCR Results ===');
      print(recognizedText.text);
      print('=== End OCR Results ===');

      // Extract amount if not already set from metadata
      if (_extractedAmount == null) {
        final List<double> potentialAmounts = _extractAllAmounts(recognizedText.text);
        if (potentialAmounts.isNotEmpty) {
          _extractedAmount = potentialAmounts.first;
          _amountController.text = _extractedAmount!.toStringAsFixed(2);
        }
      }

      setState(() {
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
    final List<RegExp> amountPatterns = [
      RegExp(r'Rs\.?\s*\d+\.?\d*', caseSensitive: false), // Rs.XX.XX
      RegExp(r'₹\s*\d+\.?\d*'), // ₹XX.XX
      RegExp(r'INR\s*\d+\.?\d*', caseSensitive: false), // INR XX.XX
      RegExp(r'\d+\.?\d*\s*Rs\.?', caseSensitive: false), // XX.XX Rs.
      RegExp(r'\d+\.?\d*\s*₹'), // XX.XX ₹
      RegExp(r'(?:paid|sent|transferred)\s*(?:Rs\.?|₹|INR)?\s*(\d+(?:\.\d{2})?)', caseSensitive: false),
      RegExp(r'amount\s*(?:Rs\.?|₹|INR)?\s*(\d+(?:\.\d{2})?)', caseSensitive: false),
    ];

    final List<double> amounts = [];
    
    for (var pattern in amountPatterns) {
      final matches = pattern.allMatches(text);
      for (var match in matches) {
        final amountStr = match.group(0)!
            .replaceAll(RegExp(r'[^\d.]'), '')
            .trim();
        final amount = double.tryParse(amountStr);
        if (amount != null) {
          print('Found amount: $amount from pattern: ${pattern.pattern}');
          amounts.add(amount);
        }
      }
    }

    amounts.sort((a, b) => b.compareTo(a));
    return amounts;
  }

  Future<void> _addExpense() async {
    if (_selectedCategoryId == null) {
      setState(() {
        _error = 'Please select a category';
      });
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null) {
      setState(() {
        _error = 'Please enter a valid amount';
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${widget.serverIp}/expenses/${widget.userId}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': amount,
          'description': _descriptionController.text.isNotEmpty 
              ? _descriptionController.text 
              : 'UPI Transaction',
          'category': widget.categories.firstWhere(
            (cat) => cat['_id'].toString() == _selectedCategoryId,
          )['categoryName'],
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
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
        title: const Text('GPay Transaction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_image != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _image!,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
            ],
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixText: '₹ ',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Category',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      value: _selectedCategoryId,
                      items: widget.categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category['_id'].toString(),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Color(int.parse('0xFF${category['categoryColor']}')),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(category['categoryName']),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isProcessing ? null : _addExpense,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isProcessing
                  ? const CircularProgressIndicator()
                  : const Text('Add Expense', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }
} 