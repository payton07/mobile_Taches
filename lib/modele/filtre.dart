import 'tache.dart';

/// Filtre d'affichage de la liste des tâches.
enum Filtre {
  toutes('Toutes', 'Aucune tâche'),
  aFaire('À faire', 'Aucune tâche à faire'),
  faites('Faites', 'Aucune tâche faite');

  const Filtre(this.libelle, this.messageVide);

  /// Libellé affichable dans le sélecteur.
  final String libelle;

  /// Message affiché quand ce filtre ne retient aucune tâche.
  final String messageVide;

  /// Vrai si [tache] doit être affichée avec ce filtre.
  /// Se contente de lire la tâche : filtrer ne la modifie jamais.
  bool accepte(Tache tache) => switch (this) {
    Filtre.toutes => true,
    Filtre.aFaire => !tache.faite,
    Filtre.faites => tache.faite,
  };
}