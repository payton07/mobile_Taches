import 'package:mes_taches/modele/taches.dart';
import 'package:test/test.dart';

void main() {
  group('prioriteDepuisCode', () {
    test('reconnaît les trois codes', () {
      expect(prioriteDepuisCode('low'), Priorite.basse);
      expect(prioriteDepuisCode('normal'), Priorite.normale);
      expect(prioriteDepuisCode('high'), Priorite.haute);
    });

    test('renvoie null pour tout autre code', () {
      for (final code in ['High', 'LOW', '', 'urgent', ' low']) {
        expect(prioriteDepuisCode(code), isNull, reason: code);
      }
    });
  });

  group('tacheDepuisJson', () {
    const valide = <String, Object?>{
      'id': 't1',
      'title': 'Installer Flutter',
      'priority': 'high',
      'done': true,
    };

    /// Le document valide, privé de la clé [cle].
    Map<String, Object?> sans(String cle) => Map.of(valide)..remove(cle);

    test('lit l\'exemple t1 (sans échéance ni note)', () {
      expect(
        tacheDepuisJson(valide),
        Tache(
          id: 't1',
          titre: 'Installer Flutter',
          priorite: Priorite.haute,
          faite: true,
        ),
      );
    });

    test('lit l\'exemple t2 (avec échéance et note)', () {
      final tache = tacheDepuisJson({
        'id': 't2',
        'title': 'Payer le loyer',
        'priority': 'low',
        'done': false,
        'due': '2026-12-01',
        'note': 'virement',
      });

      expect(tache.priorite, Priorite.basse);
      expect(tache.faite, isFalse);
      expect(tache.echeance, EcheanceDate(DateTime(2026, 12, 1)));
      expect(tache.note, 'virement');
    });

    test('"due" et "note" valant null équivalent à leur absence', () {
      final tache = tacheDepuisJson({...valide, 'due': null, 'note': null});
      expect(tache.echeance, const SansEcheance());
      expect(tache.note, isNull);
    });

    test('ignore les clés inconnues', () {
      expect(
        tacheDepuisJson({...valide, 'couleur': 'rouge', 'tags': [1, 2]}),
        tacheDepuisJson(valide),
      );
    });

    test('rejette les exemples t3 et t4', () {
      expect(() => tacheDepuisJson({...valide, 'priority': 'urgent'}),
          throwsFormatException);
      expect(() => tacheDepuisJson({...valide, 'done': 'non'}),
          throwsFormatException);
    });

    test('rejette une clé obligatoire absente ou null', () {
      for (final cle in ['id', 'title', 'priority', 'done']) {
        expect(() => tacheDepuisJson(sans(cle)), throwsFormatException,
            reason: 'absente : $cle');
        expect(() => tacheDepuisJson({...valide, cle: null}),
            throwsFormatException,
            reason: 'null : $cle');
      }
    });

    test('rejette une chaîne obligatoire vide', () {
      expect(() => tacheDepuisJson({...valide, 'id': ''}),
          throwsFormatException);
      expect(() => tacheDepuisJson({...valide, 'title': ''}),
          throwsFormatException);
    });

    test('rejette une valeur du mauvais type', () {
      final invalides = <String, Object?>{
        'id': 42,
        'title': ['Lire'],
        'priority': 2,
        'done': 1,
        'due': 20261201,
        'note': 42,
      };
      invalides.forEach((cle, valeur) {
        expect(() => tacheDepuisJson({...valide, cle: valeur}),
            throwsFormatException,
            reason: '$cle: $valeur');
      });
    });

    test('rejette une date illisible ou inexistante', () {
      for (final due in [
        '',
        '01/12/2026',
        '2026-12-1',
        '2026-12-01T10:00:00',
        '2026-13-01',
        '2026-02-30',
        '2026-00-10',
      ]) {
        expect(() => tacheDepuisJson({...valide, 'due': due}),
            throwsFormatException,
            reason: due);
      }
    });

    test('accepte le 29 février d\'une année bissextile', () {
      expect(
        tacheDepuisJson({...valide, 'due': '2028-02-29'}).echeance,
        EcheanceDate(DateTime(2028, 2, 29)),
      );
    });
  });
}