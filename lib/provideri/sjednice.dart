import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esjednice/modeli/sjednica.dart';
import 'package:esjednice/modeli/korisnik.dart';
import 'package:esjednice/provideri/global.dart';

final sjedniceProvider = StreamProvider<List<Sjednica>>((ref) async* {
  final korisnikData = ref.watch(korisnikPodaciProvider).value;
  
  if (korisnikData == null) {
    yield [];
    return;
  }

  final firestore = FirebaseFirestore.instance;
  
  // If user is principal, they see all meetings
  if (korisnikData.uloga == KorisnikUloga.ravnatelj) {
    yield* firestore
        .collection('sjednice')
        .orderBy('vrijeme', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Sjednica.fromFirestore(doc))
          .toList();
    });
  } else {
    // Otherwise, filter by user's groups
    yield* firestore
        .collection('sjednice')
        .where('grupa', whereIn: korisnikData.grupe.isEmpty ? [''] : korisnikData.grupe)
        .orderBy('vrijeme', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Sjednica.fromFirestore(doc))
          .toList();
    });
  }
});

final pojedinacnaSjednicaProvider =
    StreamProvider.family<Sjednica?, String>((ref, sjednicaId) {
  final firestore = FirebaseFirestore.instance;
  
  return firestore
      .collection('sjednice')
      .doc(sjednicaId)
      .snapshots()
      .map((snapshot) {
    if (snapshot.exists) {
      return Sjednica.fromFirestore(snapshot);
    }
    return null;
  });
});

final sjedniceStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final sjednice = ref.watch(sjedniceProvider).value ?? [];
  
  return {
    'planned': sjednice.where((s) => s.status == SjednicaStatus.planned).length,
    'inProgress': sjednice.where((s) => s.status == SjednicaStatus.inProgress).length,
    'concluded': sjednice.where((s) => s.status == SjednicaStatus.concluded).length,
    'canceled': sjednice.where((s) => s.status == SjednicaStatus.canceled).length,
    'total': sjednice.length,
  };
});
