import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/travel_document.dart';

/// Travel documents never leave the device — no backend calls here. Metadata
/// is kept in SharedPreferences; photos are copied into the app's documents
/// directory on Android/iOS (on web there's no persistent filesystem, so the
/// picked image's blob URL is kept as-is for the session).
class DocumentsRepository {
  String _prefsKey(String userId) => 'travel_documents_$userId';

  Future<List<TravelDocument>> fetchDocuments({
    required String userId,
    required String tripId,
  }) async {
    final documents = await fetchAllDocuments(userId: userId);
    return documents.where((doc) => doc.tripId == tripId).toList();
  }

  Future<List<TravelDocument>> fetchAllDocuments({required String userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey(userId)) ?? [];
    return raw
        .map((entry) => TravelDocument.fromJson(
            jsonDecode(entry) as Map<String, dynamic>))
        .toList();
  }

  Future<TravelDocument> addDocument({
    required String userId,
    required String tripId,
    required String title,
    String notes = '',
    List<XFile> photos = const [],
  }) async {
    final imagePaths = await Future.wait(photos.map(_persistImage));
    final document = TravelDocument(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      tripId: tripId,
      title: title,
      notes: notes,
      imagePaths: imagePaths,
    );
    await _appendAll(userId, [document]);
    return document;
  }

  /// [existingPhotoPaths] are the already-persisted photos the user chose to
  /// keep (already excludes anything they removed in the editor);
  /// [newPhotos] are freshly picked and still need persisting.
  Future<void> updateDocument({
    required String userId,
    required String documentId,
    required String title,
    String notes = '',
    List<String> existingPhotoPaths = const [],
    List<XFile> newPhotos = const [],
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey(userId)) ?? [];
    final newPaths = await Future.wait(newPhotos.map(_persistImage));
    final imagePaths = [...existingPhotoPaths, ...newPaths];
    final updated = <String>[];
    for (final entry in raw) {
      final doc = TravelDocument.fromJson(jsonDecode(entry) as Map<String, dynamic>);
      if (doc.id != documentId) {
        updated.add(entry);
        continue;
      }
      await _deleteFiles(doc.imagePaths.where((p) => !existingPhotoPaths.contains(p)));
      final edited = doc.copyWith(title: title, notes: notes, imagePaths: imagePaths);
      updated.add(jsonEncode(edited.toJson()));
    }
    await prefs.setStringList(_prefsKey(userId), updated);
  }

  Future<void> deleteDocument({
    required String userId,
    required String documentId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey(userId)) ?? [];
    final remaining = <String>[];
    for (final entry in raw) {
      final doc = TravelDocument.fromJson(jsonDecode(entry) as Map<String, dynamic>);
      if (doc.id == documentId) {
        await _deleteFiles(doc.imagePaths);
      } else {
        remaining.add(entry);
      }
    }
    await prefs.setStringList(_prefsKey(userId), remaining);
  }

  /// Called when a whole trip is deleted, so its photo-journal entries don't
  /// stay orphaned in this user's SharedPreferences list forever.
  Future<void> deleteDocumentsForTrip({
    required String userId,
    required String tripId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey(userId)) ?? [];
    final remaining = <String>[];
    for (final entry in raw) {
      final doc = TravelDocument.fromJson(jsonDecode(entry) as Map<String, dynamic>);
      if (doc.tripId == tripId) {
        await _deleteFiles(doc.imagePaths);
      } else {
        remaining.add(entry);
      }
    }
    await prefs.setStringList(_prefsKey(userId), remaining);
  }

  Future<void> _appendAll(String userId, List<TravelDocument> documents) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey(userId)) ?? [];
    raw.addAll(documents.map((d) => jsonEncode(d.toJson())));
    await prefs.setStringList(_prefsKey(userId), raw);
  }

  Future<String> _persistImage(XFile picked) async {
    if (kIsWeb) return picked.path;
    final docsDir = await getApplicationDocumentsDirectory();
    final documentsFolder = Directory('${docsDir.path}/travel_documents');
    if (!await documentsFolder.exists()) {
      await documentsFolder.create(recursive: true);
    }
    final fileName = '${DateTime.now().microsecondsSinceEpoch}_${picked.name}';
    final saved = await File(picked.path).copy('${documentsFolder.path}/$fileName');
    return saved.path;
  }

  /// Best-effort cleanup of persisted files backing removed/deleted photos.
  /// No-op on web (paths are blob: URLs, nothing to delete on the device) and
  /// swallows errors — a stale metadata entry pointing at an already-missing
  /// file must never block the delete the user actually asked for.
  Future<void> _deleteFiles(Iterable<String> paths) async {
    if (kIsWeb) return;
    for (final path in paths) {
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
      } catch (_) {
        // Best-effort — a missing/locked file shouldn't block deletion.
      }
    }
  }
}
