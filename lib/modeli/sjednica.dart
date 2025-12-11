import 'package:cloud_firestore/cloud_firestore.dart';

enum SjednicaStatus {
  planned, // Planned
  inProgress, // In Progress
  concluded, // Concluded
  canceled, // Canceled
}

extension SjednicaStatusExtension on SjednicaStatus {
  String get displayName {
    switch (this) {
      case SjednicaStatus.planned:
        return 'Planirana';
      case SjednicaStatus.inProgress:
        return 'U tijeku';
      case SjednicaStatus.concluded:
        return 'Završena';
      case SjednicaStatus.canceled:
        return 'Otkazana';
    }
  }
}

class DnevniRedStavka {
  final String id;
  final int rednibroj;
  final String naslov;
  final String? opis;
  final bool saGlasanjem;
  final DateTime? vrijeme;

  DnevniRedStavka({
    required this.id,
    required this.rednibroj,
    required this.naslov,
    this.opis,
    this.saGlasanjem = false,
    this.vrijeme,
  });

  factory DnevniRedStavka.fromMap(Map<String, dynamic> map) {
    return DnevniRedStavka(
      id: map['id'] as String,
      rednibroj: map['rednibroj'] as int,
      naslov: map['naslov'] as String,
      opis: map['opis'] as String?,
      saGlasanjem: map['saGlasanjem'] as bool? ?? false,
      vrijeme: (map['vrijeme'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rednibroj': rednibroj,
      'naslov': naslov,
      'opis': opis,
      'saGlasanjem': saGlasanjem,
      'vrijeme': vrijeme != null ? Timestamp.fromDate(vrijeme!) : null,
    };
  }

  DnevniRedStavka copyWith({
    String? id,
    int? rednibroj,
    String? naslov,
    String? opis,
    bool? saGlasanjem,
    DateTime? vrijeme,
  }) {
    return DnevniRedStavka(
      id: id ?? this.id,
      rednibroj: rednibroj ?? this.rednibroj,
      naslov: naslov ?? this.naslov,
      opis: opis ?? this.opis,
      saGlasanjem: saGlasanjem ?? this.saGlasanjem,
      vrijeme: vrijeme ?? this.vrijeme,
    );
  }
}

class Prisutnost {
  final String korisnikId;
  final String ime;
  final String prezime;
  final bool prisutan;
  final DateTime? vrijemeProvjere;

  Prisutnost({
    required this.korisnikId,
    required this.ime,
    required this.prezime,
    required this.prisutan,
    this.vrijemeProvjere,
  });

  factory Prisutnost.fromMap(Map<String, dynamic> map) {
    return Prisutnost(
      korisnikId: map['korisnikId'] as String,
      ime: map['ime'] as String,
      prezime: map['prezime'] as String,
      prisutan: map['prisutan'] as bool,
      vrijemeProvjere: (map['vrijemeProvjere'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'korisnikId': korisnikId,
      'ime': ime,
      'prezime': prezime,
      'prisutan': prisutan,
      'vrijemeProvjere':
          vrijemeProvjere != null ? Timestamp.fromDate(vrijemeProvjere!) : null,
    };
  }

  Prisutnost copyWith({
    String? korisnikId,
    String? ime,
    String? prezime,
    bool? prisutan,
    DateTime? vrijemeProvjere,
  }) {
    return Prisutnost(
      korisnikId: korisnikId ?? this.korisnikId,
      ime: ime ?? this.ime,
      prezime: prezime ?? this.prezime,
      prisutan: prisutan ?? this.prisutan,
      vrijemeProvjere: vrijemeProvjere ?? this.vrijemeProvjere,
    );
  }
}

class Sjednica {
  final String id;
  final String naslov;
  final String? opis;
  final String grupa;
  final DateTime vrijeme;
  final String? lokacija;
  final SjednicaStatus status;
  final String sazivac;
  final String zapisnicar;
  final List<DnevniRedStavka> dnevniRed;
  final List<Prisutnost> prisutnost;
  final String? zapisnik;
  final DateTime created;
  final DateTime? updated;

  Sjednica({
    required this.id,
    required this.naslov,
    this.opis,
    required this.grupa,
    required this.vrijeme,
    this.lokacija,
    required this.status,
    required this.sazivac,
    required this.zapisnicar,
    this.dnevniRed = const [],
    this.prisutnost = const [],
    this.zapisnik,
    required this.created,
    this.updated,
  });

  factory Sjednica.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Sjednica(
      id: doc.id,
      naslov: data['naslov'] as String,
      opis: data['opis'] as String?,
      grupa: data['grupa'] as String,
      vrijeme: (data['vrijeme'] as Timestamp).toDate(),
      lokacija: data['lokacija'] as String?,
      status: SjednicaStatus.values.firstWhere(
        (e) => e.toString() == 'SjednicaStatus.${data['status']}',
        orElse: () => SjednicaStatus.planned,
      ),
      sazivac: data['sazivac'] as String,
      zapisnicar: data['zapisnicar'] as String,
      dnevniRed: (data['dnevniRed'] as List?)
              ?.map((item) => DnevniRedStavka.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      prisutnost: (data['prisutnost'] as List?)
              ?.map((item) => Prisutnost.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      zapisnik: data['zapisnik'] as String?,
      created: (data['created'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updated: (data['updated'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'naslov': naslov,
      'opis': opis,
      'grupa': grupa,
      'vrijeme': Timestamp.fromDate(vrijeme),
      'lokacija': lokacija,
      'status': status.toString().split('.').last,
      'sazivac': sazivac,
      'zapisnicar': zapisnicar,
      'dnevniRed': dnevniRed.map((e) => e.toMap()).toList(),
      'prisutnost': prisutnost.map((e) => e.toMap()).toList(),
      'zapisnik': zapisnik,
      'created': Timestamp.fromDate(created),
      'updated': updated != null ? Timestamp.fromDate(updated!) : null,
    };
  }

  Sjednica copyWith({
    String? id,
    String? naslov,
    String? opis,
    String? grupa,
    DateTime? vrijeme,
    String? lokacija,
    SjednicaStatus? status,
    String? sazivac,
    String? zapisnicar,
    List<DnevniRedStavka>? dnevniRed,
    List<Prisutnost>? prisutnost,
    String? zapisnik,
    DateTime? created,
    DateTime? updated,
  }) {
    return Sjednica(
      id: id ?? this.id,
      naslov: naslov ?? this.naslov,
      opis: opis ?? this.opis,
      grupa: grupa ?? this.grupa,
      vrijeme: vrijeme ?? this.vrijeme,
      lokacija: lokacija ?? this.lokacija,
      status: status ?? this.status,
      sazivac: sazivac ?? this.sazivac,
      zapisnicar: zapisnicar ?? this.zapisnicar,
      dnevniRed: dnevniRed ?? this.dnevniRed,
      prisutnost: prisutnost ?? this.prisutnost,
      zapisnik: zapisnik ?? this.zapisnik,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }
}
