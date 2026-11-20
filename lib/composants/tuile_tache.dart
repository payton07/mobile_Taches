import 'package:material_ui/material_ui.dart';

import '../modele/taches.dart';

/// Tuile réutilisable affichant une tâche : case à cocher, titre (barré si
/// faite), libellé de l'échéance (en couleur d'alerte si en retard) et
/// indicateur de priorité.
///
/// Ne possède aucun état et n'appelle jamais setState : l'information descend
/// par le constructeur, les événements remontent par [surBascule] et
/// [surOuverture].
class TuileTache extends StatelessWidget {
  const TuileTache({
    super.key,
    required this.tache,
    required this.aujourdhui,
    required this.surBascule,
    required this.surOuverture,
  });

  final Tache tache;

  /// Date du jour, fournie par l'écran : la tuile ne lit jamais l'horloge.
  final DateTime aujourdhui;

  /// Appelée quand l'utilisateur coche ou décoche la tâche.
  final VoidCallback surBascule;

  /// Appelée quand l'utilisateur touche la tuile pour ouvrir la tâche.
  final VoidCallback surOuverture;

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;
    final textes = Theme.of(context).textTheme;
    final enRetard = estEnRetard(tache, aujourdhui: aujourdhui);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: surOuverture,
        leading: Checkbox(
          value: tache.faite,
          onChanged: (_) => surBascule(),
        ),
        title: Text(
          tache.titre,
          style: tache.faite
              ? textes.bodyLarge?.copyWith(
            decoration: TextDecoration.lineThrough,
            color: couleurs.onSurfaceVariant,
          )
              : null,
        ),
        subtitle: Text(
          libelleEcheance(tache.echeance),
          style: textes.bodyMedium?.copyWith(
            color: enRetard ? couleurs.error : couleurs.onSurfaceVariant,
            fontWeight: enRetard ? FontWeight.w600 : null,
          ),
        ),
        trailing: _BadgePriorite(priorite: tache.priorite),
      ),
    );
  }
}

/// Indicateur de priorité : pastille colorée affichant le libellé.
/// Privée : elle ne sert qu'à TuileTache, dans ce fichier.
class _BadgePriorite extends StatelessWidget {
  const _BadgePriorite({required this.priorite});

  final Priorite priorite;

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;

    // Pas de cas par défaut : un nouveau niveau de priorité
    // provoquerait une erreur de compilation ici.
    final (fond, texte) = switch (priorite) {
      Priorite.haute => (couleurs.errorContainer, couleurs.onErrorContainer),
      Priorite.normale =>
      (couleurs.secondaryContainer, couleurs.onSecondaryContainer),
      Priorite.basse =>
      (couleurs.surfaceContainerHighest, couleurs.onSurfaceVariant),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fond,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        priorite.libelle,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: texte),
      ),
    );
  }
}