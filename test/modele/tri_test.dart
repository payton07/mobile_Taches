import 'package:mes_taches/modele/taches.dart';
import 'package:test/test.dart';

void main() {
  // Le jour J : 18/11/2026 à 15 h.
  final aujourdhui = DateTime(2026, 11, 18, 15);

  final retard = Tache(
    id: 'r',
    titre: 'Retard',
    echeance: EcheanceDate(DateTime(2026, 11, 10)),
  );
  final faiteAncienne = Tache(
    id: 'f',
    titre: 'Faite ancienne',
    echeance: EcheanceDate(DateTime(2026, 11, 1)),
    faite: true,
  );
  final demain = Tache(
    id: 'd',
    titre: 'demain',
    priorite: Priorite.haute,
    echeance: EcheanceDate(DateTime(2026, 11, 19)),
  );
  final janvier = Tache(
    id: 'j',
    titre: 'Janvier',
    priorite: Priorite.basse,
    echeance: EcheanceDate(DateTime(2027, 1, 5)),
  );
  final lundi = Tache(
    id: 'l',
    titre: 'Lundi',
    echeance: EcheanceHebdomadaire(DateTime.monday),
  );
  final vendredi = Tache(
    id: 'v',
    titre: 'Vendredi',
    priorite: Priorite.haute,
    echeance: EcheanceHebdomadaire(DateTime.friday),
  );
  final sansB = Tache(id: 'b', titre: 'banane', priorite: Priorite.basse);
  final sansA = Tache(id: 'a', titre: 'Abricot');

  final taches = [
    sansB,
    vendredi,
    retard,
    janvier,
    sansA,
    faiteAncienne,
    lundi,
    demain,
  ];

  List<String> ids(Iterable<Tache> liste) => [for (final t in liste) t.id];

  group('groupeDe', () {
    test('une date passée non faite est en retard', () {
      expect(groupeDe(retard, aujourdhui: aujourdhui), GroupeEcheance.enRetard);
    });

    test('une date passée mais faite est seulement datée', () {
      expect(
        groupeDe(faiteAncienne, aujourdhui: aujourdhui),
        GroupeEcheance.datees,
      );
    });

    test('une date future est datée', () {
      expect(groupeDe(demain, aujourdhui: aujourdhui), GroupeEcheance.datees);
    });

    test('hebdomadaire et sans échéance ont leur groupe', () {
      expect(
        groupeDe(lundi, aujourdhui: aujourdhui),
        GroupeEcheance.hebdomadaires,
      );
      expect(
        groupeDe(sansA, aujourdhui: aujourdhui),
        GroupeEcheance.sansEcheance,
      );
    });
  });

  group('trier', () {
    test('par ordre d\'ajout : l\'ordre reçu est conservé', () {
      expect(ids(trier(taches, Tri.ajout)), ids(taches));
    });

    test('par priorité : décroissante, puis par titre', () {
      expect(ids(trier(taches, Tri.priorite)), [
        'v', 'd', // haute : Vendredi, demain (V < d en code)
        'a', 'f', 'l', 'r', // normale
        'j', 'b', // basse : Janvier, banane (J < b en code)
      ]);
    });

    test('par titre : alphabétique, sans tenir compte des majuscules', () {
      expect(ids(trier(taches, Tri.titre)), [
        'a',
        'b',
        'd',
        'f',
        'j',
        'l',
        'r',
        'v',
      ]);
    });

    test('par échéance : dates proches d\'abord, puis hebdo, puis sans', () {
      expect(ids(trier(taches, Tri.echeance)), [
        'f', 'r', 'd', 'j', // 1/11, 10/11, 19/11, 5/1
        'l', 'v', // lundi, vendredi
        'a', 'b', // sans échéance, par titre
      ]);
    });

    test('ne modifie jamais la collection reçue', () {
      final copie = List.of(taches);
      for (final tri in Tri.values) {
        trier(taches, tri);
      }
      expect(taches, copie);
    });

    test('renvoie une nouvelle liste, même sans tri', () {
      expect(identical(trier(taches, Tri.ajout), taches), isFalse);
    });
  });

  group('grouperParEcheance', () {
    test('groupes dans l\'ordre, chacun trié par échéance', () {
      final groupes = grouperParEcheance(taches, aujourdhui: aujourdhui);

      expect([for (final g in groupes) g.groupe], GroupeEcheance.values);
      expect(
        [for (final g in groupes) ids(g.taches)],
        [
          ['r'],
          ['f', 'd', 'j'],
          ['l', 'v'],
          ['a', 'b'],
        ],
      );
    });

    test('les groupes vides sont omis', () {
      final groupes = grouperParEcheance([
        sansA,
        demain,
      ], aujourdhui: aujourdhui);

      expect(
        [for (final g in groupes) g.groupe],
        [GroupeEcheance.datees, GroupeEcheance.sansEcheance],
      );
    });

    test('une collection vide ne donne aucun groupe', () {
      expect(grouperParEcheance([], aujourdhui: aujourdhui), isEmpty);
    });
  });
}
