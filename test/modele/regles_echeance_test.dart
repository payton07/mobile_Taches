import 'package:mes_taches/modele/taches.dart';
import 'package:test/test.dart';

void main() {
  group('libelleEcheance', () {
    test('sans échéance', () {
      expect(libelleEcheance(const SansEcheance()), 'sans échéance');
    });

    test('date au format jour/mois, sans zéro initial', () {
      expect(
        libelleEcheance(EcheanceDate(DateTime(2026, 12, 1))),
        'pour le 1/12',
      );
      expect(
        libelleEcheance(EcheanceDate(DateTime(2027, 1, 5))),
        'pour le 5/1',
      );
      expect(
        libelleEcheance(EcheanceDate(DateTime(2026, 11, 25))),
        'pour le 25/11',
      );
    });

    test('hebdomadaire, jour en minuscules', () {
      const attendus = {
        DateTime.monday: 'chaque lundi',
        DateTime.tuesday: 'chaque mardi',
        DateTime.wednesday: 'chaque mercredi',
        DateTime.thursday: 'chaque jeudi',
        DateTime.friday: 'chaque vendredi',
        DateTime.saturday: 'chaque samedi',
        DateTime.sunday: 'chaque dimanche',
      };
      attendus.forEach((jour, libelle) {
        expect(libelleEcheance(EcheanceHebdomadaire(jour)), libelle);
      });
    });
  });

  group('estEnRetard', () {
    // Le jour J du tableau de l'énoncé.
    final jourJ = DateTime(2026, 11, 18);

    Tache tache(Echeance echeance, {bool faite = false}) =>
        Tache(id: 't1', titre: 'Lire', echeance: echeance, faite: faite);

    test('la veille du jour J, non faite, le jour J à 15 h : oui', () {
      final veille = EcheanceDate(DateTime(2026, 11, 17));
      expect(
        estEnRetard(tache(veille), aujourdhui: DateTime(2026, 11, 18, 15)),
        isTrue,
      );
    });

    test('la veille du jour J, faite, le jour J à 15 h : non', () {
      final veille = EcheanceDate(DateTime(2026, 11, 17));
      expect(
        estEnRetard(
          tache(veille, faite: true),
          aujourdhui: DateTime(2026, 11, 18, 15),
        ),
        isFalse,
      );
    });

    test('le jour J à 8 h, non faite, le jour J à 18 h : non', () {
      final jourJMatin = EcheanceDate(DateTime(2026, 11, 18, 8));
      expect(
        estEnRetard(tache(jourJMatin), aujourdhui: DateTime(2026, 11, 18, 18)),
        isFalse,
      );
    });

    test('chaque lundi, non faite, n\'importe quel jour : non', () {
      final lundi = EcheanceHebdomadaire(DateTime.monday);
      for (var decalage = 0; decalage < 14; decalage++) {
        final jour = jourJ.add(Duration(days: decalage));
        expect(
          estEnRetard(tache(lundi), aujourdhui: jour),
          isFalse,
          reason: '$jour',
        );
      }
    });

    test('sans échéance : jamais en retard', () {
      expect(
        estEnRetard(tache(const SansEcheance()), aujourdhui: jourJ),
        isFalse,
      );
    });

    test('échéance future : pas en retard', () {
      final lendemain = EcheanceDate(DateTime(2026, 11, 19));
      expect(estEnRetard(tache(lendemain), aujourdhui: jourJ), isFalse);
    });

    test('changement d\'année : 31/12 en retard le 1/1', () {
      final reveillon = EcheanceDate(DateTime(2026, 12, 31));
      expect(
        estEnRetard(tache(reveillon), aujourdhui: DateTime(2027, 1, 1)),
        isTrue,
      );
    });

    test('le jour J à 23 h 59 n\'est pas encore en retard', () {
      final echeance = EcheanceDate(jourJ);
      expect(
        estEnRetard(
          tache(echeance),
          aujourdhui: DateTime(2026, 11, 18, 23, 59),
        ),
        isFalse,
      );
    });
  });
}
