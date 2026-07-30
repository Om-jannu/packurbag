import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Receipt photos for expenses never leave the device — the expense record
/// itself syncs to the backend, but its attached bill photos are kept purely
/// local, correlated by the expense's (server-assigned) id, mirroring
/// [DocumentsRepository]'s storage pattern.
class ExpenseReceiptsRepository {
  String _prefsKey(String userId) => 'expense_receipts_$userId';

  Future<List<String>> fetchReceiptPhotos({
    required String userId,
    required String expenseId,
  }) async {
    final map = await _readMap(userId);
    return map[expenseId] ?? const [];
  }

  Future<void> saveReceiptPhotos({
    required String userId,
    required String expenseId,
    required List<String> existingPhotoPaths,
    List<XFile> newPhotos = const [],
  }) async {
    final newPaths = await Future.wait(newPhotos.map(_persistImage));
    final photoPaths = [...existingPhotoPaths, ...newPaths];
    final map = await _readMap(userId);
    map[expenseId] = photoPaths;
    await _writeMap(userId, map);
  }

  Future<void> deleteReceiptPhotos({
    required String userId,
    required String expenseId,
  }) async {
    final map = await _readMap(userId);
    map.remove(expenseId);
    await _writeMap(userId, map);
  }

  Future<Map<String, List<String>>> _readMap(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey(userId));
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, (value as List<dynamic>).cast<String>()));
  }

  Future<void> _writeMap(String userId, Map<String, List<String>> map) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey(userId), jsonEncode(map));
  }

  Future<String> _persistImage(XFile picked) async {
    if (kIsWeb) return picked.path;
    final docsDir = await getApplicationDocumentsDirectory();
    final receiptsFolder = Directory('${docsDir.path}/expense_receipts');
    if (!await receiptsFolder.exists()) {
      await receiptsFolder.create(recursive: true);
    }
    final fileName = '${DateTime.now().microsecondsSinceEpoch}_${picked.name}';
    final saved = await File(picked.path).copy('${receiptsFolder.path}/$fileName');
    return saved.path;
  }
}
