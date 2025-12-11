import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esjednice/modeli/obavijest.dart';
import 'package:uuid/uuid.dart';

class ObavijrestiNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ObavijrestiNotifier() : super(const AsyncValue.data(null));

  Future<void> createObavijest({
    required String naslov,
    required String sadrzaj,
    required String autorizdId,
    required String autoriziranoIme,
    required ObavijestTip tip,
    required List<String>? grupe,
    required List<String>? uloge,
    required DateTime vrijeme,
  }) async {
    state = const AsyncValue.loading();
    try {
      final obavijestId = const Uuid().v4();
      
      final obavijest = Obavijest(
        id: obavijestId,
        naslov: naslov,
        sadrzaj: sadrzaj,
        autorizdId: autorizdId,
        autoriziranoIme: autoriziranoIme,
        tip: tip,
        grupe: grupe,
        uloge: uloge,
        vrijeme: vrijeme,
        created: DateTime.now(),
      );

      await _firestore
          .collection('obavijesti')
          .doc(obavijestId)
          .set(obavijest.toFirestore());

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateObavijest({
    required String obavijestId,
    required String naslov,
    required String sadrzaj,
    required ObavijestTip tip,
    required List<String>? grupe,
    required List<String>? uloge,
    required DateTime vrijeme,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _firestore.collection('obavijesti').doc(obavijestId).update({
        'naslov': naslov,
        'sadrzaj': sadrzaj,
        'tip': tip.toString().split('.').last,
        'grupe': grupe,
        'uloge': uloge,
        'vrijeme': Timestamp.fromDate(vrijeme),
        'updated': FieldValue.serverTimestamp(),
      });

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deactivateObavijest({
    required String obavijestId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _firestore.collection('obavijesti').doc(obavijestId).update({
        'aktivna': false,
        'updated': FieldValue.serverTimestamp(),
      });

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteObavijest({
    required String obavijestId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _firestore.collection('obavijesti').doc(obavijestId).delete();

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final obavijrestiNotifierProvider =
    StateNotifierProvider<ObavijrestiNotifier, AsyncValue<void>>((ref) {
  return ObavijrestiNotifier();
});
