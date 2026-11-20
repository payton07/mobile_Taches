import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mes_taches/ecrans/ecran_liste.dart';
import 'package:mes_taches/modele/taches.dart';
import 'package:mes_taches/composants/composants.dart';
import 'package:mes_taches/ecrans/ecran_detail.dart';
import 'package:mes_taches/ecrans/ecran_formulaire.dart';

// ---------------------------------------------------------------------------
// Utilitaires
// ---------------------------------------------------------------------------

/// Affiche l'écran de liste avec une horloge figée au 18/11/2026 à 15 h,
/// pour que les tests ne dépendent pas du jour où on les lance.
Future<void> afficherEcran(WidgetTester tester) => tester.pumpWidget(
  MaterialApp(home: EcranListe(maintenant: () => DateTime(2026, 11, 18, 15))),
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

/// Crée, par le formulaire, une tâche de titre [titre] : touche « Ajouter »,
/// saisit le titre puis touche « Enregistrer ».
Future<void> creer(WidgetTester tester, String titre) async {
  await tester.tap(find.text('Ajouter'));
  await tester.pumpAndSettle();
  await tester.enterText(find.widgetWithText(TextFormField, 'Titre'), titre);
  await tester.tap(find.text('Enregistrer'));
  await tester.pumpAndSettle();
}

/// Crée [fois] tâches par le formulaire : « Nouvelle tâche 1 », « 2 »…
Future<void> ajouter(WidgetTester tester, {int fois = 1}) async {
  for (var i = 1; i <= fois; i++) {
    await creer(tester, 'Nouvelle tâche $i');
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
    testWidgets('affiche le compteur et les tâches d\'exemple', (tester) async {
      await afficherEcran(tester);

      // 6 tâches d'exemple, dont une faite (t1).
      expect(find.text('5 à faire'), findsOneWidget);
      expect(find.text('1/6 faite'), findsOneWidget);
      expect(find.text('Installer Flutter'), findsOneWidget);
      expect(find.text('Relire le CM 01'), findsOneWidget);
    });

    testWidgets('une tâche ajoutée par le formulaire met à jour le compteur', (
      tester,
    ) async {
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
    testWidgets('cocher puis décocher une tâche met à jour le compteur', (
      tester,
    ) async {
      await afficherEcran(tester);
      expect(find.text('5 à faire'), findsOneWidget);

      await tester.tap(caseDe('Relire le CM 01'));
      await tester.pump();

      expect(find.text('4 à faire'), findsOneWidget);
      expect(tester.widget<Checkbox>(caseDe('Relire le CM 01')).value, isTrue);

      await tester.tap(caseDe('Relire le CM 01'));
      await tester.pump();

      expect(find.text('5 à faire'), findsOneWidget);
      expect(tester.widget<Checkbox>(caseDe('Relire le CM 01')).value, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // C1 : filtrer la liste
  // -------------------------------------------------------------------------
  group('C1 : filtrer la liste', () {
    testWidgets('« Toutes » est le filtre par défaut', (tester) async {
      await afficherEcran(tester);

      final selecteur = tester.widget<SegmentedButton<Filtre>>(
        find.byType(SegmentedButton<Filtre>),
      );
      expect(selecteur.selected, {Filtre.toutes});
      expect(find.text('Installer Flutter'), findsOneWidget);
      expect(find.text('Relire le CM 01'), findsOneWidget);
    });

    testWidgets(
      '« À faire » masque les tâches faites sans changer le compteur',
      (tester) async {
        await afficherEcran(tester);
        await choisirFiltre(tester, 'À faire');

        expect(find.text('Installer Flutter'), findsNothing);
        expect(find.text('Relire le CM 01'), findsOneWidget);
        expect(find.text('5 à faire'), findsOneWidget);
      },
    );

    testWidgets('« Faites » n\'affiche que les tâches faites', (tester) async {
      await afficherEcran(tester);
      await choisirFiltre(tester, 'Faites');

      expect(find.text('Installer Flutter'), findsOneWidget);
      expect(find.text('Relire le CM 01'), findsNothing);
      expect(find.text('5 à faire'), findsOneWidget);
    });

    testWidgets('cocher depuis « À faire » fait disparaître la tâche', (
      tester,
    ) async {
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
      },
    );
  });

  // -------------------------------------------------------------------------
  // C2 : tuile de tâche
  // -------------------------------------------------------------------------
  group('C2 : tuile de tâche', () {
    testWidgets('affiche le libellé de l\'échéance de chaque tâche', (
      tester,
    ) async {
      await afficherEcran(tester);

      expect(find.text('pour le 20/11'), findsOneWidget); // t4
      expect(find.text('sans échéance'), findsWidgets); // t1, t2, t3
    });

    testWidgets('signale en couleur d\'alerte une tâche en retard', (
      tester,
    ) async {
      await afficherEcran(tester);

      // t6, échéance le 2/11 : en retard le 18/11.
      await tester.scrollUntilVisible(find.text('pour le 2/11'), 100);
      expect(couleurDe(tester, 'pour le 2/11'), couleurAlerte(tester));

      // t4, échéance le 20/11 : pas encore en retard (on remonte).
      await tester.scrollUntilVisible(find.text('pour le 20/11'), -100);
      expect(couleurDe(tester, 'pour le 20/11'), isNot(couleurAlerte(tester)));
    });

    testWidgets('toucher le titre ne coche pas la tâche', (tester) async {
      await afficherEcran(tester);

      await tester.tap(find.text('Relire le CM 01'));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('5 à faire'), findsOneWidget);
      expect(tester.widget<Checkbox>(caseDe('Relire le CM 01')).value, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // C3 : mise en page, contraintes et cas limites
  // -------------------------------------------------------------------------
  group('C3 : mise en page, contraintes et cas limites', () {
    testWidgets(
      'le compteur et le filtre restent fixes, seule la liste défile',
      (tester) async {
        await afficherEcran(tester);
        await ajouter(tester, fois: 5); // assez de tâches pour devoir défiler

        final compteurAvant = tester.getTopLeft(find.text('10 à faire'));
        final filtreAvant = tester.getTopLeft(
          find.byType(SegmentedButton<Filtre>),
        );

        await tester.drag(find.byType(ListView), const Offset(0, -300));
        await tester.pump();

        final defilement = tester
            .state<ScrollableState>(
              find.descendant(
                of: find.byType(ListView),
                matching: find.byType(Scrollable),
              ),
            )
            .position
            .pixels;
        expect(defilement, greaterThan(0)); // la liste a bien défilé…
        expect(tester.getTopLeft(find.text('10 à faire')), compteurAvant);
        expect(
          tester.getTopLeft(find.byType(SegmentedButton<Filtre>)),
          filtreAvant,
        ); // … mais pas l'en-tête
      },
    );

    testWidgets('le message vide est centré et dépend du filtre', (
      tester,
    ) async {
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
      testWidgets('aucun débordement à ${largeur.toInt()} pixels de large', (
        tester,
      ) async {
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

    testWidgets('sur grand écran, le contenu ne dépasse pas 720 pixels', (
      tester,
    ) async {
      fixerLargeur(tester, 1280);
      await afficherEcran(tester);

      expect(tester.getSize(find.byType(ListView)).width, 720);
    });
  });

  // -------------------------------------------------------------------------
  // D1 : écran de détail
  // -------------------------------------------------------------------------
  group('D1 : écran de détail', () {
    testWidgets('toucher une tâche ouvre son détail', (tester) async {
      await afficherEcran(tester);

      await tester.tap(find.text('Relire le CM 01'));
      await tester.pumpAndSettle();

      expect(find.byType(EcranDetail), findsOneWidget);
      expect(find.text('records, patterns, classes scellées'), findsOneWidget);
    });

    testWidgets('le bouton retour ramène à la liste', (tester) async {
      await afficherEcran(tester);
      await tester.tap(find.text('Relire le CM 01'));
      await tester.pumpAndSettle();

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(EcranDetail), findsNothing);
      expect(find.text('5 à faire'), findsOneWidget);
    });

    testWidgets('avec un filtre actif, ouvre la bonne tâche', (tester) async {
      await afficherEcran(tester);
      await choisirFiltre(tester, 'À faire');

      // Deuxième tuile affichée : t3, et non t2 (deuxième de la liste complète).
      await tester.tap(find.byType(TuileTache).at(1));
      await tester.pumpAndSettle();

      expect(find.text('Faire les courses'), findsOneWidget);
      expect(find.text('pain, lait, café'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // D2 : agir depuis le détail
  // -------------------------------------------------------------------------
  group('D2 : agir depuis le détail', () {
    testWidgets('point de contrôle D : depuis « À faire », marquer faite la '
        'deuxième tâche affichée', (tester) async {
      await afficherEcran(tester);
      await choisirFiltre(tester, 'À faire');

      // Deuxième tâche affichée : t3 « Faire les courses ».
      await tester.tap(find.byType(TuileTache).at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Marquer comme faite'));
      await tester.pumpAndSettle();

      expect(find.byType(EcranDetail), findsNothing);
      expect(find.text('Faire les courses'), findsNothing);
      expect(find.text('4 à faire'), findsOneWidget);

      await choisirFiltre(tester, 'Faites');
      expect(find.text('Faire les courses'), findsOneWidget);
      expect(find.text('Relire le CM 01'), findsNothing); // pas la mauvaise
    });

    testWidgets('« Marquer à faire » depuis « Faites »', (tester) async {
      await afficherEcran(tester);
      await choisirFiltre(tester, 'Faites');

      await tester.tap(find.text('Installer Flutter'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Marquer à faire'));
      await tester.pumpAndSettle();

      expect(find.text('Aucune tâche faite'), findsOneWidget);
      expect(find.text('6 à faire'), findsOneWidget);
    });

    testWidgets('un simple retour ne change rien', (tester) async {
      await afficherEcran(tester);

      await tester.tap(find.text('Relire le CM 01'));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('5 à faire'), findsOneWidget);
      expect(tester.widget<Checkbox>(caseDe('Relire le CM 01')).value, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // E1 : formulaire de création
  // -------------------------------------------------------------------------
  group('E1 : formulaire de création', () {
    testWidgets('« Ajouter » ouvre le formulaire', (tester) async {
      await afficherEcran(tester);

      await tester.tap(find.text('Ajouter'));
      await tester.pumpAndSettle();

      expect(find.byType(EcranFormulaire), findsOneWidget);
    });

    testWidgets('une tâche créée avec une échéance apparaît avec son libellé', (
      tester,
    ) async {
      await afficherEcran(tester);

      await tester.tap(find.text('Ajouter'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Titre'),
        'Rendre le TP',
      );
      await tester.tap(find.text('sans échéance'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('25'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      expect(find.byType(EcranFormulaire), findsNothing);
      expect(find.text('6 à faire'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Rendre le TP'), 100);
      expect(find.text('pour le 25/11'), findsOneWidget);
    });

    testWidgets('revenir sans enregistrer n\'ajoute rien', (tester) async {
      await afficherEcran(tester);

      await tester.tap(find.text('Ajouter'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Titre'),
        'Abandonnée',
      );
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('5 à faire'), findsOneWidget);
      expect(find.text('1/6 faite'), findsOneWidget);
      expect(find.text('Abandonnée'), findsNothing);
    });

    testWidgets('deux tâches de même titre restent deux tâches distinctes', (
      tester,
    ) async {
      // Écran assez haut pour afficher les 8 tâches sans défiler.
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await afficherEcran(tester);

      await creer(tester, 'Doublon');
      await creer(tester, 'Doublon');
      expect(find.text('Doublon'), findsNWidgets(2));

      // Identifiants distincts : cocher l'une ne coche pas l'autre.
      await tester.tap(caseDe('Doublon').last);
      await tester.pump();
      expect(find.text('6 à faire'), findsOneWidget);
      final cases = tester.widgetList<Checkbox>(caseDe('Doublon')).toList();
      expect(cases.map((c) => c.value), [false, true]);
    });
  });

  // -------------------------------------------------------------------------
  // E2 : valider les saisies (point de contrôle E)
  // -------------------------------------------------------------------------
  group('E2 : valider les saisies', () {
    testWidgets('point de contrôle E : formulaire vide, titre de 61 '
        'caractères, puis tâche valide avec échéance', (tester) async {
      await afficherEcran(tester);
      await tester.tap(find.text('Ajouter'));
      await tester.pumpAndSettle();
      final titre = find.widgetWithText(TextFormField, 'Titre');

      // 1. Formulaire vide : un message, et rien ne se ferme.
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      expect(find.text('Le titre est obligatoire'), findsOneWidget);
      expect(find.byType(EcranFormulaire), findsOneWidget);

      // 2. Titre de 61 caractères : refusé.
      await tester.enterText(titre, 'a' * 61);
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      expect(find.text('Le titre fait 60 caractères au plus'), findsOneWidget);
      expect(find.byType(EcranFormulaire), findsOneWidget);

      // 3. Tâche valide avec échéance : elle apparaît avec son libellé.
      await tester.enterText(titre, 'Rendre le TP');
      await tester.tap(find.text('sans échéance'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('25'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      expect(find.byType(EcranFormulaire), findsNothing);
      expect(find.text('6 à faire'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Rendre le TP'), 100);
      expect(find.text('pour le 25/11'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // G1 : modifier une tâche depuis le détail
  // -------------------------------------------------------------------------
  group('G1 : modifier une tâche', () {
    testWidgets('« Modifier » remplace la tâche à sa place dans la liste', (
      tester,
    ) async {
      await afficherEcran(tester);
      final positionAvant = tester.getTopLeft(find.text('Relire le CM 01'));

      await tester.tap(find.text('Relire le CM 01'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Modifier'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Relire le CM 01'),
        'Relire le CM 02',
      );
      await tester.ensureVisible(find.text('Enregistrer'));
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      expect(find.byType(EcranFormulaire), findsNothing);
      expect(find.byType(EcranDetail), findsNothing);
      expect(find.text('Relire le CM 01'), findsNothing);
      // Même tâche (même identifiant) : même place, compteur inchangé.
      expect(tester.getTopLeft(find.text('Relire le CM 02')), positionAvant);
      expect(find.text('5 à faire'), findsOneWidget);
      expect(find.text('1/6 faite'), findsOneWidget);
    });

    testWidgets('abandonner la modification ne change rien', (tester) async {
      await afficherEcran(tester);

      await tester.tap(find.text('Relire le CM 01'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Modifier'));
      await tester.pumpAndSettle();
      await tester.pageBack(); // ferme le formulaire
      await tester.pumpAndSettle();

      expect(find.byType(EcranDetail), findsOneWidget);
      await tester.pageBack(); // ferme le détail
      await tester.pumpAndSettle();
      expect(find.text('Relire le CM 01'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // G2 : supprimer, avec annulation
  // -------------------------------------------------------------------------
  group('G2 : supprimer, avec annulation', () {
    /// Fait glisser vers la gauche la tuile qui affiche [titre].
    Future<void> glisser(WidgetTester tester, String titre) async {
      await tester.drag(find.text(titre), const Offset(-600, 0));
      await tester.pumpAndSettle();
    }

    /// Titres affichés, dans l'ordre de la liste.
    List<String> titres(WidgetTester tester) => [
      for (final tuile in tester.widgetList<TuileTache>(
        find.byType(TuileTache),
      ))
        tuile.tache.titre,
    ];

    testWidgets('glisser une tâche la supprime et met à jour le compteur', (
      tester,
    ) async {
      await afficherEcran(tester);

      await glisser(tester, 'Relire le CM 01');

      expect(find.text('Relire le CM 01'), findsNothing);
      expect(find.text('4 à faire'), findsOneWidget);
      expect(find.text('1/5 faite'), findsOneWidget);
      expect(find.text('« Relire le CM 01 » supprimée'), findsOneWidget);
    });

    testWidgets('« Annuler » remet la tâche à sa place', (tester) async {
      await afficherEcran(tester);
      final ordreAvant = titres(tester);

      await glisser(tester, 'Relire le CM 01');
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      expect(titres(tester), ordreAvant);
      expect(find.text('5 à faire'), findsOneWidget);
    });

    testWidgets('avec un filtre actif, l\'annulation rend sa place dans la '
        'liste complète', (tester) async {
      await afficherEcran(tester);
      final ordreAvant = titres(tester);

      await choisirFiltre(tester, 'À faire');
      await glisser(tester, 'Faire les courses');
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      await choisirFiltre(tester, 'Toutes');

      expect(titres(tester), ordreAvant);
    });

    testWidgets('supprimer la seule tâche faite affiche le message vide', (
      tester,
    ) async {
      await afficherEcran(tester);
      await choisirFiltre(tester, 'Faites');

      await glisser(tester, 'Installer Flutter');

      expect(find.text('Aucune tâche faite'), findsOneWidget);
      expect(find.text('5 à faire'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // G3 : trier et regrouper
  // -------------------------------------------------------------------------
  group('G3 : trier et regrouper', () {
    /// Choisit [libelle] dans le menu « Trier » de la barre d'application.
    Future<void> trierPar(WidgetTester tester, String libelle) async {
      await tester.tap(find.byTooltip('Trier'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(libelle).last);
      await tester.pumpAndSettle();
    }

    /// En-têtes et titres affichés, de haut en bas.
    List<String> lignes(WidgetTester tester) {
      final elements = <(double, String)>[
        for (final element in find.byType(EnteteGroupe).evaluate())
          (
            tester.getTopLeft(find.byWidget(element.widget)).dy,
            '# ${(element.widget as EnteteGroupe).libelle}',
          ),
        for (final element in find.byType(TuileTache).evaluate())
          (
            tester.getTopLeft(find.byWidget(element.widget)).dy,
            (element.widget as TuileTache).tache.titre,
          ),
      ]..sort((a, b) => a.$1.compareTo(b.$1));
      return [for (final (_, texte) in elements) texte];
    }

    /// Écran assez haut pour voir toutes les lignes sans défiler.
    void grandEcran(WidgetTester tester) {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }

    testWidgets('par défaut, l\'ordre d\'ajout sans en-têtes', (tester) async {
      grandEcran(tester);
      await afficherEcran(tester);

      expect(lignes(tester), [
        'Installer Flutter',
        'Relire le CM 01',
        'Faire les courses',
        'Appeler le dentiste',
        'Renouveler le passeport',
        'Rendre la convention de stage',
      ]);
    });

    testWidgets('tri par priorité', (tester) async {
      grandEcran(tester);
      await afficherEcran(tester);

      await trierPar(tester, 'Priorité');

      expect(lignes(tester), [
        'Installer Flutter', // haute
        'Renouveler le passeport', // haute
        'Appeler le dentiste', // normale
        'Relire le CM 01',
        'Rendre la convention de stage',
        'Faire les courses', // basse
      ]);
    });

    testWidgets('tri par titre', (tester) async {
      grandEcran(tester);
      await afficherEcran(tester);

      await trierPar(tester, 'Titre');

      expect(lignes(tester), [
        'Appeler le dentiste',
        'Faire les courses',
        'Installer Flutter',
        'Relire le CM 01',
        'Rendre la convention de stage',
        'Renouveler le passeport',
      ]);
    });

    testWidgets('tri par échéance : regroupé sous des en-têtes', (
      tester,
    ) async {
      grandEcran(tester);
      await afficherEcran(tester);

      await trierPar(tester, 'Échéance');

      expect(lignes(tester), [
        '# En retard',
        'Rendre la convention de stage', // 2/11, le 18/11
        '# Datées',
        'Appeler le dentiste', // 20/11
        'Renouveler le passeport', // 15/1
        '# Sans échéance',
        'Faire les courses',
        'Installer Flutter',
        'Relire le CM 01',
      ]);
      expect(find.text('En retard (1)'), findsOneWidget);
      expect(find.text('Sans échéance (3)'), findsOneWidget);
    });

    testWidgets('le tri se combine au filtre et ne change pas le compteur', (
      tester,
    ) async {
      grandEcran(tester);
      await afficherEcran(tester);

      await trierPar(tester, 'Échéance');
      await choisirFiltre(tester, 'Faites');

      expect(lignes(tester), ['# Sans échéance', 'Installer Flutter']);
      expect(find.text('5 à faire'), findsOneWidget);
    });

    testWidgets('cocher une tâche la fait changer de groupe', (tester) async {
      grandEcran(tester);
      await afficherEcran(tester);
      await trierPar(tester, 'Échéance');

      await tester.tap(caseDe('Rendre la convention de stage'));
      await tester.pump();

      // Faite, elle n'est plus en retard : groupe « Datées », par date.
      expect(lignes(tester).take(4), [
        '# Datées',
        'Rendre la convention de stage',
        'Appeler le dentiste',
        'Renouveler le passeport',
      ]);
      expect(find.text('En retard (1)'), findsNothing);
    });
  });
}
