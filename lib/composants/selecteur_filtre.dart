import 'package:material_ui/material_ui.dart';

import '../modele/taches.dart';

/// Sélecteur du filtre d'affichage : « Toutes », « À faire », « Faites ».
/// Ne possède aucun état : il affiche [filtre] et signale le nouveau choix
/// à l'écran par [surChangement].
class SelecteurFiltre extends StatelessWidget {
  const SelecteurFiltre({
    super.key,
    required this.filtre,
    required this.surChangement,
  });

  final Filtre filtre;
  final ValueChanged<Filtre> surChangement;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SizedBox(
        width: double.infinity,
        child: SegmentedButton<Filtre>(
          segments: [
            for (final choix in Filtre.values)
              ButtonSegment(value: choix, label: Text(choix.libelle)),
          ],
          selected: {filtre},
          showSelectedIcon: false,
          onSelectionChanged: (selection) => surChangement(selection.first),
        ),
      ),
    );
  }
}