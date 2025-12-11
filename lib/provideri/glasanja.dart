import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esjednice/modeli/glasanje.dart';
import 'package:esjednice/modeli/korisnik.dart';
import 'package:esjednice/provideri/global.dart';

final glasanjaProvider = StreamProvider<List<Glasanje>>((ref) async* {
  final korisnikData = ref.watch(korisnikPodaciProvider).value;
  
  if (korisnikData == null) {
    yield [];
    return;
  }

  final firestore = FirebaseFirestore.instance;
  
  // If user is principal, they see all votings
  if (korisnikData.uloga == KorisnikUloga.ravnatelj) {
    yield* firestore
        .collection('glasanja')
        .orderBy('krajnjeVrijeme', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Glasanje.fromFirestore(doc))
          .toList();
    });
  } else {
    // Otherwise, filter by user's groups
    yield* firestore
        .collection('glasanja')
        .where('grupa', whereIn: korisnikData.grupe.isEmpty ? [''] : korisnikData.grupe)
        .orderBy('krajnjeVrijeme', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Glasanje.fromFirestore(doc))
          .toList();
    });
  }
});

final pojedinacnoGlasanjeProvider =
    StreamProvider.family<Glasanje?, String>((ref, glasanjeId) {
  final firestore = FirebaseFirestore.instance;
  
  return firestore
      .collection('glasanja')
      .doc(glasanjeId)
      .snapshots()
      .map((snapshot) {
    if (snapshot.exists) {
      return Glasanje.fromFirestore(snapshot);
    }
    return null;
  });
});

final glasanjaStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final glasanja = ref.watch(glasanjaProvider).value ?? [];
  
  return {
    'open': glasanja.where((g) => g.status == GlasanjeStatus.openForVoting).length,
    'closed': glasanja.where((g) => g.status == GlasanjeStatus.closed).length,
    'total': glasanja.length,
  };
});

// Check if user has already voted
final userVotedProvider =
    FutureProvider.family<bool, String>((ref, glasanjeId) async {
  final user = ref.watch(korisnikPodaciProvider).value;
  if (user == null) return false;

  final firestore = FirebaseFirestore.instance;
  final doc = await firestore.collection('glasanja').doc(glasanjeId).get();
  
  if (!doc.exists) return false;
  
  final glasanje = Glasanje.fromFirestore(doc);
  return glasanje.glasovi.any((glas) => glas.korisnikId == user.uid);
});
