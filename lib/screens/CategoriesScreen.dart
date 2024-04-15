import 'dart:convert';
import 'dart:io';

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../components/CategoryItemShimmer.dart';
import '../components/GlobalSnackbar.dart';
import '../main.dart';
import '../models/category.dart';
import 'todoListPage.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<CategoryData> _categories = [];
  List<CategoryData> _filteredCategories = [];
  late Color dialogPickerColor;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
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

  final GlobalKey<FormState> _addCategoryformKey = GlobalKey<FormState>();
  final TextEditingController _categoryTextController = TextEditingController();
  @override
  void initState() {
    super.initState();
    dialogPickerColor = Colors.red;
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
        final category = Category.fromJson(data);
        print(category.toJson());
        if (category.success ?? false) {
          setState(() {
            _categories = category.categoryData ?? [];
            if (_categories.isEmpty) {
              // If no categories are fetched, add predefined categories to the database
              _addPredefinedCategories(userId);
            }
            _filteredCategories = _categories;
          });
        } else {
          if (mounted) {
            GlobalSnackbar.show(
                context, category.message ?? 'Failed to fetch categories');
          }
        }
      } else {
        if (mounted) {
          GlobalSnackbar.show(context, 'Failed to fetch categories');
        }
      }
    } catch (e) {
      print('Error: $e');
      if (e is SocketException) {
        if (mounted) {
          GlobalSnackbar.show(context,
              'Connection error: Please check your internet connection.');
        }
      } else {
        if (mounted) {
          GlobalSnackbar.show(
              context, 'An error occurred while fetching categories');
        }
      }
    }
  }

  Future<void> _addPredefinedCategories(String userId) async {
    try {
      final List<CategoryData> predefinedCategories =
          _getPredefinedCategories();
      for (final category in predefinedCategories) {
        final response = await http.post(
          Uri.parse('$serverIp/categories/$userId'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'categoryName': category.categoryName,
            'categoryColor': category.categoryColor,
          }),
        );
        if (response.statusCode == 201) {
          print('Predefined category added: ${category.categoryName}');
        } else {
          print('Failed to add predefined category: ${category.categoryName}');
        }
      }
      // Fetch categories again after adding predefined categories
      _fetchCategories();
    } catch (e) {
      print('Error adding predefined categories: $e');
    }
  }

  List<CategoryData> _getPredefinedCategories() {
    List<CategoryData> predefinedCategories = [
      CategoryData(
        categoryName: 'Birthdays',
        categoryColor: 'FF5733', // Example color (orange)
        todoCount: 0,
      ),
      CategoryData(
        categoryName: 'Meetings',
        categoryColor: '3366FF', // Example color (blue)
        todoCount: 0,
      ),
      CategoryData(
        categoryName: 'Shopping',
        categoryColor: 'FFD700', // Example color (gold)
        todoCount: 0,
      ),
      CategoryData(
        categoryName: 'Exercise',
        categoryColor: '00FF00', // Example color (green)
        todoCount: 0,
      ),
      CategoryData(
        categoryName: 'Events',
        categoryColor: 'FF1493', // Example color (deep pink)
        todoCount: 0,
      ),
      CategoryData(
        categoryName: 'Exams',
        categoryColor: '9932CC', // Example color (dark orchid)
        todoCount: 0,
      ),
      CategoryData(
        categoryName: 'Reading',
        categoryColor: '4169E1', // Example color (royal blue)
        todoCount: 0,
      ),
      CategoryData(
        categoryName: 'Savings',
        categoryColor: 'FFA500', // Example color (orange)
        todoCount: 0,
      ),
      CategoryData(
        categoryName: 'Bills',
        categoryColor: 'FF4500', // Example color (orangered)
        todoCount: 0,
      ),
      CategoryData(
        categoryName: 'Trips',
        categoryColor: 'FF6347', // Example color (tomato)
        todoCount: 0,
      ),
    ];

    return predefinedCategories;
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
                        onPressed: () => _addCategory(
                            _categoryTextController.text,
                            dialogPickerColorLocal),
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

  Future<void> _addCategory(
      String categoryText, Color dialogPickerColorLocal) async {
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
            'categoryName': categoryText,
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

  Widget _buildCategoryCard(CategoryData category) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TodoListPage(category: category),
          ),
        );
      },
      onLongPress: () {
        _showEditDeleteBottomSheet(context, category);
      },
      child: Card(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _parseColor(category.categoryColor))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                category.categoryName.capitalizeMaybeNull ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              // Display circular progress indicator with todo count inside
              Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 8,
                    value: category.todoCount != 0
                        ? category.todoCompleted! / category.todoCount!
                        : 0,
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        _parseColor(category.categoryColor)),
                  ),
                  Text(
                    category.todoCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.check,
                    size: 16,
                    color: _parseColor(category.categoryColor),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tasks ${category.todoCompleted}/${category.todoCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching ? _buildSearchField() : const Text('Categories'),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        actions: _buildAppBarActions(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: _categories.isEmpty // Check if categories are empty
          ? _buildShimmerLoading() // Show shimmer loading effect
          : Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                    ),
                    itemCount: _filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = _filteredCategories[index];
                      return _buildCategoryCard(category);
                    },
                  ),
                ),
              ],
            ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildShimmerLoading() {
  return GridView.builder(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 10.0,
      mainAxisSpacing: 10.0,
    ),
    itemCount: 10, // Number of shimmer items
    itemBuilder: (context, index) {
      return const CategoryItemShimmer(); // Use CategoryItemShimmer here
    },
  );
}

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Search categories',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white60),
      ),
      style: const TextStyle(color: Colors.white),
      onChanged: _filterCategories,
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_isSearching) {
      return [
        IconButton(
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchController.clear();
              _filteredCategories = _categories;
            });
          },
          icon: const Icon(Icons.close),
        ),
      ];
    } else {
      return [
        IconButton(
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
          },
          icon: const Icon(Icons.search),
        ),
        IconButton(
          onPressed: () => _showAddCategoryBottomSheet(context),
          icon: const Icon(Icons.add),
        ),
      ];
    }
  }

  void _filterCategories(String query) {
    setState(() {
      _filteredCategories = _categories
          .where((category) => category.categoryName!
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
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

  void _showEditDeleteBottomSheet(BuildContext context, CategoryData category) {
    TextEditingController nameController =
        TextEditingController(text: category.categoryName);
    Color dialogPickerColorLocal = _parseColor(category.categoryColor);

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Edit Category',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: 'Category Name'),
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
                        if (await colorPickerDialog()) {
                          setState(() {
                            dialogPickerColorLocal = dialogPickerColor;
                          });
                        } else {
                          setState(() {
                            dialogPickerColorLocal =
                                _parseColor(category.categoryColor);
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Perform edit operation
                          _editCategory(category, nameController.text,
                              dialogPickerColorLocal.hex);
                          Navigator.pop(context); // Close bottom sheet
                        },
                        child: const Text('Save'),
                      ),
                      const SizedBox(width: 8.0),
                      ElevatedButton(
                        onPressed: () {
                          // Perform delete operation
                          _deleteCategory(category);
                          Navigator.pop(context); // Close bottom sheet
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _editCategory(
      CategoryData category, String newName, String newColor) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';
      final categoryName = category.categoryName ?? '';


      final response = await http.put(
        Uri.parse('$serverIp/categories/$userId/$categoryName'),
        body:
            jsonEncode({'newCategoryName': newName, 'categoryColor': newColor}),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          category.categoryName = newName;
          category.categoryColor = newColor;
        });
        if (mounted) {
          GlobalSnackbar.show(context, 'Category updated successfully',
              success: true);
        }
      } else {
        if (mounted) {
          GlobalSnackbar.show(context, 'Failed to update category');
        }
      }
    } catch (e) {
      print('Error: $e');
      if (mounted) {
        GlobalSnackbar.show(
            context, 'An error occurred while updating category');
      }
    }
  }

  void _deleteCategory(CategoryData category) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';
      final categoryName = category.categoryName ?? '';

      final response = await http.delete(
        Uri.parse('$serverIp/categories/$userId/$categoryName'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _categories.remove(category);
        });
        if (mounted) {
          GlobalSnackbar.show(context, 'Category deleted successfully',
              success: true);
        }
      } else {
        if (mounted) {
          GlobalSnackbar.show(context, 'Failed to delete category');
        }
      }
    } catch (e) {
      print('Error: $e');
      if (mounted) {
        GlobalSnackbar.show(
            context, 'An error occurred while deleting category');
      }
    }
  }

  Color _parseColor(String? colorHex) {
    if (colorHex != null && colorHex.isNotEmpty) {
      return Color(int.parse('0xFF$colorHex'));
    }
    return Colors.grey;
  }
}
