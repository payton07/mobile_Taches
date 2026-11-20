import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mes_taches/ecrans/ecran_liste.dart';
import 'package:mes_taches/modele/taches.dart';

// ---------------------------------------------------------------------------
// Utilitaires
// ---------------------------------------------------------------------------

/// Affiche l'écran de liste avec une horloge figée au 18/11/2026 à 15 h,
/// pour que les tests ne dépendent pas du jour où on les lance.
Future<void> afficherEcran(WidgetTester tester) => tester.pumpWidget(
  MaterialApp(
    home: EcranListe(maintenant: () => DateTime(2026, 11, 18, 15)),
  ),
);

/// Simule un écran de [largeur] pixels, rétabli à la fin du test.
void fixerLargeur(WidgetTester tester, double largeur) {
  tester.view.physicalSize = Size(largeur, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Touche le segment [libelle] du sélecteur de filtre.
Future<void> choisirFiltre(WidgetTester tester, String libelle) async {
  await tester.tap(find.text(libelle));
  await tester.pump();
}

/// Touche le bouton « Ajouter » [fois] fois.
Future<void> ajouter(WidgetTester tester, {int fois = 1}) async {
  for (var i = 0; i < fois; i++) {
    await tester.tap(find.text('Ajouter'));
    await tester.pump();
  }
}

/// La case à cocher de la tuile qui affiche [titre].
Finder caseDe(String titre) => find.descendant(
  of: find.widgetWithText(ListTile, titre),
  matching: find.byType(Checkbox),
);

/// Couleur d'alerte du thème de l'écran.
Color couleurAlerte(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(EcranListe))).colorScheme.error;

/// Couleur du texte [texte] affiché à l'écran.
Color? couleurDe(WidgetTester tester, String texte) =>
    tester.widget<Text>(find.text(texte)).style?.color;

void main() {
  // -------------------------------------------------------------------------
  // B1 : affichage et ajout
  // -------------------------------------------------------------------------
  group('B1 : affichage et ajout', () {
    testWidgets('affiche le compteur et les tâches d\'exemple',
            (tester) async {
          await afficherEcran(tester);

          // 6 tâches d'exemple, dont une faite (t1).
          expect(find.text('5 à faire'), findsOneWidget);
          expect(find.text('1/6 faite'), findsOneWidget);
          expect(find.text('Installer Flutter'), findsOneWidget);
          expect(find.text('Relire le CM 01'), findsOneWidget);
        });

    testWidgets('« Ajouter » ajoute une tâche et met à jour le compteur',
            (tester) async {
          await afficherEcran(tester);

          await ajouter(tester);

          expect(find.text('6 à faire'), findsOneWidget);
          // La nouvelle tâche est en bas de la liste : on fait défiler jusqu'à elle.
          await tester.scrollUntilVisible(find.text('Nouvelle tâche 1'), 100);
          expect(find.text('Nouvelle tâche 1'), findsOneWidget);
        });

    testWidgets('deux ajouts donnent deux tâches distinctes', (tester) async {
      await afficherEcran(tester);

      await ajouter(tester, fois: 2);

      expect(find.text('7 à faire'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Nouvelle tâche 2'), 100);
      expect(find.text('Nouvelle tâche 1'), findsOneWidget);
      expect(find.text('Nouvelle tâche 2'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // B2 : cocher une tâche
  // -------------------------------------------------------------------------
  group('B2 : cocher une tâche', () {
    testWidgets('cocher puis décocher une tâche met à jour le compteur',
            (tester) async {
          await afficherEcran(tester);
          expect(find.text('5 à faire'), findsOneWidget);

          await tester.tap(caseDe('Relire le CM 01'));
          await tester.pump();

          expect(find.text('4 à faire'), findsOneWidget);
          expect(tester.widget<Checkbox>(caseDe('Relire le CM 01')).value, isTrue);

          await tester.tap(caseDe('Relire le CM 01'));
          await tester.pump();

          expect(find.text('5 à faire'), findsOneWidget);
          expect(
              tester.widget<Checkbox>(caseDe('Relire le CM 01')).value, isFalse);
        });
  });

  // -------------------------------------------------------------------------
  // C1 : filtrer la liste
  // -------------------------------------------------------------------------
  group('C1 : filtrer la liste', () {
    testWidgets('« Toutes » est le filtre par défaut', (tester) async {
      await afficherEcran(tester);

      final selecteur = tester.widget<SegmentedButton<Filtre>>(
          find.byType(SegmentedButton<Filtre>));
      expect(selecteur.selected, {Filtre.toutes});
      expect(find.text('Installer Flutter'), findsOneWidget);
      expect(find.text('Relire le CM 01'), findsOneWidget);
    });

    testWidgets('« À faire » masque les tâches faites sans changer le compteur',
            (tester) async {
          await afficherEcran(tester);
          await choisirFiltre(tester, 'À faire');

          expect(find.text('Installer Flutter'), findsNothing);
          expect(find.text('Relire le CM 01'), findsOneWidget);
          expect(find.text('5 à faire'), findsOneWidget);
        });

    testWidgets('« Faites » n\'affiche que les tâches faites', (tester) async {
      await afficherEcran(tester);
      await choisirFiltre(tester, 'Faites');

      expect(find.text('Installer Flutter'), findsOneWidget);
      expect(find.text('Relire le CM 01'), findsNothing);
      expect(find.text('5 à faire'), findsOneWidget);
    });

    testWidgets('cocher depuis « À faire » fait disparaître la tâche',
            (tester) async {
          await afficherEcran(tester);
          await choisirFiltre(tester, 'À faire');

          await tester.tap(caseDe('Relire le CM 01'));
          await tester.pump();

          expect(find.text('Relire le CM 01'), findsNothing);
          expect(find.text('4 à faire'), findsOneWidget);
        });

    testWidgets(
        'décocher depuis « Faites » fait réapparaître la tâche dans « À faire »',
            (tester) async {
          await afficherEcran(tester);
          await choisirFiltre(tester, 'Faites');

          await tester.tap(caseDe('Installer Flutter'));
          await tester.pump();

          expect(find.text('Installer Flutter'), findsNothing);
          expect(find.text('Aucune tâche faite'), findsOneWidget);
          expect(find.text('6 à faire'), findsOneWidget);

          await choisirFiltre(tester, 'À faire');
          expect(find.text('Installer Flutter'), findsOneWidget);
        });
  });

  // -------------------------------------------------------------------------
  // C2 : tuile de tâche
  // -------------------------------------------------------------------------
  group('C2 : tuile de tâche', () {
    testWidgets('affiche le libellé de l\'échéance de chaque tâche',
            (tester) async {
          await afficherEcran(tester);

          expect(find.text('pour le 20/11'), findsOneWidget); // t4
          expect(find.text('sans échéance'), findsWidgets); // t1, t2, t3
        });

    testWidgets('signale en couleur d\'alerte une tâche en retard',
            (tester) async {
          await afficherEcran(tester);

          // t6, échéance le 2/11 : en retard le 18/11.
          await tester.scrollUntilVisible(find.text('pour le 2/11'), 100);
          expect(couleurDe(tester, 'pour le 2/11'), couleurAlerte(tester));

          // t4, échéance le 20/11 : pas encore en retard (on remonte).
          await tester.scrollUntilVisible(find.text('pour le 20/11'), -100);
          expect(couleurDe(tester, 'pour le 20/11'),
              isNot(couleurAlerte(tester)));
        });

    testWidgets('toucher le titre ne coche pas la tâche', (tester) async {
      await afficherEcran(tester);

      await tester.tap(find.text('Relire le CM 01'));
      await tester.pump();

      expect(find.text('5 à faire'), findsOneWidget);
      expect(
          tester.widget<Checkbox>(caseDe('Relire le CM 01')).value, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // C3 : mise en page, contraintes et cas limites
  // -------------------------------------------------------------------------
  group('C3 : mise en page, contraintes et cas limites', () {
    testWidgets('le compteur et le filtre restent fixes, seule la liste défile',
            (tester) async {
          await afficherEcran(tester);
          await ajouter(tester, fois: 5); // assez de tâches pour devoir défiler

          final compteurAvant = tester.getTopLeft(find.text('10 à faire'));
          final filtreAvant =
          tester.getTopLeft(find.byType(SegmentedButton<Filtre>));

          await tester.drag(find.byType(ListView), const Offset(0, -300));
          await tester.pump();

          final defilement = tester
              .state<ScrollableState>(find.descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          ))
              .position
              .pixels;
          expect(defilement, greaterThan(0)); // la liste a bien défilé…
          expect(tester.getTopLeft(find.text('10 à faire')), compteurAvant);
          expect(tester.getTopLeft(find.byType(SegmentedButton<Filtre>)),
              filtreAvant); // … mais pas l'en-tête
        });

    testWidgets('le message vide est centré et dépend du filtre',
            (tester) async {
          fixerLargeur(tester, 800);
          await afficherEcran(tester);
          await choisirFiltre(tester, 'Faites');
          await tester.tap(caseDe('Installer Flutter'));
          await tester.pump();

          final message = find.text('Aucune tâche faite');
          expect(message, findsOneWidget);
          expect(tester.getCenter(message).dx, 400); // centré horizontalement
        });

    for (final largeur in [360.0, 1280.0]) {
      testWidgets('aucun débordement à ${largeur.toInt()} pixels de large',
              (tester) async {
            fixerLargeur(tester, largeur);
            await afficherEcran(tester);
            expect(tester.takeException(), isNull);

            for (final filtre in ['À faire', 'Faites', 'Toutes']) {
              await choisirFiltre(tester, filtre);
              expect(tester.takeException(), isNull, reason: filtre);
            }

            await ajouter(tester, fois: 3);
            expect(tester.takeException(), isNull);
          });
    }

    testWidgets('sur grand écran, le contenu ne dépasse pas 720 pixels',
            (tester) async {
          fixerLargeur(tester, 1280);
          await afficherEcran(tester);

          expect(tester.getSize(find.byType(ListView)).width, 720);
        });
  });
}