# Mes tâches

Gestionnaire de tâches personnel écrit en Flutter, réalisé pour le TP 1 du module HAI912I (« Fondamentaux de Dart et Flutter »). L'application cible le Web (Chrome) et Android.

## Projet

« Mes tâches » affiche une liste de tâches. Chaque tâche a un titre, une priorité (basse, normale, haute), une échéance (aucune, une date, ou un jour de la semaine), une note facultative et un état (à faire ou faite). Au lancement, la liste part de quelques tâches d'exemple ; elle n'est pas enregistrée d'un lancement à l'autre.

Fonctionnalités :

- **Liste** : une tuile par tâche, avec case à cocher, badge de priorité et libellé d'échéance ; les tâches en retard sont signalées.
- **Filtre et compteur** : « Toutes », « À faire », « Faites », et en tête le nombre de tâches à faire avec la progression.
- **Détail** : un écran qui montre tous les champs d'une tâche et permet de la marquer comme faite ou à faire ; la liste est mise à jour au retour.
- **Création** : un formulaire validé (titre obligatoire de 60 caractères au plus, note de 200 caractères au plus, échéance non antérieure à aujourd'hui), avec un message sous chaque champ refusé.
- **Mise en page** : le contenu ne dépasse pas 720 pixels de large, et un titre long ne provoque aucun débordement sur un écran étroit.
- **Bonus** : modification, suppression avec annulation, tri et regroupement, mise en page adaptative (voir [Bonus](#bonus)).

Membres du binôme : leurs noms figurent sur la page de titre du compte-rendu. Le dépôt ne contient volontairement aucune information personnelle.

## Architecture

```
lib/
├── main.dart              point d'entrée : thème, écran d'accueil (la liste)
├── modele/                modèle en Dart pur, sans aucune dépendance à Flutter
│   ├── taches.dart        point d'entrée public imposé par le sujet (réexporte le modèle)
│   ├── tache.dart         Tache, immuable (copieAvec, sansNote, ==, hashCode)
│   ├── priorite.dart      enum Priorite
│   ├── echeance.dart      sealed class Echeance : SansEcheance, EcheanceDate, EcheanceHebdomadaire
│   ├── regles_echeance.dart  libelleEcheance, estEnRetard
│   ├── lecture_json.dart  lecture des tâches au format JSON (tacheDepuisJson, tachesDepuisTexteJson)
│   ├── liste_taches.dart  aFaire : tâches à faire, de la plus urgente à la moins urgente
│   ├── filtre.dart        enum Filtre (Toutes, À faire, Faites)
│   ├── validation.dart    règles du formulaire (titre, note, échéance)
│   ├── tri.dart           tri et regroupement par échéance (bonus G3)
│   └── jour.dart          comparaison de jours, interne au modèle
├── ecrans/
│   ├── ecran_liste.dart   écran principal ; il possède l'état (tâches, filtre, tri, sélection)
│   ├── ecran_detail.dart  détail d'une tâche en plein écran
│   └── ecran_formulaire.dart  création et modification d'une tâche
├── composants/            widgets réutilisables, sans état propre
│   ├── tuile_tache.dart, badge_priorite.dart, compteur_taches.dart
│   ├── selecteur_filtre.dart, menu_tri.dart, entete_groupe.dart
│   └── contenu_detail.dart  contenu du détail, partagé par l'écran et le panneau latéral
└── donnees/exemples.dart  tâches d'exemple au format JSON

test/
├── modele/                tests unitaires du modèle (package:test)
├── composants/            tests de widgets des composants
├── ecrans/                tests de widgets des écrans (navigation, formulaire, bonus)
└── widget_test.dart       test fourni avec le projet de démarrage
```

Le modèle ne dépend jamais de Flutter : il se teste seul, et les écrans ne font que l'afficher.
L'état vit dans `EcranListe` ; le détail et le formulaire renvoient leur résultat par `Navigator.pop`, et la liste le reporte dans son état.

## Environnement

| Élément                 | Version utilisée                                     |
| ----------------------- | ---------------------------------------------------- |
| Système d'exploitation  | macOS 27.2                                           |
| Flutter                 | 3.50.1, canal stable (3.47 au minimum)               |
| Dart                    | 3.14.0                                               |
| IDE                     | Android Studio 2025.3, greffons Flutter et Dart      |
| SDK Android             | plate-forme de niveau d'API 36, Build-Tools 36.1.0   |
| Navigateur              | Google Chrome                                        |

Dépendances (voir `pubspec.yaml`, versions figées dans `pubspec.lock`) :

| Paquet          | Version | Rôle                                         |
| --------------- | ------- | -------------------------------------------- |
| `material_ui`   | 1.11.1  | widgets Material                             |
| `flutter_test`  | SDK     | tests de widgets (développement)             |
| `test`          | 1.32.0  | tests unitaires du modèle (développement)    |
| `flutter_lints` | 6.0.0   | règles de l'analyseur (développement)        |

## Plateformes

- **Web (obligatoire)** : Google Chrome, avec `flutter run -d chrome`.
- **Android** : émulateur Pixel 10 Pro (Android 17, API 37) créé depuis le Device Manager d'Android Studio, avec
  `flutter run -d <id>`. `flutter build apk --debug` réussit.

Le code est le même pour les deux cibles : il n'utilise aucune bibliothèque propre au Web ni à Android.

## Installation

Depuis une copie propre des sources (sans `build/` ni `.dart_tool/`), placée dans un chemin
**court, sans espaces ni accents** :

```
flutter --version                         # 3.47 ou plus
flutter doctor                            # coche pour Flutter, Chrome et, si besoin, Android
flutter create --platforms=web,android .  # recrée web/ et android/ ; ne touche ni lib/ ni test/
flutter pub get                           # installe les dépendances de pubspec.lock
```

## Exécution et tests

Lancer l'application :

```
flutter run -d chrome                     # Web
flutter emulators                         # liste les émulateurs Android
flutter emulators --launch <id>           # en démarre un
flutter devices                           # repère l'identifiant de l'appareil
flutter run -d <id>                       # Android
```

Dans Android Studio : ouvrir le dossier par **File → Open**, choisir l'appareil dans la barre d'outils (« Chrome (web) » ou l'émulateur), puis **Run**.

Vérifier le projet :

```
flutter test                              # 180 tests, tous au vert
flutter analyze                           # aucun problème
dart format lib test                      # mise en forme officielle (aucun changement attendu)
flutter build web                         # doit réussir
flutter build apk --debug                 # si la chaîne Android est installée
```

Les tests unitaires (`test/modele/`) couvrent les règles du modèle : lecture JSON, échéances, retard, filtre, validation, tri. Les tests de widgets (`test/composants/`, `test/ecrans/`) couvrent les parcours de l'interface : cocher une tâche depuis la liste et depuis le détail, filtrer, créer une tâche refusée puis acceptée, titre long sur écran étroit, et chaque bonus.

## Limites

- **Pas de persistance** : les tâches reviennent aux exemples à chaque lancement.
- **Tri par titre** : il ignore les majuscules mais pas les accents ; un titre commençant par « É » est rangé après « Z ».
- **Suppression** : seulement en faisant glisser la tuile vers la gauche ; il n'y a pas de bouton de suppression dans le détail.
- **Langue** : l'interface est uniquement en français.

## Bonus

| Bonus | Où le voir                                                                 | Code principal                            | Tests                        |
| ----- | -------------------------------------------------------------------------- | ----------------------------------------- | ---------------------------- |
| G1    | détail d'une tâche → « Modifier » : même formulaire, pré-rempli            | `ecrans/ecran_formulaire.dart`            | `ecran_formulaire_test.dart`, `ecran_liste_test.dart` |
| G2    | glisser une tuile vers la gauche, puis « Annuler » dans le bandeau          | `ecrans/ecran_liste.dart`                 | `ecran_liste_test.dart`      |
| G3    | menu « Trier » de la barre d'application ; « Échéance » regroupe la liste   | `modele/tri.dart`, `composants/menu_tri.dart` | `tri_test.dart`, `ecran_liste_test.dart` |
| G4    | fenêtre de plus de 840 pixels : liste à gauche, détail à droite            | `ecrans/ecran_liste.dart`, `composants/contenu_detail.dart` | `ecran_liste_test.dart` |

## Dépannage

| Symptôme                                                    | Solution                                                                                         |
| ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| `flutter` : commande introuvable                            | ajouter le dossier `flutter/bin` du SDK au `PATH`, puis rouvrir les terminaux et l'IDE           |
| Chrome n'apparaît pas dans `flutter devices`                | installer Chrome ; sinon indiquer son chemin dans la variable `CHROME_EXECUTABLE`                |
| `flutter doctor` signale des licences Android non acceptées | `flutter doctor --android-licenses`, puis accepter chaque licence                                |
| Aucun appareil Android                                      | créer un émulateur dans le Device Manager d'Android Studio, puis `flutter emulators --launch <id>` |
| Erreurs de compilation étranges, chemin non trouvé          | placer le projet dans un chemin court, sans espaces ni accents                                   |
| Dépendances incohérentes après un changement de SDK         | `flutter clean`, puis `flutter pub get`                                                          |
| `.metadata` ou `pubspec.lock` modifiés par `flutter create` | sans conséquence : c'est la trace de la version du SDK utilisée pour recréer les plateformes     |

Avertissements de `flutter doctor` sur Xcode ou Visual Studio : sans importance, ces cibles ne sont pas utilisées.

## Liens

- Dépôt Git : https://github.com/payton07/mobile_Taches
- Vidéo de démonstration : [`video/demonstration.mp4`](video/demonstration.mp4), dans ce dépôt
