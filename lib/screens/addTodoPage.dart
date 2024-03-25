// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../components/GlobalSnackbar.dart';
import '../main.dart';
import '../utils/utils.dart';

class AddTodoPage extends StatefulWidget {
  const AddTodoPage({Key? key}) : super(key: key);

  @override
  _AddTodoPageState createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _addCategoryformKey = GlobalKey<FormState>();
  final TextEditingController _todoTextController = TextEditingController();
  final TextEditingController _categoryTextController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _category = "";
  List<String> _categories = [];
  int _priority = 0;
  final List<int> _priorities = [0, 1, 2, 3, 4]; // Example priority levels

  //color picker
  late Color dialogPickerColor;
  late bool isDark;

  static const Color guidePrimary = Color(0xFF6200EE);
  static const Color guidePrimaryVariant = Color(0xFF3700B3);
  static const Color guideSecondary = Color(0xFF03DAC6);
  static const Color guideSecondaryVariant = Color(0xFF018786);
  static const Color guideError = Color(0xFFB00020);
  static const Color guideErrorDark = Color(0xFFCF6679);
  static const Color blueBlues = Color(0xFF174378);

  // Make a custom ColorSwatch to name map from the above custom colors.
  final Map<ColorSwatch<Object>, String> colorsNameMap =
      <ColorSwatch<Object>, String>{
    ColorTools.createPrimarySwatch(guidePrimary): 'Guide Purple',
    ColorTools.createPrimarySwatch(guidePrimaryVariant): 'Guide Purple Variant',
    ColorTools.createAccentSwatch(guideSecondary): 'Guide Teal',
    ColorTools.createAccentSwatch(guideSecondaryVariant): 'Guide Teal Variant',
    ColorTools.createPrimarySwatch(guideError): 'Guide Error',
    ColorTools.createPrimarySwatch(guideErrorDark): 'Guide Error Dark',
    ColorTools.createPrimarySwatch(blueBlues): 'Blue blues',
  };
  @override
  void initState() {
    super.initState();
    dialogPickerColor = Colors.red;
    isDark = false;
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';
      final response =
          await http.get(Uri.parse('http://$serverIp:5000/categories/$userId'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          final List<dynamic> categoriesData = data['data'];
          print('Categories data: $categoriesData');
          if (mounted) {
            // Check if the widget is still mounted before updating state
            setState(() {
              _categories = categoriesData
                  .map((category) => category['categoryName'] as String)
                  .toList();
            });
          }
          print(_categories);
        } else {
          if (mounted) {
            // Check if the widget is still mounted before showing snackbar
            GlobalSnackbar.show(context, data['message']);
          }
        }
      } else {
        if (mounted) {
          // Check if the widget is still mounted before showing snackbar
          GlobalSnackbar.show(context, 'Failed to fetch categories');
        }
      }
    } catch (e) {
      if (e is SocketException) {
        if (mounted) {
          // Check if the widget is still mounted before showing snackbar
          GlobalSnackbar.show(context,
              'Connection error: Please check your internet connection.');
        }
      } else {
        if (mounted) {
          // Check if the widget is still mounted before showing snackbar
          print('Error: $e');
          GlobalSnackbar.show(
              context, 'An error occurred while fetching categories');
        }
      }
    }
  }

  Future<void> _addTodo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';
      if (_formKey.currentState!.validate()) {
        final response = await http.post(
          Uri.parse('http://$serverIp:5000/todos/$userId'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'text': _todoTextController.text,
            'date': _selectedDate.toIso8601String(),
            'priority': _priority,
            'category': _category,
            "dateOfCreation": DateTime.now().toIso8601String(),
          }),
        );

        if (response.statusCode == 200) {
          // Refresh categories after adding
          _fetchCategories();
          Navigator.pop(context);
          if (mounted) {
            GlobalSnackbar.show(context, 'Todo Added successfully',
                success: true);
          }
        } else {
          if (mounted) {
            GlobalSnackbar.show(context, 'Failed to add todo');
          }
        }
      }
    } catch (e) {
      if (e is SocketException) {
        // Handle SocketException (No internet connection or server unreachable)
        if (mounted) {
          GlobalSnackbar.show(context,
              'Connection error: Please check your internet connection.');
        }
      } else {
        // Handle other exceptions
        print('Error: $e');
        if (mounted) {
          GlobalSnackbar.show(context, 'An error occurred while adding todo');
        }
      }
    }
  }

  Future<void> _addCategory(Color dialogPickerColorLocal) async {
    try {
      if (_addCategoryformKey.currentState!.validate()) {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('userId') ?? '';
        final response = await http.post(
          Uri.parse('http://$serverIp:5000/categories/$userId'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'categoryName': _categoryTextController.text,
            'categoryColor': dialogPickerColorLocal.hex, // Send selected color
          }),
        );
        final data = jsonDecode(response.body);
        print(data);
        if (response.statusCode == 201) {
          _fetchCategories();
          _addCategoryformKey.currentState!.reset();
          setState(() {
            dialogPickerColorLocal = Colors.red;
          });
          Navigator.pop(context);
          if (mounted) {
            GlobalSnackbar.show(context, data['message'], success: true);
          }
        } else {
          _addCategoryformKey.currentState!.reset();
          setState(() {
            dialogPickerColorLocal = Colors.red;
          });
          Navigator.pop(context);
          if (mounted) {
            GlobalSnackbar.show(context, data['message']);
          }
        }
      }
    } catch (e) {
      if (e is SocketException) {
        if (mounted) {
          GlobalSnackbar.show(context,
              'Connection error: Please check your internet connection.');
        }
      } else {
        print('Error: $e');
        if (mounted) {
          GlobalSnackbar.show(
              context, 'An error occurred while adding category');
        }
      }
    }
  }

  Future<bool> colorPickerDialog() async {
    return ColorPicker(
      color: dialogPickerColor,
      onColorChanged: (Color color) =>
          setState(() => dialogPickerColor = color),
      width: 40,
      height: 40,
      borderRadius: 4,
      spacing: 5,
      runSpacing: 5,
      wheelDiameter: 155,
      heading: Text(
        'Select color',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subheading: Text(
        'Select color shade',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      wheelSubheading: Text(
        'Selected color and its shades',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      showMaterialName: true,
      showColorName: true,
      showColorCode: true,
      copyPasteBehavior: const ColorPickerCopyPasteBehavior(
        longPressMenu: true,
      ),
      materialNameTextStyle: Theme.of(context).textTheme.bodySmall,
      colorNameTextStyle: Theme.of(context).textTheme.bodySmall,
      colorCodeTextStyle: Theme.of(context).textTheme.bodyMedium,
      colorCodePrefixStyle: Theme.of(context).textTheme.bodySmall,
      selectedPickerTypeColor: Theme.of(context).colorScheme.primary,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: true,
        ColorPickerType.bw: false,
        ColorPickerType.custom: true,
        ColorPickerType.wheel: true,
      },
      customColorSwatchesAndNames: colorsNameMap,
    ).showPickerDialog(
      context,
      actionsPadding: const EdgeInsets.all(16),
      constraints:
          const BoxConstraints(minHeight: 480, minWidth: 300, maxWidth: 320),
    );
  }

  void _showAddCategoryBottomSheet(BuildContext context) {
    Color dialogPickerColorLocal = dialogPickerColor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _addCategoryformKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Add new Category',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _categoryTextController,
                        decoration:
                            const InputDecoration(labelText: 'Category Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter category name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      ListTile(
                        title: const Text('Category Color'),
                        subtitle: Text(
                          ColorTools.nameThatColor(dialogPickerColorLocal),
                        ),
                        trailing: ColorIndicator(
                          width: 44,
                          height: 44,
                          borderRadius: 4,
                          color: dialogPickerColorLocal,
                          onSelectFocus: false,
                          onSelect: () async {
                            final Color colorBeforeDialog =
                                dialogPickerColorLocal;
                            if (await colorPickerDialog()) {
                              setState(() {
                                dialogPickerColorLocal = dialogPickerColor;
                              });
                            } else {
                              setState(() {
                                dialogPickerColorLocal = colorBeforeDialog;
                              });
                            }
                          },
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _addCategory(dialogPickerColorLocal),
                        child: const Text('Add Category'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Todo'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategoryBottomSheet(context),
        icon: const FaIcon(FontAwesomeIcons.tag),
        label: const Text('Add Category'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _todoTextController,
                decoration: const InputDecoration(labelText: 'Todo Text'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter todo text';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              const Text('Select Date:'),
              InkWell(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null && picked != _selectedDate) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
                child: Text(
                  '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}',
                  style: const TextStyle(fontSize: 18.0),
                ),
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                  });
                },
                value: _category.isNotEmpty ? _category : null,
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<int>(
                value: _priority,
                onChanged: (value) {
                  setState(() {
                    _priority = value!;
                  });
                },
                items: _priorities.map((int priority) {
                  return DropdownMenuItem<int>(
                    value: priority,
                    child: Text(priorityLabels[priority] ?? 'Unknown'),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Priority'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _addTodo,
                child: const Text('Add Todo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
