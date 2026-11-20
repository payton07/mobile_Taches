import 'package:mes_taches/modele/taches.dart';
import 'package:test/test.dart';

void main() {
  var compteur = 0;
  Tache tache(String titre, Priorite priorite, {bool faite = false}) => Tache(
    id: 't${compteur++}',
    titre: titre,
    priorite: priorite,
    faite: faite,
  );

  /// L'exemple de l'énoncé.
  List<Tache> exemple() => [
    tache('Courses', Priorite.basse),
    tache('Dentiste', Priorite.normale),
    tache('Passeport', Priorite.haute),
    tache('Installer', Priorite.haute, faite: true),
    tache('Banque', Priorite.normale),
  ];

  List<String> titres(List<Tache> taches) => [for (final t in taches) t.titre];

  group('bilan', () {
    test('une collection vide donne (faites: 0, total: 0)', () {
      expect(bilan(const <Tache>[]), (faites: 0, total: 0));
    });

    test('compte les tâches faites et le total', () {
      expect(bilan(exemple()), (faites: 1, total: 5));
    });

    test('toutes faites / aucune faite', () {
      final taches = exemple();
      expect(bilan(taches.map((t) => t.copieAvec(faite: true))), (
        faites: 5,
        total: 5,
      ));
      expect(bilan(taches.map((t) => t.copieAvec(faite: false))), (
        faites: 0,
        total: 5,
      ));
    });
  });

  group('aFaire', () {
    test('exemple de l\'énoncé, sans filtre de priorité', () {
      expect(titres(aFaire(exemple())), [
        'Passeport',
        'Banque',
        'Dentiste',
        'Courses',
      ]);
    });

    test('exemple de l\'énoncé, avec auMoins: Priorite.normale', () {
      expect(titres(aFaire(exemple(), auMoins: Priorite.normale)), [
        'Passeport',
        'Banque',
        'Dentiste',
      ]);
    });

    test('auMoins est inclusif', () {
      expect(titres(aFaire(exemple(), auMoins: Priorite.haute)), ['Passeport']);
    });

    test('exclut les tâches faites, même urgentes', () {
      expect(titres(aFaire(exemple())), isNot(contains('Installer')));
    });

    test('à priorité égale, trie par titre', () {
      final taches = [
        tache('Zèbre', Priorite.normale),
        tache('Abricot', Priorite.normale),
        tache('Melon', Priorite.normale),
      ];
      expect(titres(aFaire(taches)), ['Abricot', 'Melon', 'Zèbre']);
    });

    test('la priorité l\'emporte sur le titre', () {
      final taches = [
        tache('Abricot', Priorite.basse),
        tache('Zèbre', Priorite.haute),
      ];
      expect(titres(aFaire(taches)), ['Zèbre', 'Abricot']);
    });

    test('une collection vide donne une liste vide', () {
      expect(aFaire(const <Tache>[]), isEmpty);
    });

    test('ne modifie jamais la collection reçue', () {
      final recue = exemple();
      final copie = List.of(recue);

      aFaire(recue);

      expect(recue, copie);
    });

    test('fonctionne sur une collection non modifiable', () {
      final recue = List<Tache>.unmodifiable(exemple());
      expect(titres(aFaire(recue)), [
        'Passeport',
        'Banque',
        'Dentiste',
        'Courses',
      ]);
    });

    test('renvoie une nouvelle liste, indépendante de la collection reçue', () {
      final recue = exemple().where((t) => !t.faite).toList();
      final resultat = aFaire(recue);

      expect(identical(resultat, recue), isFalse);
      resultat.clear();
      expect(recue, hasLength(4));
    });
  });
}
