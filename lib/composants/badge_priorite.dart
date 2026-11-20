import 'package:material_ui/material_ui.dart';

import '../modele/taches.dart';

/// Indicateur de priorité : pastille colorée affichant le libellé.
/// Partagé par la tuile de la liste et l'écran de détail.
class BadgePriorite extends StatelessWidget {
  const BadgePriorite({super.key, required this.priorite});

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