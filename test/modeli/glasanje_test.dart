import 'package:flutter_test/flutter_test.dart';
import 'package:esjednice/modeli/glasanje.dart';

void main() {
  group('Glasanje Model Tests', () {
    test('rezultati calculation with votes', () {
      final glas1 = Glas(
        korisnikId: 'user1',
        izbor: 'Da',
        vrijeme: DateTime.now(),
      );
      final glas2 = Glas(
        korisnikId: 'user2',
        izbor: 'Da',
        vrijeme: DateTime.now(),
      );
      final glas3 = Glas(
        korisnikId: 'user3',
        izbor: 'Ne',
        vrijeme: DateTime.now(),
      );

      final glasanje = Glasanje(
        id: 'test-1',
        sjednicaId: 'sjednica-1',
        stavkaId: 'stavka-1',
        naslov: 'Test Voting',
        grupa: 'Grupa A',
        opcije: ['Da', 'Ne', 'Suzdržan'],
        status: GlasanjeStatus.openForVoting,
        glasovi: [glas1, glas2, glas3],
        pocetneVrijeme: DateTime.now(),
        krajnjeVrijeme: DateTime.now().add(Duration(hours: 2)),
        created: DateTime.now(),
      );

      expect(glasanje.rezultati['Da'], 2);
      expect(glasanje.rezultati['Ne'], 1);
      expect(glasanje.rezultati['Suzdržan'], 0);
    });

    test('isOpen and isClosed status checks', () {
      final openVoting = Glasanje(
        id: 'test-1',
        sjednicaId: 'sjednica-1',
        stavkaId: 'stavka-1',
        naslov: 'Test Voting',
        grupa: 'Grupa A',
        opcije: ['Da', 'Ne'],
        status: GlasanjeStatus.openForVoting,
        glasovi: [],
        pocetneVrijeme: DateTime.now(),
        krajnjeVrijeme: DateTime.now().add(Duration(hours: 2)),
        created: DateTime.now(),
      );

      expect(openVoting.isOpen, true);
      expect(openVoting.isClosed, false);

      final closedVoting = openVoting.copyWith(status: GlasanjeStatus.closed);
      expect(closedVoting.isOpen, false);
      expect(closedVoting.isClosed, true);
    });

    test('copyWith method creates new instance with updated fields', () {
      final original = Glasanje(
        id: 'test-1',
        sjednicaId: 'sjednica-1',
        stavkaId: 'stavka-1',
        naslov: 'Original Title',
        grupa: 'Grupa A',
        opcije: ['Da', 'Ne'],
        status: GlasanjeStatus.openForVoting,
        glasovi: [],
        pocetneVrijeme: DateTime.now(),
        krajnjeVrijeme: DateTime.now().add(Duration(hours: 2)),
        created: DateTime.now(),
      );

      final updated = original.copyWith(
        naslov: 'Updated Title',
        status: GlasanjeStatus.closed,
      );

      expect(updated.naslov, 'Updated Title');
      expect(updated.status, GlasanjeStatus.closed);
      expect(updated.id, original.id); // ID should remain same
      expect(updated.grupa, original.grupa); // Other fields should remain same
    });
  });
}
