import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mes_taches/composants/ligne_tache.dart';
import 'package:mes_taches/modele/taches.dart';

/// Affiche [widget] dans un environnement Material minimal.
Future<void> afficher(WidgetTester tester, Widget widget) =>
    tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

void main() {
  testWidgets('affiche le titre et le libellé de la priorité', (tester) async {
    await afficher(
      tester,
      LigneTache(
        tache: Tache(id: 't1', titre: 'Lire', priorite: Priorite.haute),
        surBascule: () {},
      ),
    );

    expect(find.text('Lire'), findsOneWidget);
    expect(find.text('Haute'), findsOneWidget);
  });

  testWidgets('une tâche à faire a une case vide et un titre normal', (
    tester,
  ) async {
    await afficher(
      tester,
      LigneTache(
        tache: Tache(id: 't1', titre: 'Lire'),
        surBascule: () {},
      ),
    );

    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
    final titre = tester.widget<Text>(find.text('Lire'));
    expect(titre.style?.decoration, isNot(TextDecoration.lineThrough));
  });

  testWidgets('une tâche faite a une case cochée et un titre barré', (
    tester,
  ) async {
    await afficher(
      tester,
      LigneTache(
        tache: Tache(id: 't1', titre: 'Lire', faite: true),
        surBascule: () {},
      ),
    );

    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
    final titre = tester.widget<Text>(find.text('Lire'));
    expect(titre.style?.decoration, TextDecoration.lineThrough);
  });

  testWidgets('toucher la case ou la ligne appelle surBascule', (tester) async {
    var appels = 0;
    await afficher(
      tester,
      LigneTache(
        tache: Tache(id: 't1', titre: 'Lire'),
        surBascule: () => appels++,
      ),
    );

    await tester.tap(find.byType(Checkbox));
    expect(appels, 1);

    await tester.tap(find.text('Lire'));
    expect(appels, 2);
  });
}
