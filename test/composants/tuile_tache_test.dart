import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mes_taches/composants/tuile_tache.dart';
import 'package:mes_taches/modele/taches.dart';

/// Date fixe : les tests ne dépendent pas du jour où on les lance.
final aujourdhui = DateTime(2026, 11, 18, 15);

/// Affiche une tuile pour [tache], avec des callbacks facultatifs.
Future<void> afficherTuile(
  WidgetTester tester,
  Tache tache, {
  VoidCallback? surBascule,
  VoidCallback? surOuverture,
}) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(
      body: TuileTache(
        tache: tache,
        aujourdhui: aujourdhui,
        surBascule: surBascule ?? () {},
        surOuverture: surOuverture ?? () {},
      ),
    ),
  ),
);

/// Couleur du texte [texte] affiché à l'écran.
Color? couleurDe(WidgetTester tester, String texte) =>
    tester.widget<Text>(find.text(texte)).style?.color;

/// Couleur d'alerte du thème courant.
Color couleurAlerte(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(TuileTache))).colorScheme.error;

void main() {
  group('affichage', () {
    testWidgets('titre, priorité et libellé de l\'échéance', (tester) async {
      await afficherTuile(
        tester,
        Tache(
          id: 't1',
          titre: 'Lire',
          priorite: Priorite.haute,
          echeance: EcheanceHebdomadaire(DateTime.saturday),
        ),
      );

      expect(find.text('Lire'), findsOneWidget);
      expect(find.text('Haute'), findsOneWidget);
      expect(find.text('chaque samedi'), findsOneWidget);
    });

    testWidgets('« sans échéance » en sous-titre par défaut', (tester) async {
      await afficherTuile(tester, Tache(id: 't1', titre: 'Lire'));

      expect(find.text('sans échéance'), findsOneWidget);
    });

    testWidgets('une tâche à faire : case vide, titre normal', (tester) async {
      await afficherTuile(tester, Tache(id: 't1', titre: 'Lire'));

      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
      final titre = tester.widget<Text>(find.text('Lire'));
      expect(titre.style?.decoration, isNot(TextDecoration.lineThrough));
    });

    testWidgets('une tâche faite : case cochée, titre barré', (tester) async {
      await afficherTuile(tester, Tache(id: 't1', titre: 'Lire', faite: true));

      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
      final titre = tester.widget<Text>(find.text('Lire'));
      expect(titre.style?.decoration, TextDecoration.lineThrough);
    });
  });

  group('retard', () {
    testWidgets('échéance passée, non faite : couleur d\'alerte', (
      tester,
    ) async {
      await afficherTuile(
        tester,
        Tache(
          id: 't1',
          titre: 'Lire',
          echeance: EcheanceDate(DateTime(2026, 11, 17)),
        ),
      );

      expect(couleurDe(tester, 'pour le 17/11'), couleurAlerte(tester));
    });

    testWidgets('échéance aujourd\'hui : pas d\'alerte', (tester) async {
      await afficherTuile(
        tester,
        Tache(
          id: 't1',
          titre: 'Lire',
          echeance: EcheanceDate(DateTime(2026, 11, 18)),
        ),
      );

      expect(couleurDe(tester, 'pour le 18/11'), isNot(couleurAlerte(tester)));
    });

    testWidgets('échéance passée mais tâche faite : pas d\'alerte', (
      tester,
    ) async {
      await afficherTuile(
        tester,
        Tache(
          id: 't1',
          titre: 'Lire',
          echeance: EcheanceDate(DateTime(2026, 11, 17)),
          faite: true,
        ),
      );

      expect(couleurDe(tester, 'pour le 17/11'), isNot(couleurAlerte(tester)));
    });
  });

  group('fonctions de rappel', () {
    testWidgets('toucher la case appelle surBascule, pas surOuverture', (
      tester,
    ) async {
      var bascules = 0;
      var ouvertures = 0;
      await afficherTuile(
        tester,
        Tache(id: 't1', titre: 'Lire'),
        surBascule: () => bascules++,
        surOuverture: () => ouvertures++,
      );

      await tester.tap(find.byType(Checkbox));

      expect(bascules, 1);
      expect(ouvertures, 0);
    });

    testWidgets('toucher le titre appelle surOuverture, pas surBascule', (
      tester,
    ) async {
      var bascules = 0;
      var ouvertures = 0;
      await afficherTuile(
        tester,
        Tache(id: 't1', titre: 'Lire'),
        surBascule: () => bascules++,
        surOuverture: () => ouvertures++,
      );

      await tester.tap(find.text('Lire'));

      expect(ouvertures, 1);
      expect(bascules, 0);
    });
  });

  group('mise en page', () {
    testWidgets('un titre très long tient sur une ligne, terminé par « … »', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final titreLong = 'Un titre vraiment très long ' * 10;

      await afficherTuile(
        tester,
        Tache(
          id: 't1',
          titre: titreLong,
          priorite: Priorite.normale,
          echeance: EcheanceHebdomadaire(DateTime.wednesday),
        ),
      );

      final titre = tester.widget<Text>(find.text(titreLong));
      expect(titre.maxLines, 1);
      expect(titre.overflow, TextOverflow.ellipsis);
      expect(tester.takeException(), isNull); // aucun débordement
    });
  });
}
