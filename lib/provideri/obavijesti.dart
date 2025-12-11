import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esjednice/modeli/obavijest.dart';
import 'package:esjednice/modeli/korisnik.dart';
import 'package:esjednice/provideri/global.dart';

final obavijrestiProvider = StreamProvider<List<Obavijest>>((ref) async* {
  final korisnikData = ref.watch(korisnikPodaciProvider).value;
  
  if (korisnikData == null) {
    yield [];
    return;
  }

  final firestore = FirebaseFirestore.instance;
  
  // If user is principal, they see all announcements
  if (korisnikData.uloga == KorisnikUloga.ravnatelj) {
    yield* firestore
        .collection('obavijesti')
        .where('aktivna', isEqualTo: true)
        .orderBy('vrijeme', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Obavijest.fromFirestore(doc))
          .toList();
    });
  } else {
    // Filter based on user's groups and roles
    yield* firestore
        .collection('obavijesti')
        .where('aktivna', isEqualTo: true)
        .orderBy('vrijeme', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Obavijest.fromFirestore(doc))
          .where((obavijest) {
            // Check if announcement is for this user
            if (obavijest.tip == ObavijestTip.opca) {
              return true;
            }
            
            if (obavijest.tip == ObavijestTip.grupa) {
              return obavijest.grupe?.any((grupa) => korisnikData.grupe.contains(grupa)) ?? false;
            }
            
            if (obavijest.tip == ObavijestTip.uloga) {
              return obavijest.uloge?.contains(korisnikData.uloga.toString().split('.').last) ?? false;
            }
            
            return false;
          })
          .toList();
    });
  }
});

final pojedinacnaObavijestProvider =
    StreamProvider.family<Obavijest?, String>((ref, obavijestId) {
  final firestore = FirebaseFirestore.instance;
  
  return firestore
      .collection('obavijesti')
      .doc(obavijestId)
      .snapshots()
      .map((snapshot) {
    if (snapshot.exists) {
      return Obavijest.fromFirestore(snapshot);
    }
    return null;
  });
});

final obavijestStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final obavijesti = ref.watch(obavijrestiProvider).value ?? [];
  
  return {
    'active': obavijesti.where((o) => o.aktivna).length,
    'total': obavijesti.length,
  };
});
