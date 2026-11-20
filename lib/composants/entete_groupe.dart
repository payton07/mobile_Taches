import 'package:material_ui/material_ui.dart';

/// En-tête d'un groupe de tâches (« En retard », « Datées »…), suivi du
/// nombre de tâches du groupe.
class EnteteGroupe extends StatelessWidget {
  const EnteteGroupe({super.key, required this.libelle, required this.nombre});

  final String libelle;
  final int nombre;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(
        '$libelle ($nombre)',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
