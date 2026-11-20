import 'package:material_ui/material_ui.dart';

import '../modele/taches.dart';
import 'badge_priorite.dart';

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
    this.selectionnee = false,
  });

  final Tache tache;

  /// Date du jour, fournie par l'écran : la tuile ne lit jamais l'horloge.
  final DateTime aujourdhui;

  /// Appelée quand l'utilisateur coche ou décoche la tâche.
  final VoidCallback surBascule;

  /// Appelée quand l'utilisateur touche la tuile pour ouvrir la tâche.
  final VoidCallback surOuverture;

  /// Vrai si la tâche est celle affichée dans le panneau de détail (G4).
  final bool selectionnee;

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;
    final textes = Theme.of(context).textTheme;
    final enRetard = estEnRetard(tache, aujourdhui: aujourdhui);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: selectionnee ? couleurs.secondaryContainer : null,
      child: ListTile(
        onTap: surOuverture,
        selected: selectionnee,
        leading: Checkbox(value: tache.faite, onChanged: (_) => surBascule()),
        title: Text(
          tache.titre,
          // Une seule ligne, terminée par « … » si le titre est trop long.
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
        trailing: BadgePriorite(priorite: tache.priorite),
      ),
    );
  }
}
