import 'package:flutter/material.dart';

import 'loading_shimmer_card.dart';

/// Rough shape of the home dashboard (next-trip card, stat row, calendar) —
/// shown in place of a spinner while trips load, so the page doesn't jump
/// from an empty center-spinner straight to a full page of content.
class HomeDashboardShimmer extends StatelessWidget {
  const HomeDashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const LoadingShimmerCard(height: 110),
        const SizedBox(height: 12),
        const LoadingShimmerCard(height: 64),
        const SizedBox(height: 16),
        Row(
          children: const [
            Expanded(child: LoadingShimmerCard(height: 84)),
            SizedBox(width: 12),
            Expanded(child: LoadingShimmerCard(height: 84)),
            SizedBox(width: 12),
            Expanded(child: LoadingShimmerCard(height: 84)),
          ],
        ),
        const SizedBox(height: 16),
        const LoadingShimmerCard(height: 340, borderRadius: 24),
      ],
    );
  }
}
