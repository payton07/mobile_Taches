import 'package:mes_taches/modele/taches.dart';
import 'package:test/test.dart';

void main() {
  group('erreurTitre', () {
    test('refuse un titre vide', () {
      expect(erreurTitre(''), 'Le titre est obligatoire');
    });

    test('refuse un titre fait seulement d\'espaces', () {
      expect(erreurTitre('   '), 'Le titre est obligatoire');
      expect(erreurTitre(' \t\n '), 'Le titre est obligatoire');
    });

    test('accepte un titre de 60 caractères', () {
      expect(erreurTitre('a' * 60), isNull);
    });

    test('refuse un titre de 61 caractères', () {
      expect(erreurTitre('a' * 61), 'Le titre fait 60 caractères au plus');
    });

    test('ne compte pas les espaces de début et de fin', () {
      expect(erreurTitre('  ${'a' * 60}  '), isNull);
      expect(erreurTitre('  Réviser  '), isNull);
    });
  });

  group('erreurNote', () {
    test('accepte une note vide (pas de note)', () {
      expect(erreurNote(''), isNull);
      expect(erreurNote('   '), isNull);
    });

    test('accepte une note de 200 caractères', () {
      expect(erreurNote('n' * 200), isNull);
    });

    test('refuse une note de 201 caractères', () {
      expect(erreurNote('n' * 201), 'La note fait 200 caractères au plus');
    });

    test('ne compte pas les espaces de début et de fin', () {
      expect(erreurNote(' ${'n' * 200} '), isNull);
    });
  });

  group('erreurEcheance', () {
    // Le jour J : 18/11/2026 à 15 h.
    final aujourdhui = DateTime(2026, 11, 18, 15);
    const message = "L'échéance ne peut pas être antérieure à aujourd'hui";

    test('refuse la veille', () {
      expect(
        erreurEcheance(
          EcheanceDate(DateTime(2026, 11, 17)),
          aujourdhui: aujourdhui,
        ),
        message,
      );
    });

    test('refuse une date d\'une année passée', () {
      expect(
        erreurEcheance(
          EcheanceDate(DateTime(2025, 12, 31)),
          aujourdhui: aujourdhui,
        ),
        message,
      );
    });

    test('accepte aujourd\'hui, quelle que soit l\'heure', () {
      final echeance = EcheanceDate(DateTime(2026, 11, 18));
      expect(erreurEcheance(echeance, aujourdhui: aujourdhui), isNull);
      expect(
        erreurEcheance(echeance, aujourdhui: DateTime(2026, 11, 18, 23, 59)),
        isNull,
      );
    });

    test('accepte le lendemain', () {
      expect(
        erreurEcheance(
          EcheanceDate(DateTime(2026, 11, 19)),
          aujourdhui: aujourdhui,
        ),
        isNull,
      );
    });

    test('accepte l\'absence d\'échéance et une échéance hebdomadaire', () {
      expect(
        erreurEcheance(const SansEcheance(), aujourdhui: aujourdhui),
        isNull,
      );
      expect(
        erreurEcheance(EcheanceHebdomadaire(1), aujourdhui: aujourdhui),
        isNull,
      );
    });
  });
}
