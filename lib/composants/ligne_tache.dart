import 'package:material_ui/material_ui.dart';

import '../modele/taches.dart';

/// Affichage d'une tâche : une case à cocher, son titre et sa priorité.
/// Ne possède aucun état : un appui est signalé à l'écran par [surBascule],
/// et c'est l'écran qui remplace la tâche dans son état.
class LigneTache extends StatelessWidget {
  const LigneTache({super.key, required this.tache, required this.surBascule});

  final Tache tache;

  /// Appelée quand l'utilisateur demande à marquer la tâche faite ou à faire.
  final VoidCallback surBascule;

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;
    final textes = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: surBascule,
        leading: Checkbox(value: tache.faite, onChanged: (_) => surBascule()),
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
/// Privée : elle ne sert qu'à LigneTache, dans ce fichier.
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
      Priorite.normale => (
        couleurs.secondaryContainer,
        couleurs.onSecondaryContainer,
      ),
      Priorite.basse => (
        couleurs.surfaceContainerHighest,
        couleurs.onSurfaceVariant,
      ),
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
