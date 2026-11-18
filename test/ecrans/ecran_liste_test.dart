import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mes_taches/ecrans/ecran_liste.dart';

Future<void> afficherEcran(WidgetTester tester) =>
    tester.pumpWidget(const MaterialApp(home: EcranListe()));

void main() {
  testWidgets('affiche le compteur et les tâches d\'exemple', (tester) async {
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

  testWidgets('cocher puis décocher une tâche met à jour le compteur',
          (tester) async {
        await afficherEcran(tester);
        final caseRelire = find.descendant(
          of: find.widgetWithText(ListTile, 'Relire le CM 01'),
          matching: find.byType(Checkbox),
        );
        expect(find.text('5 à faire'), findsOneWidget);

        await tester.tap(caseRelire);
        await tester.pump();

        expect(find.text('4 à faire'), findsOneWidget);
        expect(tester.widget<Checkbox>(caseRelire).value, isTrue);

        await tester.tap(caseRelire);
        await tester.pump();

        expect(find.text('5 à faire'), findsOneWidget);
        expect(tester.widget<Checkbox>(caseRelire).value, isFalse);
      });
}