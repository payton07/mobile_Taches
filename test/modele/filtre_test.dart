import 'package:mes_taches/modele/taches.dart';
import 'package:test/test.dart';

void main() {
  final aFaire = Tache(id: 't1', titre: 'Lire');
  final faite = Tache(id: 't2', titre: 'Écrire', faite: true);

  test('« Toutes » accepte toutes les tâches', () {
    expect(Filtre.toutes.accepte(aFaire), isTrue);
    expect(Filtre.toutes.accepte(faite), isTrue);
  });

  test('« À faire » n\'accepte que les tâches non faites', () {
    expect(Filtre.aFaire.accepte(aFaire), isTrue);
    expect(Filtre.aFaire.accepte(faite), isFalse);
  });

  test('« Faites » n\'accepte que les tâches faites', () {
    expect(Filtre.faites.accepte(aFaire), isFalse);
    expect(Filtre.faites.accepte(faite), isTrue);
  });

  test('filtrer ne modifie jamais la tâche', () {
    final avant = Tache(id: 't1', titre: 'Lire');
    for (final filtre in Filtre.values) {
      filtre.accepte(avant);
    }
    expect(avant, Tache(id: 't1', titre: 'Lire'));
  });

  test('libellés affichables', () {
    expect(
      [for (final f in Filtre.values) f.libelle],
      ['Toutes', 'À faire', 'Faites'],
    );
  });

  test('chaque filtre a son message quand il ne retient rien', () {
    expect(Filtre.toutes.messageVide, 'Aucune tâche');
    expect(Filtre.aFaire.messageVide, 'Aucune tâche à faire');
    expect(Filtre.faites.messageVide, 'Aucune tâche faite');
  });
}
