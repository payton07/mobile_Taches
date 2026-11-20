import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mes_taches/ecrans/ecran_liste.dart';
import 'package:mes_taches/modele/taches.dart';



/// Affiche l'écran de liste dans une application Material minimale.
Future<void> afficherEcran(WidgetTester tester) =>
    tester.pumpWidget(const MaterialApp(home: EcranListe()));

/// Touche le segment [libelle] du sélecteur de filtre.
Future<void> choisirFiltre(WidgetTester tester, String libelle) async {
  await tester.tap(find.text(libelle));
  await tester.pump();
}

/// La case à cocher de la ligne qui affiche [titre].
Finder caseDe(String titre) => find.descendant(
  of: find.widgetWithText(ListTile, titre),
  matching: find.byType(Checkbox),
);

void main() {


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

          await tester.tap(find.text('Ajouter'));
          await tester.pump();

          expect(find.text('6 à faire'), findsOneWidget);
          // La nouvelle tâche est en bas de la liste : on fait défiler jusqu'à elle.
          await tester.scrollUntilVisible(find.text('Nouvelle tâche 1'), 100);
          expect(find.text('Nouvelle tâche 1'), findsOneWidget);
        });

    testWidgets('deux ajouts donnent deux tâches distinctes', (tester) async {
      await afficherEcran(tester);

      await tester.tap(find.text('Ajouter'));
      await tester.pump();
      await tester.tap(find.text('Ajouter'));
      await tester.pump();

      expect(find.text('7 à faire'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Nouvelle tâche 2'), 100);
      expect(find.text('Nouvelle tâche 1'), findsOneWidget);
      expect(find.text('Nouvelle tâche 2'), findsOneWidget);
    });
  });


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
          expect(find.text('Aucune tâche'), findsOneWidget);
          expect(find.text('6 à faire'), findsOneWidget);

          await choisirFiltre(tester, 'À faire');
          expect(find.text('Installer Flutter'), findsOneWidget);
        });
  });
}