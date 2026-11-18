import 'package:material_ui/material_ui.dart';

import '../modele/taches.dart';

/// Affichage d'une tâche : son état, son titre et sa priorité.
/// Ne possède aucun état : il affiche la tâche qu'on lui donne.
class LigneTache extends StatelessWidget {
  const LigneTache({super.key, required this.tache});

  final Tache tache;

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;
    final textes = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          tache.faite ? Icons.check_circle : Icons.radio_button_unchecked,
          color: tache.faite ? couleurs.primary : couleurs.outline,
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
        trailing: _BadgePriorite(priorite: tache.priorite),
      ),
    );
  }
}

/// Pastille colorée affichant le libellé de la priorité.
class _BadgePriorite extends StatelessWidget {
  const _BadgePriorite({required this.priorite});

  final Priorite priorite;

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;

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