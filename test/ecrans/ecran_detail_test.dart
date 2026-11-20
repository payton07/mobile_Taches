import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mes_taches/ecrans/ecran_detail.dart';
import 'package:mes_taches/modele/taches.dart';

/// Affiche le détail de [tache], le 18/11/2026 à 15 h.
Future<void> afficherDetail(WidgetTester tester, Tache tache) =>
    tester.pumpWidget(MaterialApp(
      home: EcranDetail(tache: tache, aujourdhui: DateTime(2026, 11, 18, 15)),
    ));
/// Ouvre le détail de [tache] depuis un écran hôte et transmet à [recevoir]
/// la valeur renvoyée à sa fermeture.
Future<void> ouvrirDepuisHote(
    WidgetTester tester,
    Tache tache,
    void Function(Tache?) recevoir,
    ) async {
  await tester.pumpWidget(MaterialApp(
    home: Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () async {
            final resultat = await Navigator.of(context).push<Tache>(
              MaterialPageRoute(
                builder: (_) => EcranDetail(
                  tache: tache,
                  aujourdhui: DateTime(2026, 11, 18, 15),
                ),
              ),
            );
            recevoir(resultat);
          },
          child: const Text('Ouvrir'),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('Ouvrir'));
  await tester.pumpAndSettle();
}
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
  group('D2 : agir depuis le détail', () {
    testWidgets('le libellé du bouton dépend de l\'état', (tester) async {
      await afficherDetail(tester, Tache(id: 't1', titre: 'Lire'));
      expect(find.text('Marquer comme faite'), findsOneWidget);

      await afficherDetail(
          tester, Tache(id: 't1', titre: 'Lire', faite: true));
      expect(find.text('Marquer à faire'), findsOneWidget);
    });

    testWidgets('« Marquer comme faite » ferme et renvoie la tâche faite',
            (tester) async {
          final tache = Tache(id: 't1', titre: 'Lire', note: 'chapitre 2');
          Tache? recu;
          await ouvrirDepuisHote(tester, tache, (resultat) => recu = resultat);

          await tester.tap(find.text('Marquer comme faite'));
          await tester.pumpAndSettle();

          expect(find.byType(EcranDetail), findsNothing);
          expect(recu, tache.copieAvec(faite: true));
          expect(tache.faite, isFalse); // la tâche d'origine est intacte
        });

    testWidgets('« Marquer à faire » renvoie la tâche à faire',
            (tester) async {
          final tache = Tache(id: 't1', titre: 'Lire', faite: true);
          Tache? recu;
          await ouvrirDepuisHote(tester, tache, (resultat) => recu = resultat);

          await tester.tap(find.text('Marquer à faire'));
          await tester.pumpAndSettle();

          expect(recu, tache.copieAvec(faite: false));
        });

    testWidgets('un simple retour ne renvoie rien', (tester) async {
      var recu = false;
      Tache? resultat = Tache(id: 'x', titre: 'non nul');
      await ouvrirDepuisHote(tester, Tache(id: 't1', titre: 'Lire'), (r) {
        recu = true;
        resultat = r;
      });

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(recu, isTrue);
      expect(resultat, isNull);
    });
  });
}