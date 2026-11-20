import 'package:material_ui/material_ui.dart';

/// En-tête de l'écran de liste : nombre de tâches à faire et progression.
class CompteurTaches extends StatelessWidget {
  const CompteurTaches({super.key, required this.faites, required this.total});

  final int faites;
  final int total;

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;
    final textes = Theme.of(context).textTheme;
    final restantes = total - faites;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      color: couleurs.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              // Côte à côte quand la place suffit ; sinon, le second texte
              // passe à la ligne au lieu de déborder.
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 8,
              runSpacing: 2,
              children: [
                Text(
                  '$restantes à faire',
                  style: textes.titleLarge?.copyWith(
                    color: couleurs.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$faites/$total ${faites > 1 ? 'faites' : 'faite'}',
                  style: textes.bodySmall?.copyWith(
                    color: couleurs.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                // Pas de division par zéro si la liste est vide.
                value: total == 0 ? 0 : faites / total,
                minHeight: 6,
                color: couleurs.primary,
                backgroundColor: couleurs.surface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}