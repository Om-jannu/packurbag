// import 'package:flutter/material.dart';

// class CategoryItem extends StatelessWidget {
//   final String category;
//   final VoidCallback onDelete;
//   final VoidCallback onEdit;
//   final VoidCallback onTap;

//   const CategoryItem({
//     Key? key,
//     required this.category,
//     required this.onDelete,
//     required this.onEdit,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       child: Card(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(category),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.edit),
//                   onPressed: onEdit,
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.delete),
//                   onPressed: onDelete,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  final String category;
  final int todoCount;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onTap;

  const CategoryItem({
    Key? key,
    required this.category,
    required this.todoCount,
    required this.onDelete,
    required this.onEdit,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(category),
            Text('Todo Count: $todoCount'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
