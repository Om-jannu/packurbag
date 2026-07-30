import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'repository_providers.dart';

/// Local-only receipt photos for an expense. Keyed by (userId, expenseId).
final expenseReceiptsProvider = FutureProvider.family<List<String>,
    ({String userId, String expenseId})>((ref, ids) {
  return ref
      .watch(expenseReceiptsRepositoryProvider)
      .fetchReceiptPhotos(userId: ids.userId, expenseId: ids.expenseId);
});
