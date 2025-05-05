import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/services.dart';

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
  String? _rawOcrText;
  List<double> _detectedAmounts = [];
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  static const platform = MethodChannel('com.example.packurbag/shared_content');

  @override
  void initState() {
    super.initState();
    _setupMethodChannel();
    if (widget.sharedData != null) {
      _handleSharedData();
    }
  }

  void _setupMethodChannel() {
    platform.setMethodCallHandler((call) async {
      if (call.method == 'onSharedContent') {
        final sharedData = Map<String, dynamic>.from(call.arguments);
        _handleSharedData(sharedData);
      }
    });
  }

  Future<void> _handleSharedImage(String imagePath) async {
    setState(() {
      _image = File(imagePath);
      _isProcessing = true;
      _error = null;
      _rawOcrText = null;
      _detectedAmounts = [];
    });
    await _processImage();
  }

  void _handleSharedText(String text) {
    print('Received shared text: $text');
    
    // Try to extract amount
    final amountPatterns = [
      RegExp(r'(?:Rs\.?|₹|INR)\s*(\d+(?:\.\d{2})?)', caseSensitive: false),
      RegExp(r'(?:paid|sent|transferred)\s*(?:Rs\.?|₹|INR)?\s*(\d+(?:\.\d{2})?)', caseSensitive: false),
      RegExp(r'amount\s*(?:Rs\.?|₹|INR)?\s*(\d+(?:\.\d{2})?)', caseSensitive: false),
    ];

    for (var pattern in amountPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final amount = double.tryParse(match.group(1)!.replaceAll(RegExp(r'[^\d.]'), ''));
        if (amount != null) {
          setState(() {
            _amountController.text = amount.toStringAsFixed(2);
            _extractedAmount = amount;
          });
          break;
        }
      }
    }

    // Try to extract description
    final descriptionPatterns = [
      RegExp(r'(?:paid|sent|to)\s+([^,]+)', caseSensitive: false),
      RegExp(r'(?:recipient|beneficiary):\s*([^,]+)', caseSensitive: false),
      RegExp(r'(?:for|purpose):\s*([^,]+)', caseSensitive: false),
    ];

    for (var pattern in descriptionPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        setState(() {
          _descriptionController.text = match.group(1)!.trim();
        });
        break;
      }
    }

    // Try to extract transaction ID
    final transactionPattern = RegExp(r'(?:transaction|txn|ref)(?:id|no)?[:\s]+([A-Za-z0-9]+)', caseSensitive: false);
    final transactionMatch = transactionPattern.firstMatch(text);
    if (transactionMatch != null) {
      setState(() {
        _descriptionController.text += ' (Txn: ${transactionMatch.group(1)})';
      });
    }
  }

  void _handleSharedData([Map<String, dynamic>? data]) {
    final sharedData = data ?? widget.sharedData;
    if (sharedData == null) return;

    if (sharedData['image'] != null) {
      _handleSharedImage(sharedData['image']);
    }

    if (sharedData['text'] != null) {
      _handleSharedText(sharedData['text']);
    }
  }

  Future<void> _processImage() async {
    if (_image == null) return;

    try {
      final inputImage = InputImage.fromFile(_image!);
      final textRecognizer = TextRecognizer();
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      print('=== GPay Transaction OCR Results ===');
      print(recognizedText.text);
      print('=== End OCR Results ===');

      setState(() {
        _rawOcrText = recognizedText.text;
      });

      // Extract amount if not already set
      if (_extractedAmount == null) {
        final List<double> potentialAmounts = _extractAllAmounts(recognizedText.text);
        setState(() {
          _detectedAmounts = potentialAmounts;
          if (potentialAmounts.isNotEmpty) {
            _extractedAmount = potentialAmounts.first;
            _amountController.text = _extractedAmount!.toStringAsFixed(2);
          }
        });
      }

      // Extract description if not already set
      if (_descriptionController.text.isEmpty) {
        final descriptionPatterns = [
          RegExp(r'(?:paid|sent|to)\s+([^,]+)', caseSensitive: false),
          RegExp(r'(?:recipient|beneficiary):\s*([^,]+)', caseSensitive: false),
          RegExp(r'(?:for|purpose):\s*([^,]+)', caseSensitive: false),
        ];

        for (var pattern in descriptionPatterns) {
          final match = pattern.firstMatch(recognizedText.text);
          if (match != null) {
            setState(() {
              _descriptionController.text = match.group(1)!.trim();
            });
            break;
          }
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
            if (_rawOcrText != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OCR Results',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(
                          _rawOcrText!,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (_detectedAmounts.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detected Amounts',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      ..._detectedAmounts.map((amount) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Text(
                              '₹ ${amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: amount == _extractedAmount ? FontWeight.bold : FontWeight.normal,
                                color: amount == _extractedAmount ? Colors.green : null,
                              ),
                            ),
                            if (amount == _extractedAmount)
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Icon(Icons.check_circle, color: Colors.green, size: 16),
                              ),
                          ],
                        ),
                      )).toList(),
                    ],
                  ),
                ),
              ),
            ],
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