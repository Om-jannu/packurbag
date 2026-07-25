import 'package:flutter/material.dart';

/// Parses the app's stored category-color hex strings (e.g. `FF5733`, no
/// leading `#`). Consolidates the `_parseColor` helper that used to be
/// copy-pasted in HomeScreen, CategoriesScreen, and TodoListPage.
Color parseCategoryColor(String? colorHex, {Color fallback = Colors.grey}) {
  if (colorHex == null || colorHex.isEmpty) return fallback;
  final cleaned = colorHex.replaceFirst('#', '');
  return Color(int.tryParse('0xFF$cleaned') ?? fallback.toARGB32());
}

class CategoryColorDot extends StatelessWidget {
  const CategoryColorDot({super.key, required this.colorHex, this.size = 14});

  final String? colorHex;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: parseCategoryColor(colorHex),
        shape: BoxShape.circle,
      ),
    );
  }
}
