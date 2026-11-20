import 'tache.dart';

/// Filtre d'affichage de la liste des tâches.
enum Filtre {
  toutes('Toutes'),
  aFaire('À faire'),
  faites('Faites');

  const Filtre(this.libelle);

  /// Libellé affichable.
  final String libelle;

  /// Vrai si [tache] doit être affichée avec ce filtre.
  /// Se contente de lire la tâche : filtrer ne la modifie jamais.
  bool accepte(Tache tache) => switch (this) {
    Filtre.toutes => true,
    Filtre.aFaire => !tache.faite,
    Filtre.faites => tache.faite,
  };
}