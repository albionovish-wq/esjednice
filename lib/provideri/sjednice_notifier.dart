import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esjednice/modeli/sjednica.dart';
import 'package:uuid/uuid.dart';

/// Data class for attendance records
class PrisutnostRecord {
  final String korisnikId;
  final String prezentacija; // "Planirana", "Prisutan", "Izostao"
  final DateTime vrijeme;

  PrisutnostRecord({
    required this.korisnikId,
    required this.prezentacija,
    required this.vrijeme,
  });

  Map<String, dynamic> toMap() {
    return {
      'korisnikId': korisnikId,
      'prezentacija': prezentacija,
      'vrijeme': Timestamp.fromDate(vrijeme),
    };
  }
}

/// Data class for agenda items
class DnevniRedItem {
  final String id;
  final int redniBroj;
  final String naslov;
  final String opis;
  final String vrsta; // "obavijest", "glasanje", "rasprava"
  final String? glasanjeId; // if vrsta == "glasanje"

  DnevniRedItem({
    required this.id,
    required this.redniBroj,
    required this.naslov,
    required this.opis,
    required this.vrsta,
    this.glasanjeId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'redni_broj': redniBroj,
      'naslov': naslov,
      'opis': opis,
      'vrsta': vrsta,
      if (glasanjeId != null) 'glasanjeId': glasanjeId,
    };
  }
}

class SjedniceNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SjedniceNotifier() : super(const AsyncValue.data(null));

  /// Create a new meeting
  Future<String> createSjednica({
    required String naslov,
    required String opis,
    required String grupa,
    required DateTime vrijeme,
    required String lokacija,
    required String sazivac,
    String? zapisnicar,
    List<DnevniRedItem>? dnevniRed,
  }) async {
    state = const AsyncValue.loading();
    try {
      final sjednicaId = const Uuid().v4();

      final sjednica = Sjednica(
        id: sjednicaId,
        naslov: naslov,
        opis: opis,
        grupa: grupa,
        vrijeme: vrijeme,
        lokacija: lokacija,
        status: SjednicaStatus.planned,
        sazivac: sazivac,
        zapisnicar: zapisnicar,
        dnevniRed: dnevniRed ?? [],
        prisutnost: [],
        dokumenti: [],
        created: DateTime.now(),
        updated: null,
      );

      await _firestore
          .collection('sjednice')
          .doc(sjednicaId)
          .set(sjednica.toFirestore());

      state = const AsyncValue.data(null);
      return sjednicaId;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Update meeting details
  Future<void> updateSjednica({
    required String sjednicaId,
    required String naslov,
    required String opis,
    required String grupa,
    required DateTime vrijeme,
    required String lokacija,
    String? zapisnicar,
    List<DnevniRedItem>? dnevniRed,
  }) async {
    state = const AsyncValue.loading();
    try {
      final updateData = {
        'naslov': naslov,
        'opis': opis,
        'grupa': grupa,
        'vrijeme': Timestamp.fromDate(vrijeme),
        'lokacija': lokacija,
        'zapisnicar': zapisnicar,
        'updated': FieldValue.serverTimestamp(),
      };

      if (dnevniRed != null) {
        updateData['dnevniRed'] =
            dnevniRed.map((item) => item.toMap()).toList();
      }

      await _firestore.collection('sjednice').doc(sjednicaId).update(updateData);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Update meeting status
  Future<void> updateStatus({
    required String sjednicaId,
    required SjednicaStatus status,
  }) async {
    state = const AsyncValue.loading();
    try {
      final statusString = status.toString().split('.').last;

      await _firestore.collection('sjednice').doc(sjednicaId).update({
        'status': statusString,
        'updated': FieldValue.serverTimestamp(),
      });

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Add or update attendance for a user
  Future<void> updateAttendance({
    required String sjednicaId,
    required String korisnikId,
    required String prezentacija, // "Planirana", "Prisutan", "Izostao"
  }) async {
    state = const AsyncValue.loading();
    try {
      // Get current attendance
      final doc = await _firestore.collection('sjednice').doc(sjednicaId).get();
      if (!doc.exists) {
        throw Exception('Meeting not found');
      }

      final sjednica = Sjednica.fromFirestore(doc);
      final prisutnost = List<Map<String, dynamic>>.from(
        sjednica.prisutnost.cast<Map<String, dynamic>>(),
      );

      // Remove existing record for this user
      prisutnost.removeWhere((p) => p['korisnikId'] == korisnikId);

      // Add new record
      prisutnost.add({
        'korisnikId': korisnikId,
        'prezentacija': prezentacija,
        'vrijeme': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('sjednice').doc(sjednicaId).update({
        'prisutnost': prisutnost,
        'updated': FieldValue.serverTimestamp(),
      });

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Add agenda item to meeting
  Future<void> addAgendaItem({
    required String sjednicaId,
    required String naslov,
    required String opis,
    required String vrsta,
    String? glasanjeId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final doc = await _firestore.collection('sjednice').doc(sjednicaId).get();
      if (!doc.exists) {
        throw Exception('Meeting not found');
      }

      final sjednica = Sjednica.fromFirestore(doc);
      final dnevniRed =
          List<Map<String, dynamic>>.from(sjednica.dnevniRed.cast<Map<String, dynamic>>());

      // Calculate next redni_broj
      final maxRedniBroj = dnevniRed.isEmpty
          ? 0
          : (dnevniRed.map((item) => item['redni_broj'] as int).reduce((a, b) => a > b ? a : b));

      final newItem = {
        'id': const Uuid().v4(),
        'redni_broj': maxRedniBroj + 1,
        'naslov': naslov,
        'opis': opis,
        'vrsta': vrsta,
        if (glasanjeId != null) 'glasanjeId': glasanjeId,
      };

      dnevniRed.add(newItem);

      await _firestore.collection('sjednice').doc(sjednicaId).update({
        'dnevniRed': dnevniRed,
        'updated': FieldValue.serverTimestamp(),
      });

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Remove agenda item from meeting
  Future<void> removeAgendaItem({
    required String sjednicaId,
    required String itemId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final doc = await _firestore.collection('sjednice').doc(sjednicaId).get();
      if (!doc.exists) {
        throw Exception('Meeting not found');
      }

      final sjednica = Sjednica.fromFirestore(doc);
      final dnevniRed =
          List<Map<String, dynamic>>.from(sjednica.dnevniRed.cast<Map<String, dynamic>>());

      // Remove item
      dnevniRed.removeWhere((item) => item['id'] == itemId);

      // Reorder redni_broj
      for (int i = 0; i < dnevniRed.length; i++) {
        dnevniRed[i]['redni_broj'] = i + 1;
      }

      await _firestore.collection('sjednice').doc(sjednicaId).update({
        'dnevniRed': dnevniRed,
        'updated': FieldValue.serverTimestamp(),
      });

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Delete a meeting
  Future<void> deleteSjednica({
    required String sjednicaId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _firestore.collection('sjednice').doc(sjednicaId).delete();

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Add document reference to meeting
  Future<void> addDocumentReference({
    required String sjednicaId,
    required String dokumentId,
    required String naziv,
    required String tip,
    required int veličina,
    required String putanja,
    required String urlPreuzimanja,
    required String kreatoriId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final dokument = {
        'id': dokumentId,
        'naziv': naziv,
        'tip': tip,
        'veličina': veličina,
        'putanja': putanja,
        'urlPreuzimanja': urlPreuzimanja,
        'kreatoriId': kreatoriId,
        'vrijeme': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('sjednice').doc(sjednicaId).update({
        'dokumenti': FieldValue.arrayUnion([dokument]),
        'updated': FieldValue.serverTimestamp(),
      });

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Remove document reference from meeting
  Future<void> removeDocumentReference({
    required String sjednicaId,
    required String dokumentId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final doc = await _firestore.collection('sjednice').doc(sjednicaId).get();
      if (!doc.exists) {
        throw Exception('Meeting not found');
      }

      final sjednica = Sjednica.fromFirestore(doc);
      final dokumenti = List<Map<String, dynamic>>.from(
        sjednica.dokumenti.cast<Map<String, dynamic>>(),
      );

      // Remove document
      dokumenti.removeWhere((d) => d['id'] == dokumentId);

      await _firestore.collection('sjednice').doc(sjednicaId).update({
        'dokumenti': dokumenti,
        'updated': FieldValue.serverTimestamp(),
      });

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final sjedniceNotifierProvider =
    StateNotifierProvider<SjedniceNotifier, AsyncValue<void>>((ref) {
  return SjedniceNotifier();
});
