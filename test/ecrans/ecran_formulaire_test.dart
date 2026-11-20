import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mes_taches/ecrans/ecran_formulaire.dart';
import 'package:mes_taches/modele/taches.dart';

/// Date du jour figée : le 18/11/2026 à 15 h.
final aujourdhui = DateTime(2026, 11, 18, 15);

/// Ouvre le formulaire depuis un écran hôte et transmet à [recevoir] la
/// valeur renvoyée à sa fermeture.
Future<void> ouvrirFormulaire(
  WidgetTester tester,
  void Function(Tache?) recevoir,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async {
              final resultat = await Navigator.of(context).push<Tache>(
                MaterialPageRoute(
                  builder: (_) => EcranFormulaire(
                    identifiant: 'id-test',
                    aujourdhui: aujourdhui,
                  ),
                ),
              );
              recevoir(resultat);
            },
            child: const Text('Ouvrir'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Ouvrir'));
  await tester.pumpAndSettle();
}

/// Le champ de saisie dont le libellé est [libelle].
Finder champ(String libelle) => find.widgetWithText(TextFormField, libelle);

void main() {
  testWidgets('affiche les quatre champs, « Normale » choisie par défaut', (
    tester,
  ) async {
    await ouvrirFormulaire(tester, (_) {});

    expect(champ('Titre'), findsOneWidget);
    expect(find.byType(SegmentedButton<Priorite>), findsOneWidget);
    expect(find.text('sans échéance'), findsOneWidget);
    expect(champ('Note (facultative)'), findsOneWidget);
    expect(
      tester
          .widget<SegmentedButton<Priorite>>(
            find.byType(SegmentedButton<Priorite>),
          )
          .selected,
      {Priorite.normale},
    );
  });

  testWidgets(
    '« Enregistrer » renvoie la tâche saisie et ferme le formulaire',
    (tester) async {
      Tache? recue;
      await ouvrirFormulaire(tester, (tache) => recue = tache);

      await tester.enterText(champ('Titre'), 'Réviser le CM 02');
      await tester.tap(find.text('Haute'));
      await tester.enterText(champ('Note (facultative)'), 'chapitre 3');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      expect(find.byType(EcranFormulaire), findsNothing);
      expect(
        recue,
        Tache(
          id: 'id-test',
          titre: 'Réviser le CM 02',
          priorite: Priorite.haute,
          note: 'chapitre 3',
        ),
      );
    },
  );

  testWidgets('une note vide donne une tâche sans note', (tester) async {
    Tache? recue;
    await ouvrirFormulaire(tester, (tache) => recue = tache);

    await tester.enterText(champ('Titre'), 'Sans note');
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    expect(recue?.note, isNull);
  });

  testWidgets('une date choisie au calendrier devient l\'échéance', (
    tester,
  ) async {
    Tache? recue;
    await ouvrirFormulaire(tester, (tache) => recue = tache);

    await tester.tap(find.text('sans échéance'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('25')); // calendrier ouvert sur novembre 2026
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('pour le 25/11'), findsOneWidget);

    await tester.enterText(champ('Titre'), 'Rendre le TP');
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    expect(recue?.echeance, EcheanceDate(DateTime(2026, 11, 25)));
  });

  testWidgets('« Retirer la date » revient à « sans échéance »', (
    tester,
  ) async {
    await ouvrirFormulaire(tester, (_) {});

    await tester.tap(find.text('sans échéance'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('25'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retirer la date'));
    await tester.pump();

    expect(find.text('sans échéance'), findsOneWidget);
    expect(find.text('Retirer la date'), findsNothing);
  });

  testWidgets('un titre vide est refusé et le formulaire reste ouvert', (
    tester,
  ) async {
    var ferme = false;
    await ouvrirFormulaire(tester, (_) => ferme = true);

    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    expect(find.text('Le titre est obligatoire'), findsOneWidget);
    expect(find.byType(EcranFormulaire), findsOneWidget);
    expect(ferme, isFalse);
  });

  testWidgets('un simple retour ne renvoie rien', (tester) async {
    var appele = false;
    Tache? recue;
    await ouvrirFormulaire(tester, (tache) {
      appele = true;
      recue = tache;
    });

    await tester.enterText(champ('Titre'), 'Abandonnée');
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(appele, isTrue);
    expect(recue, isNull);
  });

  testWidgets('aucun débordement à 360 pixels de large', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await ouvrirFormulaire(tester, (_) {});
    await tester.tap(find.text('sans échéance'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('25'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
