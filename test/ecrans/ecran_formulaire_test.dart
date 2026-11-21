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

  testWidgets('rouvrir le calendrier propose la date déjà choisie', (
    tester,
  ) async {
    await ouvrirFormulaire(tester, (_) {});

    await tester.tap(find.text('sans échéance'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('25'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('pour le 25/11'));
    await tester.pumpAndSettle();
    final calendrier = tester.widget<CalendarDatePicker>(
      find.byType(CalendarDatePicker),
    );
    expect(calendrier.initialDate, DateTime(2026, 11, 25));
  });

  testWidgets("« Retirer l'échéance » revient à « sans échéance »", (
    tester,
  ) async {
    await ouvrirFormulaire(tester, (_) {});

    await tester.tap(find.text('sans échéance'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('25'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Retirer l'échéance"));
    await tester.pump();

    expect(find.text('sans échéance'), findsOneWidget);
    expect(find.text("Retirer l'échéance"), findsNothing);
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

  // -------------------------------------------------------------------------
  // E2 : valider les saisies
  // -------------------------------------------------------------------------
  group('E2 : valider les saisies', () {
    /// Touche « Enregistrer », après l'avoir fait défiler à l'écran.
    Future<void> enregistrer(WidgetTester tester) async {
      await tester.ensureVisible(find.text('Enregistrer'));
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
    }

    testWidgets('aucun message à l\'ouverture du formulaire', (tester) async {
      await ouvrirFormulaire(tester, (_) {});

      expect(find.text('Le titre est obligatoire'), findsNothing);
    });

    testWidgets('un titre fait d\'espaces est refusé, le formulaire reste '
        'ouvert', (tester) async {
      var ferme = false;
      await ouvrirFormulaire(tester, (_) => ferme = true);

      await tester.enterText(champ('Titre'), '    ');
      await enregistrer(tester);

      expect(find.text('Le titre est obligatoire'), findsOneWidget);
      expect(find.byType(EcranFormulaire), findsOneWidget);
      expect(ferme, isFalse);
    });

    testWidgets('un titre de 61 caractères est refusé, message sous le champ', (
      tester,
    ) async {
      var ferme = false;
      await ouvrirFormulaire(tester, (_) => ferme = true);

      await tester.enterText(champ('Titre'), 'a' * 61);
      await enregistrer(tester);

      final message = find.text('Le titre fait 60 caractères au plus');
      expect(message, findsOneWidget);
      // Le message appartient bien au champ du titre.
      expect(
        find.descendant(of: champ('Titre'), matching: message),
        findsOneWidget,
      );
      expect(ferme, isFalse);
    });

    testWidgets('un titre de 60 caractères est accepté', (tester) async {
      Tache? recue;
      await ouvrirFormulaire(tester, (tache) => recue = tache);

      await tester.enterText(champ('Titre'), 'a' * 60);
      await enregistrer(tester);

      expect(recue?.titre, 'a' * 60);
    });

    testWidgets('une note de 201 caractères est refusée', (tester) async {
      var ferme = false;
      await ouvrirFormulaire(tester, (_) => ferme = true);

      await tester.enterText(champ('Titre'), 'Titre valide');
      await tester.enterText(champ('Note (facultative)'), 'n' * 201);
      await enregistrer(tester);

      expect(find.text('La note fait 200 caractères au plus'), findsOneWidget);
      expect(ferme, isFalse);
    });

    testWidgets('les espaces de bord sont retirés du titre et de la note', (
      tester,
    ) async {
      Tache? recue;
      await ouvrirFormulaire(tester, (tache) => recue = tache);

      await tester.enterText(champ('Titre'), '   Réviser   ');
      await tester.enterText(champ('Note (facultative)'), '  chapitre 3  ');
      await enregistrer(tester);

      expect(recue?.titre, 'Réviser');
      expect(recue?.note, 'chapitre 3');
    });

    testWidgets('une note faite d\'espaces donne une tâche sans note', (
      tester,
    ) async {
      Tache? recue;
      await ouvrirFormulaire(tester, (tache) => recue = tache);

      await tester.enterText(champ('Titre'), 'Sans note');
      await tester.enterText(champ('Note (facultative)'), '    ');
      await enregistrer(tester);

      expect(recue, isNotNull);
      expect(recue!.note, isNull);
    });

    testWidgets('après un refus, le message disparaît dès la correction', (
      tester,
    ) async {
      Tache? recue;
      await ouvrirFormulaire(tester, (tache) => recue = tache);

      await enregistrer(tester);
      expect(find.text('Le titre est obligatoire'), findsOneWidget);

      await tester.enterText(champ('Titre'), 'Corrigé');
      await tester.pump();
      expect(find.text('Le titre est obligatoire'), findsNothing);

      await enregistrer(tester);
      expect(recue?.titre, 'Corrigé');
    });
  });

  // -------------------------------------------------------------------------
  // G1 : modifier une tâche (même formulaire, même identifiant)
  // -------------------------------------------------------------------------
  group('G1 : modifier une tâche', () {
    /// Ouvre le formulaire en modification de [tache] depuis un écran hôte.
    Future<void> ouvrirModification(
      WidgetTester tester,
      Tache tache,
      void Function(Tache?) recevoir,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  recevoir(
                    await Navigator.of(context).push<Tache>(
                      MaterialPageRoute(
                        builder: (_) => EcranFormulaire.modification(
                          tache: tache,
                          aujourdhui: aujourdhui,
                        ),
                      ),
                    ),
                  );
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

    final existante = Tache(
      id: 't9',
      titre: 'Rapport',
      priorite: Priorite.haute,
      echeance: EcheanceDate(DateTime(2026, 12, 1)),
      note: 'brouillon',
      faite: true,
    );

    testWidgets('le formulaire est pré-rempli avec la tâche', (tester) async {
      await ouvrirModification(tester, existante, (_) {});

      expect(find.text('Modifier la tâche'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Rapport'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'brouillon'), findsOneWidget);
      expect(find.text('pour le 1/12'), findsOneWidget);
      expect(
        tester
            .widget<SegmentedButton<Priorite>>(
              find.byType(SegmentedButton<Priorite>),
            )
            .selected,
        {Priorite.haute},
      );
    });

    testWidgets('enregistrer garde l\'identifiant et l\'état de la tâche', (
      tester,
    ) async {
      Tache? recue;
      await ouvrirModification(tester, existante, (tache) => recue = tache);

      await tester.enterText(champ('Titre'), 'Rapport final');
      await tester.tap(find.text('Normale'));
      await tester.ensureVisible(find.text('Enregistrer'));
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      expect(
        recue,
        existante.copieAvec(titre: 'Rapport final', priorite: Priorite.normale),
      );
    });

    testWidgets('une échéance déjà passée laissée telle quelle est acceptée', (
      tester,
    ) async {
      final enRetard = Tache(
        id: 't6',
        titre: 'Rendre la convention',
        echeance: EcheanceDate(DateTime(2026, 11, 2)),
      );
      Tache? recue;
      await ouvrirModification(tester, enRetard, (tache) => recue = tache);

      await tester.enterText(champ('Titre'), 'Rendre la convention signée');
      await tester.ensureVisible(find.text('Enregistrer'));
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      expect(recue?.titre, 'Rendre la convention signée');
      expect(recue?.echeance, enRetard.echeance);
    });

    testWidgets('les règles de E2 s\'appliquent aussi à la modification', (
      tester,
    ) async {
      var ferme = false;
      await ouvrirModification(tester, existante, (_) => ferme = true);

      await tester.enterText(champ('Titre'), '   ');
      await tester.ensureVisible(find.text('Enregistrer'));
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      expect(find.text('Le titre est obligatoire'), findsOneWidget);
      expect(ferme, isFalse);
    });

    testWidgets('une échéance hebdomadaire s\'affiche et peut être retirée', (
      tester,
    ) async {
      Tache? recue;
      await ouvrirModification(
        tester,
        Tache(id: 't8', titre: 'Sport', echeance: EcheanceHebdomadaire(5)),
        (tache) => recue = tache,
      );

      expect(find.text('chaque vendredi'), findsOneWidget);
      await tester.tap(find.text("Retirer l'échéance"));
      await tester.pump();
      await tester.ensureVisible(find.text('Enregistrer'));
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      expect(recue?.echeance, const SansEcheance());
    });
  });
}
