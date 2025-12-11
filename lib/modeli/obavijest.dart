import 'package:cloud_firestore/cloud_firestore.dart';

enum ObavijestTip {
  opca, // General
  grupa, // Group-specific
  uloga, // Role-specific
}

extension ObavijestTipExtension on ObavijestTip {
  String get displayName {
    switch (this) {
      case ObavijestTip.opca:
        return 'Opća';
      case ObavijestTip.grupa:
        return 'Za grupu';
      case ObavijestTip.uloga:
        return 'Za ulogu';
    }
  }
}

class Obavijest {
  final String id;
  final String naslov;
  final String sadrzaj;
  final String autorizdId;
  final String autoriziranoIme;
  final ObavijestTip tip;
  final List<String>? grupe; // If tip == grupa
  final List<String>? uloge; // If tip == uloga
  final DateTime vrijeme;
  final bool aktivna;
  final DateTime created;
  final DateTime? updated;

  Obavijest({
    required this.id,
    required this.naslov,
    required this.sadrzaj,
    required this.autorizdId,
    required this.autoriziranoIme,
    required this.tip,
    this.grupe,
    this.uloge,
    required this.vrijeme,
    this.aktivna = true,
    required this.created,
    this.updated,
  });

  factory Obavijest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Obavijest(
      id: doc.id,
      naslov: data['naslov'] as String,
      sadrzaj: data['sadrzaj'] as String,
      autorizdId: data['autorizdId'] as String,
      autoriziranoIme: data['autoriziranoIme'] as String,
      tip: ObavijestTip.values.firstWhere(
        (e) => e.toString() == 'ObavijestTip.${data['tip']}',
        orElse: () => ObavijestTip.opca,
      ),
      grupe: data['grupe'] != null ? List<String>.from(data['grupe'] as List) : null,
      uloge: data['uloge'] != null ? List<String>.from(data['uloge'] as List) : null,
      vrijeme: (data['vrijeme'] as Timestamp).toDate(),
      aktivna: data['aktivna'] as bool? ?? true,
      created: (data['created'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updated: (data['updated'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'naslov': naslov,
      'sadrzaj': sadrzaj,
      'autorizdId': autorizdId,
      'autoriziranoIme': autoriziranoIme,
      'tip': tip.toString().split('.').last,
      'grupe': grupe,
      'uloge': uloge,
      'vrijeme': Timestamp.fromDate(vrijeme),
      'aktivna': aktivna,
      'created': Timestamp.fromDate(created),
      'updated': updated != null ? Timestamp.fromDate(updated!) : null,
    };
  }

  Obavijest copyWith({
    String? id,
    String? naslov,
    String? sadrzaj,
    String? autorizdId,
    String? autoriziranoIme,
    ObavijestTip? tip,
    List<String>? grupe,
    List<String>? uloge,
    DateTime? vrijeme,
    bool? aktivna,
    DateTime? created,
    DateTime? updated,
  }) {
    return Obavijest(
      id: id ?? this.id,
      naslov: naslov ?? this.naslov,
      sadrzaj: sadrzaj ?? this.sadrzaj,
      autorizdId: autorizdId ?? this.autorizdId,
      autoriziranoIme: autoriziranoIme ?? this.autoriziranoIme,
      tip: tip ?? this.tip,
      grupe: grupe ?? this.grupe,
      uloge: uloge ?? this.uloge,
      vrijeme: vrijeme ?? this.vrijeme,
      aktivna: aktivna ?? this.aktivna,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }
}
