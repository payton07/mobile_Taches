import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mes_taches/ecrans/ecran_detail.dart';
import 'package:mes_taches/modele/taches.dart';

/// Affiche le détail de [tache], le 18/11/2026 à 15 h.
Future<void> afficherDetail(WidgetTester tester, Tache tache) =>
    tester.pumpWidget(MaterialApp(
      home: EcranDetail(tache: tache, aujourdhui: DateTime(2026, 11, 18, 15)),
    ));

void main() {
  testWidgets('affiche tout le contenu de la tâche', (tester) async {
    await afficherDetail(
      tester,
      Tache(
        id: 't4',
        titre: 'Appeler le dentiste',
        priorite: Priorite.haute,
        echeance: EcheanceDate(DateTime(2026, 11, 20)),
        note: 'avant midi',
      ),
    );

    expect(find.text('Appeler le dentiste'), findsOneWidget);
    expect(find.text('Haute'), findsOneWidget);
    expect(find.text('pour le 20/11'), findsOneWidget);
    expect(find.text('avant midi'), findsOneWidget);
    expect(find.text('À faire'), findsOneWidget);
  });

  testWidgets('affiche le titre complet, sans le couper', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final titreLong = 'Un titre vraiment très long ' * 10;

    await afficherDetail(tester, Tache(id: 't1', titre: titreLong));

    final titre = tester.widget<Text>(find.text(titreLong));
    expect(titre.maxLines, isNull);
    expect(titre.overflow, isNot(TextOverflow.ellipsis));
    expect(tester.takeException(), isNull); // aucun débordement
  });

  testWidgets('« aucune note » quand la tâche n\'en a pas', (tester) async {
    await afficherDetail(tester, Tache(id: 't1', titre: 'Lire'));

    expect(find.text('aucune note'), findsOneWidget);
  });

  testWidgets('signale le retard en texte et en couleur d\'alerte',
          (tester) async {
        await afficherDetail(
          tester,
          Tache(
            id: 't6',
            titre: 'Rendre la convention',
            echeance: EcheanceDate(DateTime(2026, 11, 2)),
          ),
        );

        final echeance = find.text('pour le 2/11 · en retard');
        expect(echeance, findsOneWidget);
        final couleurAlerte =
            Theme.of(tester.element(find.byType(EcranDetail))).colorScheme.error;
        expect(tester.widget<Text>(echeance).style?.color, couleurAlerte);
      });

  testWidgets('pas de mention de retard pour une tâche faite',
          (tester) async {
        await afficherDetail(
          tester,
          Tache(
            id: 't6',
            titre: 'Rendre la convention',
            echeance: EcheanceDate(DateTime(2026, 11, 2)),
            faite: true,
          ),
        );

        expect(find.text('pour le 2/11'), findsOneWidget);
        expect(find.text('Faite'), findsOneWidget);
      });
}