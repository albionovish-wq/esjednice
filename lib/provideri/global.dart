import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esjednice/modeli/korisnik.dart';
import 'package:esjednice/provideri/auth.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final korisnikPodaciProvider = StreamProvider<Korisnik?>((ref) {
  final user = ref.watch(authStateProvider).value;
  
  if (user == null) {
    return Stream.value(null);
  }

  return FirebaseFirestore.instance
      .collection('korisnici')
      .doc(user.uid)
      .snapshots()
      .map((snapshot) {
    if (snapshot.exists) {
      return Korisnik.fromFirestore(snapshot);
    }
    return null;
  });
});

final korisnikUlogaProvider = FutureProvider<KorisnikUloga?>((ref) async {
  final korisnikData = ref.watch(korisnikPodaciProvider).value;
  return korisnikData?.uloga;
});

final korisnikGrupeProvider = FutureProvider<List<String>>((ref) async {
  final korisnikData = ref.watch(korisnikPodaciProvider).value;
  return korisnikData?.grupe ?? [];
});

final trenutniKorisnikProvider = StreamProvider<Korisnik?>((ref) {
  return ref.watch(korisnikPodaciProvider).when(
    data: (korisnik) => Stream.value(korisnik),
    error: (error, stack) => Stream.value(null),
    loading: () => Stream.value(null),
  );
});
