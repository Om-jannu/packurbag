import 'dart:convert';
import 'dart:io';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../components/GlobalSnackbar.dart';
import '../main.dart';
import '../screens/HomeScreen.dart';
import '../utils.dart';

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
          await http.get(Uri.parse('$serverIp/categories/$userId'));

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
          Uri.parse('$serverIp/todos/$userId'),
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
          fetchTodos(userId, context);
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
          Uri.parse('$serverIp/categories/$userId'),
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
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Form(
                  key: _addCategoryformKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Add new Category',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _categoryTextController,
                        decoration: InputDecoration(
                          labelText: 'Category Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
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
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                        ),
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

  void _selectCategory(String category) {
    setState(() {
      _category = category;
    });
  }

  void _showCategoryBottomSheet(BuildContext context) {
    List<String> filteredCategories = _categories;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Select Category',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Search Category',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        filteredCategories = _categories
                            .where((category) => category
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredCategories.length,
                      itemBuilder: (BuildContext context, int index) {
                        final category = filteredCategories[index];
                        return ListTile(
                          title: Text(category.capitalize),
                          onTap: () {
                            _selectCategory(category);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPriorityBottomSheet(
      BuildContext context, Function(int) onPrioritySelected) {
    final List<int> filteredPriorities = List.from(_priorities);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Priority',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Search Priority',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    filteredPriorities.clear();
                    for (int priority in _priorities) {
                      if (priorityLabels[priority]!
                          .toLowerCase()
                          .contains(value.toLowerCase())) {
                        filteredPriorities.add(priority);
                      }
                    }
                  });
                },
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredPriorities.length,
                  itemBuilder: (BuildContext context, int index) {
                    final int priority = filteredPriorities[index];
                    return ListTile(
                      leading: _getPriorityIcon(priority),
                      title: Text(priorityLabels[priority] ?? 'Unknown'),
                      onTap: () {
                        onPrioritySelected(
                            priority); // Call the callback function
                        Navigator.pop(context);
                      },
                      selected: _priority == priority,
                      selectedTileColor:
                          Theme.of(context).primaryColor.withOpacity(0.2),
                    );
                  },
                ),
              ),
            ],
          ),
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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(50))),
        onPressed: () => _showAddCategoryBottomSheet(context),
        icon: const FaIcon(FontAwesomeIcons.layerGroup),
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
                decoration: const InputDecoration(
                  labelText: 'Todo Text',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter todo text';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              GestureDetector(
                onTap: () => _showCategoryBottomSheet(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _category.isNotEmpty
                        ? _category.capitalize
                        : 'Select Category',
                    style: TextStyle(
                      fontSize: 16.0,
                      color:
                          _category.isNotEmpty ? Colors.grey : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              GestureDetector(
                onTap: () => _showPriorityBottomSheet(context, (int priority) {
                  setState(() {
                    _priority = priority;
                  });
                }),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    children: [
                      _getPriorityIcon(_priority),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        priorityLabels[_priority].capitalizeMaybeNull!,
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Date',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  GestureDetector(
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
                    child: Chip(
                      label: Text(
                        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _addTodo,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text('Add Todo'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  FaIcon _getPriorityIcon(int priority) {
    switch (priority) {
      case 0:
        return const FaIcon(
          size: 15,
          FontAwesomeIcons.spinner,
          color: Colors.blueGrey,
        );
      case 1:
        return const FaIcon(
          size: 15,
          FontAwesomeIcons.anglesDown,
          color: Colors.blue,
        );
      case 2:
        return const FaIcon(
          size: 15,
          FontAwesomeIcons.water,
          color: Colors.yellow,
        );
      case 3:
        return const FaIcon(
          size: 15,
          FontAwesomeIcons.anglesUp,
          color: Colors.orange,
        );
      case 4:
        return const FaIcon(
          size: 15,
          FontAwesomeIcons.triangleExclamation,
          color: Colors.red,
        );
      default:
        return const FaIcon(
          FontAwesomeIcons.question,
          color: Colors.grey,
        );
    }
  }
}
