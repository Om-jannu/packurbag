import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CategoryItemShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          color: Colors.white,
        ),
      ),
    );
  }
}
