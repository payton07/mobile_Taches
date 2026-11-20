import 'package:mes_taches/modele/taches.dart';
import 'package:test/test.dart';

void main() {
  group('Priorite', () {
    test('est ordonnée basse < normale < haute', () {
      expect(Priorite.basse < Priorite.normale, isTrue);
      expect(Priorite.normale < Priorite.haute, isTrue);
      expect(Priorite.haute > Priorite.basse, isTrue);
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
