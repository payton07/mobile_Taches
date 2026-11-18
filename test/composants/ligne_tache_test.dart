import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
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
          tache: Tache(id: 't1', titre: 'Lire', priorite: Priorite.haute)),
    );

    expect(find.text('Lire'), findsOneWidget);
    expect(find.text('Haute'), findsOneWidget);
  });

  testWidgets('une tâche à faire a un cercle vide et un titre normal',
          (tester) async {
        await afficher(tester, LigneTache(tache: Tache(id: 't1', titre: 'Lire')));

        expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
        expect(find.byIcon(Icons.check_circle), findsNothing);
        final titre = tester.widget<Text>(find.text('Lire'));
        expect(titre.style?.decoration, isNot(TextDecoration.lineThrough));
      });

  testWidgets('une tâche faite est cochée et son titre barré', (tester) async {
    await afficher(
      tester,
      LigneTache(tache: Tache(id: 't1', titre: 'Lire', faite: true)),
    );

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    final titre = tester.widget<Text>(find.text('Lire'));
    expect(titre.style?.decoration, TextDecoration.lineThrough);
  });
}