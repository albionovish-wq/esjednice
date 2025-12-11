import 'package:cloud_firestore/cloud_firestore.dart';

enum KorisnikUloga {
  ravnatelj, // Principal
  zapisnicar, // Secretary
  nastavnik, // Teacher
  roditelj, // Parent
  ucenik, // Student
}

extension KorisnikUlogaExtension on KorisnikUloga {
  String get displayName {
    switch (this) {
      case KorisnikUloga.ravnatelj:
        return 'Ravnatelj';
      case KorisnikUloga.zapisnicar:
        return 'Zapisničar';
      case KorisnikUloga.nastavnik:
        return 'Nastavnik';
      case KorisnikUloga.roditelj:
        return 'Roditelj';
      case KorisnikUloga.ucenik:
        return 'Učenik';
    }
  }
}

class Korisnik {
  final String uid;
  final String email;
  final String? ime;
  final String? prezime;
  final KorisnikUloga uloga;
  final List<String> grupe;
  final DateTime created;
  final DateTime? lastLogin;
  final bool aktivan;

  Korisnik({
    required this.uid,
    required this.email,
    this.ime,
    this.prezime,
    required this.uloga,
    required this.grupe,
    required this.created,
    this.lastLogin,
    this.aktivan = true,
  });

  String get fullName => '${ime ?? ''} ${prezime ?? ''}'.trim();

  factory Korisnik.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Korisnik(
      uid: doc.id,
      email: data['email'] as String,
      ime: data['ime'] as String?,
      prezime: data['prezime'] as String?,
      uloga: KorisnikUloga.values.firstWhere(
        (e) => e.toString() == 'KorisnikUloga.${data['uloga']}',
        orElse: () => KorisnikUloga.nastavnik,
      ),
      grupe: List<String>.from(data['grupe'] as List? ?? []),
      created: (data['created'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate(),
      aktivan: data['aktivan'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'ime': ime,
      'prezime': prezime,
      'uloga': uloga.toString().split('.').last,
      'grupe': grupe,
      'created': Timestamp.fromDate(created),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'aktivan': aktivan,
    };
  }

  Korisnik copyWith({
    String? uid,
    String? email,
    String? ime,
    String? prezime,
    KorisnikUloga? uloga,
    List<String>? grupe,
    DateTime? created,
    DateTime? lastLogin,
    bool? aktivan,
  }) {
    return Korisnik(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      ime: ime ?? this.ime,
      prezime: prezime ?? this.prezime,
      uloga: uloga ?? this.uloga,
      grupe: grupe ?? this.grupe,
      created: created ?? this.created,
      lastLogin: lastLogin ?? this.lastLogin,
      aktivan: aktivan ?? this.aktivan,
    );
  }
}
