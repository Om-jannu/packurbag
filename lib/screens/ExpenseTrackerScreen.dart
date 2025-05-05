import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'ReceiptScannerScreen.dart';
import 'package:flutter/services.dart';
import 'UPITransactionScreen.dart';
import 'ExpenseAnalyticsScreen.dart';

class ExpenseTrackerScreen extends StatefulWidget {
  final String serverIp;
  final String userId;

  const ExpenseTrackerScreen({
    Key? key,
    required this.serverIp,
    required this.userId,
  }) : super(key: key);

  @override
  _ExpenseTrackerScreenState createState() => _ExpenseTrackerScreenState();
}

class _ExpenseTrackerScreenState extends State<ExpenseTrackerScreen> {
  List<Map<String, dynamic>> expenses = [];
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;
  String? error;
  static const platform = MethodChannel('com.example.packurbag/shared_content');

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadExpenses();
    _setupSharedContentHandler();
  }

  void _setupSharedContentHandler() {
    platform.setMethodCallHandler((call) async {
      if (call.method == 'onSharedContent') {
        final sharedData = Map<String, dynamic>.from(call.arguments);
        _handleSharedContent(sharedData);
      }
    });
  }

  void _handleSharedContent(Map<String, dynamic> sharedData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UPITransactionScreen(
          serverIp: widget.serverIp,
          userId: widget.userId,
          categories: categories,
          sharedData: sharedData,
        ),
      ),
    ).then((_) => _loadExpenses());
  }

  Future<void> _loadCategories() async {
    try {
      final response = await http.get(
        Uri.parse('${widget.serverIp}/categories/${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          setState(() {
            categories = List<Map<String, dynamic>>.from(data['data']);
          });
        } else {
          setState(() {
            error = 'No categories found';
          });
        }
      } else {
        setState(() {
          error = 'Failed to load categories';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error loading categories: $e';
      });
    }
  }

  Future<void> _loadExpenses() async {
    try {
      final response = await http.get(
        Uri.parse('${widget.serverIp}/expenses/${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          setState(() {
            expenses = List<Map<String, dynamic>>.from(data['data']);
            isLoading = false;
          });
        } else {
          setState(() {
            error = 'No expenses found';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          error = 'Failed to load expenses';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error loading expenses: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _addExpense() async {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    String? selectedCategoryId;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Category'),
              items: categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category['_id'].toString(),
                  child: Text(category['categoryName']),
                );
              }).toList(),
              onChanged: (value) {
                selectedCategoryId = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (amountController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty &&
                  selectedCategoryId != null) {
                try {
                  final response = await http.post(
                    Uri.parse('${widget.serverIp}/expenses/${widget.userId}'),
                    headers: {'Content-Type': 'application/json'},
                    body: json.encode({
                      'amount': double.parse(amountController.text),
                      'description': descriptionController.text,
                      'category': categories.firstWhere(
                        (cat) => cat['_id'].toString() == selectedCategoryId,
                      )['categoryName'],
                    }),
                  );

                  if (response.statusCode == 200) {
                    Navigator.pop(context);
                    _loadExpenses();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to add expense')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error adding expense: $e')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteExpense(String expenseId) async {
    try {
      final response = await http.delete(
        Uri.parse('${widget.serverIp}/api/expenses/${widget.userId}/$expenseId'),
      );

      if (response.statusCode == 200) {
        _loadExpenses();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete expense')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting expense: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(child: Text(error!));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExpenseAnalyticsScreen(
                    serverIp: widget.serverIp,
                    userId: widget.userId,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UPITransactionScreen(
                    serverIp: widget.serverIp,
                    userId: widget.userId,
                    categories: categories,
                  ),
                ),
              ).then((_) => _loadExpenses());
            },
            tooltip: 'Add UPI Transaction',
          ),
          IconButton(
            icon: const Icon(Icons.document_scanner),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReceiptScannerScreen(
                    serverIp: widget.serverIp,
                    userId: widget.userId,
                    categories: categories,
                  ),
                ),
              );
              if (result == true) {
                _loadExpenses();
              }
            },
          ),
        ],
      ),
      body: expenses.isEmpty
          ? const Center(child: Text('No expenses yet'))
          : ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _parseColor(expense['categoryColor']),
                    child: Text(
                      expense['category'][0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(expense['description']),
                  subtitle: Text(
                    DateFormat('MMM d, y').format(
                      DateTime.parse(expense['date']),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '\$${expense['amount'].toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteExpense(expense['_id']),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpense,
        child: const Icon(Icons.add),
      ),
    );
  }

    Color _parseColor(String? colorHex) {
    if (colorHex != null && colorHex.isNotEmpty) {
      return Color(int.parse('0xFF$colorHex'));
    }
    return Colors.grey;
  }
} 