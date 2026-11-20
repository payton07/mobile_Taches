import 'package:material_ui/material_ui.dart';

import '../composants/composants.dart';
import '../modele/taches.dart';
import 'ecran_formulaire.dart';

/// Écran de détail (petits écrans) : affiche [ContenuDetail] en plein écran.
/// Ne possède aucun état : la tâche et la date du jour descendent par le
/// constructeur ; une action remonte par la valeur de retour (Navigator.pop),
/// un simple retour ne renvoie rien (null).
class EcranDetail extends StatelessWidget {
  const EcranDetail({super.key, required this.tache, required this.aujourdhui});

  final Tache tache;

  /// Date du jour, fournie par la liste : le détail ne lit jamais l'horloge.
  final DateTime aujourdhui;

  /// Ouvre le formulaire pré-rempli ; la tâche enregistrée ferme le détail
  /// et remonte à la liste par le même chemin que « Marquer comme faite ».
  Future<void> _modifier(BuildContext context) async {
    final modifiee = await Navigator.of(context).push<Tache>(
      MaterialPageRoute(
        builder: (_) =>
            EcranFormulaire.modification(tache: tache, aujourdhui: aujourdhui),
      ),
    );
    if (modifiee == null || !context.mounted) return;
    Navigator.of(context).pop(modifiee);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détail de la tâche')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ContenuDetail(
            tache: tache,
            aujourdhui: aujourdhui,
            // Ferme le détail en renvoyant à la liste la tâche modifiée.
            // Le bouton de retour, lui, ferme sans résultat (null).
            surChangement: (modifiee) => Navigator.of(context).pop(modifiee),
            surModification: () => _modifier(context),
          ),
        ),
      ),
    );
  }
}
