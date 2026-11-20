import 'package:mes_taches/modele/taches.dart';
import 'package:test/test.dart';

void main() {
  group('Priorite', () {
    test('est ordonnée basse < normale < haute', () {
      expect(Priorite.basse < Priorite.normale, isTrue);
      expect(Priorite.normale < Priorite.haute, isTrue);
      expect(Priorite.haute > Priorite.basse, isTrue);
      expect(Priorite.normale <= Priorite.normale, isTrue);
      expect(Priorite.basse <= Priorite.haute, isTrue);
      expect(Priorite.haute <= Priorite.basse, isFalse);
      expect(Priorite.normale >= Priorite.normale, isTrue);
      expect([Priorite.haute, Priorite.basse, Priorite.normale]..sort(), [
        Priorite.basse,
        Priorite.normale,
        Priorite.haute,
      ]);
    });

    test('a un libellé affichable', () {
      expect(Priorite.basse.libelle, 'Basse');
      expect(Priorite.normale.libelle, 'Normale');
      expect(Priorite.haute.libelle, 'Haute');
    });
  });

  group('Echeance', () {
    test('une date ignore l\'heure', () {
      expect(
        EcheanceDate(DateTime(2026, 12, 1, 18, 30)),
        EcheanceDate(DateTime(2026, 12, 1)),
      );
      expect(
        EcheanceDate(DateTime(2026, 12, 1)),
        isNot(EcheanceDate(DateTime(2026, 12, 2))),
      );
    });

    test('deux échéances égales ont le même hashCode', () {
      expect(
        EcheanceDate(DateTime(2026, 12, 1, 18, 30)).hashCode,
        EcheanceDate(DateTime(2026, 12, 1)).hashCode,
      );
      expect(
        EcheanceHebdomadaire(DateTime.monday).hashCode,
        EcheanceHebdomadaire(DateTime.monday).hashCode,
      );
      expect(const SansEcheance().hashCode, const SansEcheance().hashCode);
      // Un Set s'appuie sur hashCode puis == : les doublons sont confondus.
      final doublons = <Echeance>[
        EcheanceDate(DateTime(2026, 12, 1, 8)),
        EcheanceDate(DateTime(2026, 12, 1, 20)),
        EcheanceHebdomadaire(DateTime.friday),
        EcheanceHebdomadaire(DateTime.friday),
        const SansEcheance(),
        const SansEcheance(),
      ];
      expect(doublons.toSet(), hasLength(3));
    });

    test('la date d\'une échéance datée est ce jour-là à minuit', () {
      expect(
        EcheanceDate(DateTime(2026, 12, 1, 18, 30)).date,
        DateTime(2026, 12, 1),
      );
    });

    test('hebdomadaire accepte lundi (1) et dimanche (7)', () {
      expect(EcheanceHebdomadaire(1).jourSemaine, DateTime.monday);
      expect(EcheanceHebdomadaire(7).jourSemaine, DateTime.sunday);
    });

    test('hebdomadaire refuse un jour hors de 1..7', () {
      expect(() => EcheanceHebdomadaire(0), throwsRangeError);
      expect(() => EcheanceHebdomadaire(8), throwsRangeError);
    });
  });

  group('Tache', () {
    Tache exemple() => Tache(
      id: 't1',
      titre: 'Rapport',
      note: 'brouillon',
      echeance: EcheanceHebdomadaire(DateTime.friday),
    );

    test('a les valeurs par défaut de la spécification', () {
      final tache = Tache(id: 't1', titre: 'Rapport');
      expect(tache.priorite, Priorite.normale);
      expect(tache.echeance, const SansEcheance());
      expect(tache.note, isNull);
      expect(tache.faite, isFalse);
    });

    test('refuse un identifiant ou un titre vide', () {
      expect(() => Tache(id: '', titre: 'Rapport'), throwsArgumentError);
      expect(() => Tache(id: 't1', titre: ''), throwsArgumentError);
    });

    test('copieAvec change chaque élément sans toucher l\'originale', () {
      final originale = exemple();
      final echeance = EcheanceDate(DateTime(2026, 12, 1));
      final modifiee = originale.copieAvec(
        titre: 'Rapport final',
        priorite: Priorite.haute,
        echeance: echeance,
        note: 'à relire',
        faite: true,
      );

      expect(modifiee.id, originale.id);
      expect(modifiee.titre, 'Rapport final');
      expect(modifiee.priorite, Priorite.haute);
      expect(modifiee.echeance, echeance);
      expect(modifiee.note, 'à relire');
      expect(modifiee.faite, isTrue);
      expect(originale, exemple());
    });

    test('deux tâches différant d\'un seul champ ne sont pas égales', () {
      final reference = exemple();
      final variantes = {
        'id': Tache(
          id: 't2',
          titre: reference.titre,
          note: reference.note,
          echeance: reference.echeance,
        ),
        'titre': reference.copieAvec(titre: 'Autre titre'),
        'priorite': reference.copieAvec(priorite: Priorite.haute),
        'echeance': reference.copieAvec(echeance: const SansEcheance()),
        'note': reference.copieAvec(note: 'autre note'),
        'note absente': reference.sansNote(),
        'faite': reference.copieAvec(faite: true),
      };
      variantes.forEach((champ, variante) {
        expect(variante, isNot(reference), reason: champ);
      });
    });

    test('deux tâches égales ont le même hashCode', () {
      expect(exemple().hashCode, exemple().hashCode);
      // Un Set s'appuie sur hashCode puis == : les doublons sont confondus.
      expect({exemple(), exemple()}, hasLength(1));
      expect({exemple(), exemple().copieAvec(faite: true)}, hasLength(2));
    });

    test('copieAvec sans argument donne une tâche égale', () {
      expect(exemple().copieAvec(), exemple());
    });

    test('sansNote retire la note et conserve le reste', () {
      final originale = exemple();
      final sansNote = originale.sansNote();

      expect(sansNote.note, isNull);
      expect(sansNote.copieAvec(note: 'brouillon'), originale);
      expect(originale.note, 'brouillon');
    });
  });
}
