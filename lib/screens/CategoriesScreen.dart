// import 'dart:convert';
// import 'package:flex_color_picker/flex_color_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:pub/main.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../components/CategoryItem.dart';
// import '../components/CategoryItemShimmer.dart';
// import 'todoListScreen.dart';

// class CategoryWithTodoCount {
//   final String name;
//   final int todoCount;

//   CategoryWithTodoCount({
//     required this.name,
//     required this.todoCount,
//   });
// }

// class CategoriesScreen extends StatefulWidget {
//   const CategoriesScreen({Key? key, var serverIp}) : super(key: key);

//   @override
//   State<CategoriesScreen> createState() => _CategoriesScreenState();
// }

// class _CategoriesScreenState extends State<CategoriesScreen> {
//   List<CategoryWithTodoCount> categories = [];
//   bool isLoading = true;
//   bool _isMounted = false;
//   late Color dialogPickerColor;
//   final GlobalKey<FormState> _addCategoryformKey = GlobalKey<FormState>();
//   @override
//   void initState() {
//     super.initState();
//     _isMounted = true;
//     addCategoryToDatabase("premade-Birthdays");
//     addCategoryToDatabase("premade-Shopping");
//     addCategoryToDatabase("premade-Exercise");
//     addCategoryToDatabase("premade-Events");
//     addCategoryToDatabase("premade-Meetings");
//     addCategoryToDatabase("premade-Exams");
//     addCategoryToDatabase("premade-Reading");
//     addCategoryToDatabase("premade-Savings");
//     addCategoryToDatabase("premade-Bills");
//     addCategoryToDatabase("premade-Trips");
//     _loadCategories();
//   }

//   @override
//   void dispose() {
//     _isMounted = false;
//     super.dispose();
//   }

//   Future<void> _loadCategories() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userId = prefs.getString('userId') ?? '';

//       final response = await http.get(
//         Uri.parse('http://$serverIp:5000/categories/$userId'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       if (_isMounted && response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         print(data);
//         if (data['categories'] != null && data['categories'] is List) {
//           List<CategoryWithTodoCount> updatedCategories =
//               List<String>.from(data['categories']).map((category) {
//             int todoCount = 0;

//             // Find the corresponding todoCount in the response
//             var categoryWithCount = (data['categorywithcount'] as List)
//                 .firstWhere((item) => item['categories'] == category,
//                     orElse: () => null);

//             if (categoryWithCount != null) {
//               todoCount = categoryWithCount['todoCount'];
//             }

//             return CategoryWithTodoCount(name: category, todoCount: todoCount);
//           }).toList();

//           if (_isMounted) {
//             setState(() {
//               categories = updatedCategories;
//             });
//           }
//         } else {
//           print('No categories found for this user');
//         }
//       } else {
//         print(
//             'Failed to fetch categories. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error while fetching categories: $e');
//     } finally {
//       if (_isMounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> _refreshCategories() async {
//     await Future.delayed(const Duration(milliseconds: 500));
//     await _loadCategories();
//   }

//   Future<void> addCategoryToDatabase(String category) async {
//     final prefs = await SharedPreferences.getInstance();
//     final username = prefs.getString('username') ?? '';

//     final response = await http.post(
//       Uri.parse('http://$serverIp:5000/add_category'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'username': username,
//         'category': category,
//       }),
//     );

//     if (response.statusCode == 200) {
//       print('Category sdfdggagrsa added to the database');
//       _loadCategories();
//     } else {
//       print('Failed to add category to the database');
//     }
//   }

//   Future<void> deleteCategory(String category) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final username = prefs.getString('username') ?? '';

//       final response = await http.post(
//         Uri.parse('http://$serverIp:5000/delete_category'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'username': username,
//           'category': category,
//         }),
//       );

//       if (response.statusCode == 200) {
//         print('Category deleted from the database');
//         _loadCategories();
//       } else {
//         print('Failed to delete category from the database');
//       }
//     } catch (e) {
//       print('Error while deleting category: $e');
//     }
//   }

//   Future<void> editCategoryInDatabase(
//       String oldCategory, String newCategory) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final username = prefs.getString('username') ?? '';

//       final response = await http.put(
//         Uri.parse('http://$serverIp:5000/edit_category'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'username': username,
//           'oldCategory': oldCategory,
//           'newCategory': newCategory,
//         }),
//       );

