import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mes_taches/composants/compteur_taches.dart';

Future<void> afficher(WidgetTester tester, Widget widget) =>
    tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

void main() {
  testWidgets('affiche le nombre de tâches à faire et la progression',
          (tester) async {
        await afficher(tester, const CompteurTaches(faites: 1, total: 3));

        expect(find.text('2 à faire'), findsOneWidget);
        expect(find.text('1/3 faite'), findsOneWidget);
        final barre = tester.widget<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator));
        expect(barre.value, closeTo(1 / 3, 1e-9));
      });

  testWidgets('accorde « faites » au pluriel', (tester) async {
    await afficher(tester, const CompteurTaches(faites: 2, total: 3));

    expect(find.text('2/3 faites'), findsOneWidget);
  });

  testWidgets('une liste vide ne provoque pas de division par zéro',
          (tester) async {
        await afficher(tester, const CompteurTaches(faites: 0, total: 0));

        expect(find.text('0 à faire'), findsOneWidget);
        final barre = tester.widget<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator));
        expect(barre.value, 0);
      });
}