import 'package:material_ui/material_ui.dart';

import '../composants/composants.dart';
import '../modele/taches.dart';

/// Écran de détail : affiche tout le contenu d'une tâche.
/// Ne possède aucun état : la tâche et la date du jour descendent par le
/// constructeur. Le bouton de retour de l'AppBar ramène à la liste.
class EcranDetail extends StatelessWidget {
  const EcranDetail({super.key, required this.tache, required this.aujourdhui});

  final Tache tache;

  /// Date du jour, fournie par la liste : le détail ne lit jamais l'horloge.
  final DateTime aujourdhui;

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;
    final textes = Theme.of(context).textTheme;
    final enRetard = estEnRetard(tache, aujourdhui: aujourdhui);
    final echeance = libelleEcheance(tache.echeance);

    return Scaffold(
      appBar: AppBar(title: const Text('Détail de la tâche')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          // ListView : le contenu défile si le titre ou la note sont longs.
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Titre complet : pas de maxLines, il s'affiche en entier.
              Text(
                tache.titre,
                style: textes.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  decoration: tache.faite ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 16),
              _Champ(
                icone: Icons.flag_outlined,
                libelle: 'Priorité',
                valeur: Align(
                  alignment: Alignment.centerLeft,
                  child: BadgePriorite(priorite: tache.priorite),
                ),
              ),
              _Champ(
                icone: Icons.event_outlined,
                libelle: 'Échéance',
                valeur: Text(
                  enRetard ? '$echeance · en retard' : echeance,
                  style: enRetard
                      ? TextStyle(
                    color: couleurs.error,
                    fontWeight: FontWeight.w600,
                  )
                      : null,
                ),
              ),
              _Champ(
                icone: Icons.notes_outlined,
                libelle: 'Note',
                valeur: switch (tache.note) {
                  null => Text(
                    'aucune note',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: couleurs.onSurfaceVariant,
                    ),
                  ),
                  final note => Text(note),
                },
              ),
              _Champ(
                icone: tache.faite
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                libelle: 'État',
                valeur: Text(tache.faite ? 'Faite' : 'À faire'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Une ligne du détail : une icône, un libellé discret et la valeur.
class _Champ extends StatelessWidget {
  const _Champ({
    required this.icone,
    required this.libelle,
    required this.valeur,
  });

  final IconData icone;
  final String libelle;
  final Widget valeur;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icone),
      title: Text(
        libelle,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: valeur,
      ),
    );
  }
}