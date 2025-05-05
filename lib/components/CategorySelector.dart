import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CategorySelector extends StatefulWidget {
  final String userId;
  final String serverIp;
  final Function(String category, Color color) onCategorySelected;

  const CategorySelector({
    Key? key,
    required this.userId,
    required this.serverIp,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('${widget.serverIp}/categories/${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            categories = List<Map<String, dynamic>>.from(data['data']);
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching categories: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (categories.isEmpty) {
      return const Text('No categories available');
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((category) {
        final color = Color(int.parse(category['categoryColor'], radix: 16));
        return ChoiceChip(
          label: Text(category['categoryName']),
          selected: false,
          onSelected: (selected) {
            if (selected) {
              widget.onCategorySelected(
                category['categoryName'],
                color,
              );
            }
          },
          backgroundColor: color.withOpacity(0.2),
          selectedColor: color,
          labelStyle: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        );
      }).toList(),
    );
  }
} 