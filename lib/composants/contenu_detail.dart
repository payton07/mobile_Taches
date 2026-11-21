import 'package:material_ui/material_ui.dart';

import '../modele/taches.dart';
import 'badge_priorite.dart';

/// Contenu du détail d'une tâche : titre complet, priorité, échéance (et
/// retard éventuel), note, état, et les deux actions « Marquer comme faite »
/// et « Modifier ».
///
/// Partagé par l'écran de détail (petits écrans) et le panneau de droite de
/// la liste (au-delà de 840 pixels, bonus G4). Ne possède aucun état : les
/// actions remontent par [surChangement] et [surModification], et c'est
/// l'endroit où il est affiché qui décide de leur effet.
class ContenuDetail extends StatelessWidget {
  const ContenuDetail({
    super.key,
    required this.tache,
    required this.aujourdhui,
    required this.surChangement,
    required this.surModification,
  });

  final Tache tache;

  /// Date du jour, fournie par la liste : le détail ne lit jamais l'horloge.
  final DateTime aujourdhui;

  /// Appelée avec la tâche à l'état inversé (« Marquer comme faite »).
  final ValueChanged<Tache> surChangement;

  /// Appelée quand l'utilisateur demande à modifier la tâche.
  final VoidCallback surModification;

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;
    final textes = Theme.of(context).textTheme;
    final enRetard = estEnRetard(tache, aujourdhui: aujourdhui);
    final echeance = libelleEcheance(tache.echeance);

    // ListView : le contenu défile si le titre ou la note sont longs.
    return ListView(
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
                ? TextStyle(color: couleurs.error, fontWeight: FontWeight.w600)
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
        const SizedBox(height: 24),
        FilledButton.icon(
          // Ferme le détail en renvoyant à la liste la tâche modifiée.
          // Le bouton de retour, lui, ferme sans résultat (null).
          onPressed: () => surChangement(tache.copieAvec(faite: !tache.faite)),
          icon: Icon(tache.faite ? Icons.undo : Icons.check),
          label: Text(tache.faite ? 'Marquer à faire' : 'Marquer comme faite'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: surModification,
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Modifier'),
        ),
      ],
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
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      subtitle: Padding(padding: const EdgeInsets.only(top: 4), child: valeur),
    );
  }
}
