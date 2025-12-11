import 'package:cloud_firestore/cloud_firestore.dart';

enum GlasanjeStatus {
  openForVoting, // Open for voting
  closed, // Closed
}

extension GlasanjeStatusExtension on GlasanjeStatus {
  String get displayName {
    switch (this) {
      case GlasanjeStatus.openForVoting:
        return 'Otvoreno';
      case GlasanjeStatus.closed:
        return 'Zatvoreno';
    }
  }
}

class Glas {
  final String korisnikId;
  final String izbor; // Yes, No, Abstain, etc.
  final DateTime vrijeme;

  Glas({
    required this.korisnikId,
    required this.izbor,
    required this.vrijeme,
  });

  factory Glas.fromMap(Map<String, dynamic> map) {
    return Glas(
      korisnikId: map['korisnikId'] as String,
      izbor: map['izbor'] as String,
      vrijeme: (map['vrijeme'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'korisnikId': korisnikId,
      'izbor': izbor,
      'vrijeme': Timestamp.fromDate(vrijeme),
    };
  }

  Glas copyWith({
    String? korisnikId,
    String? izbor,
    DateTime? vrijeme,
  }) {
    return Glas(
      korisnikId: korisnikId ?? this.korisnikId,
      izbor: izbor ?? this.izbor,
      vrijeme: vrijeme ?? this.vrijeme,
    );
  }
}

class Glasanje {
  final String id;
  final String sjednicaId;
  final String stavkaId; // Reference to agenda item
  final String naslov;
  final String? opis;
  final String grupa;
  final List<String> opcije; // Voting options (Da, Ne, Suzdržan, etc.)
  final GlasanjeStatus status;
  final List<Glas> glasovi;
  final DateTime pocetneVrijeme;
  final DateTime krajnjeVrijeme;
  final DateTime created;
  final DateTime? updated;

  Glasanje({
    required this.id,
    required this.sjednicaId,
    required this.stavkaId,
    required this.naslov,
    this.opis,
    required this.grupa,
    required this.opcije,
    required this.status,
    this.glasovi = const [],
    required this.pocetneVrijeme,
    required this.krajnjeVrijeme,
    required this.created,
    this.updated,
  });

  bool get isOpen => status == GlasanjeStatus.openForVoting;

  bool get isClosed => status == GlasanjeStatus.closed;

  Map<String, int> get rezultati {
    final rezultati = <String, int>{};
    for (final opcija in opcije) {
      rezultati[opcija] = 0;
    }
    for (final glas in glasovi) {
      rezultati[glas.izbor] = (rezultati[glas.izbor] ?? 0) + 1;
    }
    return rezultati;
  }

  factory Glasanje.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Glasanje(
      id: doc.id,
      sjednicaId: data['sjednicaId'] as String,
      stavkaId: data['stavkaId'] as String? ?? '',
      naslov: data['naslov'] as String,
      opis: data['opis'] as String?,
      grupa: data['grupa'] as String,
      opcije: List<String>.from(data['opcije'] as List? ?? []),
      status: GlasanjeStatus.values.firstWhere(
        (e) => e.toString() == 'GlasanjeStatus.${data['status']}',
        orElse: () => GlasanjeStatus.openForVoting,
      ),
      glasovi: (data['glasovi'] as List?)
              ?.map((item) => Glas.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      pocetneVrijeme: (data['pocetneVrijeme'] as Timestamp).toDate(),
      krajnjeVrijeme: (data['krajnjeVrijeme'] as Timestamp).toDate(),
      created: (data['created'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updated: (data['updated'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sjednicaId': sjednicaId,
      'stavkaId': stavkaId,
      'naslov': naslov,
      'opis': opis,
      'grupa': grupa,
      'opcije': opcije,
      'status': status.toString().split('.').last,
      'glasovi': glasovi.map((e) => e.toMap()).toList(),
      'pocetneVrijeme': Timestamp.fromDate(pocetneVrijeme),
      'krajnjeVrijeme': Timestamp.fromDate(krajnjeVrijeme),
      'created': Timestamp.fromDate(created),
      'updated': updated != null ? Timestamp.fromDate(updated!) : null,
    };
  }

  Glasanje copyWith({
    String? id,
    String? sjednicaId,
    String? stavkaId,
    String? naslov,
    String? opis,
    String? grupa,
    List<String>? opcije,
    GlasanjeStatus? status,
    List<Glas>? glasovi,
    DateTime? pocetneVrijeme,
    DateTime? krajnjeVrijeme,
    DateTime? created,
    DateTime? updated,
  }) {
    return Glasanje(
      id: id ?? this.id,
      sjednicaId: sjednicaId ?? this.sjednicaId,
      stavkaId: stavkaId ?? this.stavkaId,
      naslov: naslov ?? this.naslov,
      opis: opis ?? this.opis,
      grupa: grupa ?? this.grupa,
      opcije: opcije ?? this.opcije,
      status: status ?? this.status,
      glasovi: glasovi ?? this.glasovi,
      pocetneVrijeme: pocetneVrijeme ?? this.pocetneVrijeme,
      krajnjeVrijeme: krajnjeVrijeme ?? this.krajnjeVrijeme,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }
}