//       if (response.statusCode == 200) {
//         print('Category edited in the database');
//         _loadCategories();
//       } else {
//         print('Failed to edit category in the database');
//       }
//     } catch (e) {
//       print('Error while editing category: $e');
//     }
//   }

//   Future<void> showAddCategoryDialog(BuildContext context) async {
//     TextEditingController categoryController = TextEditingController();

//     return showDialog<void>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Add New Category'),
//           content: TextField(
//             controller: categoryController,
//             decoration: const InputDecoration(hintText: 'Enter category name'),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 addCategoryToDatabase(categoryController.text);
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Add'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> showEditCategoryDialog(
//       BuildContext context, String category) async {
//     TextEditingController categoryController =
//         TextEditingController(text: category);

//     return showDialog<void>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Edit Category'),
//           content: TextField(
//             controller: categoryController,
//             decoration:
//                 const InputDecoration(hintText: 'Enter new category name'),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 String newCategory = categoryController.text;
//                 editCategoryInDatabase(category, newCategory);
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Edit'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> showDeleteConfirmationDialog(
//       BuildContext context, String category) async {
//     return showDialog<void>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Delete Category'),
//           content: const Text('Are you sure you want to delete this category?'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 deleteCategory(category);
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Categories'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: () => _showAddCategoryBottomSheet(context),
//           ),
//         ],
//       ),
//       body: _buildCategoryList(),
//     );
//   }

//   Widget _buildCategoryList() {
//     return RefreshIndicator(
//       onRefresh: _refreshCategories,
//       child: isLoading
//           ? _buildShimmer()
//           : categories.isEmpty
//               ? _buildNoCategories()
//               : Container(
//                   padding: const EdgeInsets.all(10),
//                   child: GridView.builder(
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       crossAxisSpacing: 10,
//                       mainAxisSpacing: 10,
//                     ),
//                     itemCount: categories.length,
//                     itemBuilder: (context, index) {
//                       return CategoryItem(
//                         category: categories[index].name,
//                         todoCount: categories[index].todoCount,
//                         onLongPress: () =>
//                             _showBottomSheet(context, categories[index].name),
//                         onTap: () =>
//                             _navigateToTodoList(categories[index].name),
//                       );
//                     },
//                   ),
//                 ),
//     );
//   }

//   void _showBottomSheet(BuildContext context, String category) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.edit),
//               title: const Text('Edit Category'),
//               onTap: () {
//                 Navigator.pop(context);
//                 showEditCategoryDialog(context, category);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.delete),
//               title: const Text('Delete Category'),
//               onTap: () {
//                 Navigator.pop(context);
//                 showDeleteConfirmationDialog(context, category);
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildShimmer() {
//     return Container(
//       padding: const EdgeInsets.all(10),
//       child: GridView.builder(
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           crossAxisSpacing: 10,
//           mainAxisSpacing: 10,
//         ),
//         itemCount: 8,
//         itemBuilder: (context, index) {
//           return const CategoryItemShimmer();
//         },
//       ),
//     );
//   }

//   Widget _buildNoCategories() {
//     return const Center(
//       child: Text('No categories added.'),
//     );
//   }

//   void _navigateToTodoList(String category) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => TodoListScreen(
//           category: category,
//           serverIp: serverIp,
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
  late Color dialogPickerColor;
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
          await http.get(Uri.parse('http://$serverIp:5000/categories/$userId'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final category = Category.fromJson(data);
        if (category.success ?? false) {
          setState(() {
            _categories = category.categoryData ?? [];
            if (_categories.isEmpty) {
              // If no categories are fetched, add predefined categories to the database
              _addPredefinedCategories(userId);
            }
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
          Uri.parse('http://$serverIp:5000/categories/$userId'),
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
      String _categoryText, Color dialogPickerColorLocal) async {
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
            'categoryName': _categoryText,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            onPressed: () => _showAddCategoryBottomSheet(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return InkWell(
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
            child: ListTile(
              title: Text(category.categoryName ?? ''),
              subtitle: Text('Todo Count: ${category.todoCount ?? 0}'),
              leading: Container(
                width: 24,
                height: 24,
                color: _parseColor(category.categoryColor),
              ),
            ),
          );
        },
      ),
    );
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
        Uri.parse('http://$serverIp:5000/categories/$userId/$categoryName'),
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
        Uri.parse('http://$serverIp:5000/categories/$userId/$categoryName'),
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
