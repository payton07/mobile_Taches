import 'package:material_ui/material_ui.dart';

import '../modele/taches.dart';

/// Menu de la barre d'application qui choisit l'ordre de la liste (G3).
/// Ne possède aucun état : il affiche [tri] coché et signale le nouveau
/// choix à l'écran par [surChangement].
class MenuTri extends StatelessWidget {
  const MenuTri({super.key, required this.tri, required this.surChangement});

  final Tri tri;
  final ValueChanged<Tri> surChangement;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Tri>(
      icon: const Icon(Icons.sort),
      tooltip: 'Trier',
      initialValue: tri,
      onSelected: surChangement,
      itemBuilder: (context) => [
        for (final choix in Tri.values)
          CheckedPopupMenuItem(
            value: choix,
            checked: choix == tri,
            child: Text(choix.libelle),
          ),
      ],
    );
  }
}
