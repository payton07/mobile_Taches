import 'package:material_ui/material_ui.dart';

import '../composants/composants.dart';
import '../modele/taches.dart';
import '../donnees/exemples.dart';

/// Écran de liste : affiche les tâches et permet d'en ajouter.
class EcranListe extends StatefulWidget {
  const EcranListe({super.key});

  @override
  State<EcranListe> createState() => _EcranListeState();
}

class _EcranListeState extends State<EcranListe> {
  /// L'état de l'écran : initialisé une seule fois, à la création du State.
  List<Tache> _taches = tachesDepuisTexteJson(tachesExempleJson);

  /// Numéro de la prochaine tâche ajoutée, pour un identifiant unique.
  int _numeroAjout = 1;

  void _ajouter() {
    setState(() {
      final nouvelle = Tache(
        id: 'ajout-$_numeroAjout',
        titre: 'Nouvelle tâche $_numeroAjout',
      );
      _numeroAjout++;
      // Nouvelle liste plutôt que add() : cohérent avec le modèle immuable.
      _taches = [..._taches, nouvelle];
    });
  }

  @override
  Widget build(BuildContext context) {
    final (:faites, :total) = bilan(_taches);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes tâches')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CompteurTaches(faites: faites, total: total),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 88),
              itemCount: _taches.length,
              itemBuilder: (context, index) {
                final tache = _taches[index];
                return LigneTache(key: ValueKey(tache.id), tache: tache);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ajouter,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }
}