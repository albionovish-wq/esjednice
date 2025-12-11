import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esjednice/modeli/glasanje.dart';
import 'package:uuid/uuid.dart';

class GlasanjaNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  GlasanjaNotifier() : super(const AsyncValue.data(null));

  Future<void> createGlasanje({
    required String sjednicaId,
    required String stavkaId,
    required String naslov,
    required String? opis,
    required String grupa,
    required List<String> opcije,
    required DateTime pocetneVrijeme,
    required DateTime krajnjeVrijeme,
  }) async {
    state = const AsyncValue.loading();
    try {
      final glasanjeId = const Uuid().v4();
      
      final glasanje = Glasanje(
        id: glasanjeId,
        sjednicaId: sjednicaId,
        stavkaId: stavkaId,
        naslov: naslov,
        opis: opis,
        grupa: grupa,
        opcije: opcije,
        status: GlasanjeStatus.openForVoting,
        pocetneVrijeme: pocetneVrijeme,
        krajnjeVrijeme: krajnjeVrijeme,
        created: DateTime.now(),
      );

      await _firestore
          .collection('glasanja')
          .doc(glasanjeId)
          .set(glasanje.toFirestore());

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> castVote({
    required String glasanjeId,
    required String korisnikId,
    required String izbor,
  }) async {
    state = const AsyncValue.loading();
    try {
      final glas = Glas(
        korisnikId: korisnikId,
        izbor: izbor,
        vrijeme: DateTime.now(),
      );

      await _firestore.collection('glasanja').doc(glasanjeId).update({
        'glasovi': FieldValue.arrayUnion([glas.toMap()]),
      });

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> closeVoting({
    required String glasanjeId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _firestore.collection('glasanja').doc(glasanjeId).update({
        'status': 'closed',
        'updated': FieldValue.serverTimestamp(),
      });

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteGlasanje({
    required String glasanjeId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _firestore.collection('glasanja').doc(glasanjeId).delete();

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final glasanjaNotifierProvider =
    StateNotifierProvider<GlasanjaNotifier, AsyncValue<void>>((ref) {
  return GlasanjaNotifier();
});
