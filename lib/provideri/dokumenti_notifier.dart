import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DokumentiNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DokumentiNotifier() : super(const AsyncValue.data(null));

  /// Upload meeting minutes document to Firebase Storage and link to meeting
  Future<String> uploadMinutes({
    required String sjednicaId,
    required File file,
    required String fileName,
    required String korisnikId,
  }) async {
    state = const AsyncValue.loading();
    try {
      // Validate file
      if (!_isValidDocument(file.path)) {
        throw Exception('Nepodržan format datoteke. Koristite PDF ili DOCX.');
      }

      final fileSize = file.lengthSync();
      if (fileSize > 50 * 1024 * 1024) { // 50 MB limit
        throw Exception('Datoteka je prevelika. Maksimalno 50 MB.');
      }

      // Upload file to Firebase Storage
      final storagePath = 'sjednice/$sjednicaId/dokumenti/$fileName';
      final reference = _storage.ref(storagePath);
      
      final uploadTask = reference.putFile(file);
      await uploadTask;

      // Get download URL
      final downloadUrl = await reference.getDownloadURL();

      // Create document record in Firestore
      final dokumentId = DateTime.now().millisecondsSinceEpoch.toString();
      final dokumentData = {
        'id': dokumentId,
        'naziv': fileName,
        'tip': _getFileType(file.path),
        'veličina': fileSize,
        'putanja': storagePath,
        'urlPreuzimanja': downloadUrl,
        'kreatoriId': korisnikId,
        'vrijeme': FieldValue.serverTimestamp(),
      };

      // Add document reference to meeting
      await _firestore.collection('sjednice').doc(sjednicaId).update({
        'dokumenti': FieldValue.arrayUnion([dokumentData]),
        'updated': FieldValue.serverTimestamp(),
      });

      state = const AsyncValue.data(null);
      return downloadUrl;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Delete a document from meeting
  Future<void> deleteDocument({
    required String sjednicaId,
    required String dokumentId,
    required String storagePath,
  }) async {
    state = const AsyncValue.loading();
    try {
      // Delete from Storage
      await _storage.ref(storagePath).delete();

      // Remove from Firestore
      final doc = await _firestore.collection('sjednice').doc(sjednicaId).get();
      if (doc.exists) {
        final dokumenti = List<Map<String, dynamic>>.from(
          (doc.data()?['dokumenti'] as List? ?? [])
              .cast<Map<String, dynamic>>(),
        );
        dokumenti.removeWhere((d) => d['id'] == dokumentId);

        await _firestore.collection('sjednice').doc(sjednicaId).update({
          'dokumenti': dokumenti,
          'updated': FieldValue.serverTimestamp(),
        });
      }

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Get download URL for a document
  Future<String> getDownloadUrl({
    required String storagePath,
  }) async {
    try {
      return await _storage.ref(storagePath).getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  // Helper method to validate document type
  bool _isValidDocument(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return ['pdf', 'docx', 'doc', 'txt'].contains(extension);
  }

  // Helper method to get file type
  String _getFileType(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return extension;
  }
}

final dokumentiNotifierProvider =
    StateNotifierProvider<DokumentiNotifier, AsyncValue<void>>((ref) {
  return DokumentiNotifier();
});
