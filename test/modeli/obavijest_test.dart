import 'package:flutter_test/flutter_test.dart';
import 'package:esjednice/modeli/obavijest.dart';

void main() {
  group('Obavijest Model Tests', () {
    test('create general announcement (opca)', () {
      final obavijest = Obavijest(
        id: 'test-1',
        naslov: 'General Announcement',
        sadrzaj: 'This is a general announcement for everyone',
        autorizdId: 'user-1',
        autoriziranoIme: 'John Doe',
        tip: ObavijestTip.opca,
        vrijeme: DateTime.now(),
        created: DateTime.now(),
      );

      expect(obavijest.tip, ObavijestTip.opca);
      expect(obavijest.grupe, isNull);
      expect(obavijest.uloge, isNull);
      expect(obavijest.aktivna, true);
    });

    test('create group-specific announcement', () {
      final obavijest = Obavijest(
        id: 'test-2',
        naslov: 'Group Announcement',
        sadrzaj: 'This is for specific groups',
        autorizdId: 'user-1',
        autoriziranoIme: 'John Doe',
        tip: ObavijestTip.grupa,
        grupe: ['Grupa A', 'Grupa B'],
        vrijeme: DateTime.now(),
        created: DateTime.now(),
      );

      expect(obavijest.tip, ObavijestTip.grupa);
      expect(obavijest.grupe, ['Grupa A', 'Grupa B']);
      expect(obavijest.uloge, isNull);
    });

    test('create role-specific announcement', () {
      final obavijest = Obavijest(
        id: 'test-3',
        naslov: 'Role Announcement',
        sadrzaj: 'This is for specific roles',
        autorizdId: 'user-1',
        autoriziranoIme: 'John Doe',
        tip: ObavijestTip.uloga,
        uloge: ['nastavnik', 'zapisnicar'],
        vrijeme: DateTime.now(),
        created: DateTime.now(),
      );

      expect(obavijest.tip, ObavijestTip.uloga);
      expect(obavijest.uloge, ['nastavnik', 'zapisnicar']);
      expect(obavijest.grupe, isNull);
    });

    test('deactivate announcement with copyWith', () {
      final active = Obavijest(
        id: 'test-1',
        naslov: 'Test Announcement',
        sadrzaj: 'Test content',
        autorizdId: 'user-1',
        autoriziranoIme: 'John Doe',
        tip: ObavijestTip.opca,
        vrijeme: DateTime.now(),
        created: DateTime.now(),
        aktivna: true,
      );

      final inactive = active.copyWith(aktivna: false);

      expect(active.aktivna, true);
      expect(inactive.aktivna, false);
      expect(inactive.naslov, active.naslov); // Other fields unchanged
    });

    test('display name for announcement types', () {
      expect(ObavijestTip.opca.displayName, 'Opća');
      expect(ObavijestTip.grupa.displayName, 'Za grupu');
      expect(ObavijestTip.uloga.displayName, 'Za ulogu');
    });
  });
}
