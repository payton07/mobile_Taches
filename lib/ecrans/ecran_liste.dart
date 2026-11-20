import 'package:material_ui/material_ui.dart';

import '../composants/composants.dart';
import '../donnees/exemples.dart';
import '../modele/taches.dart';

/// Écran de liste : affiche les tâches, permet d'en ajouter, de les cocher
/// et de filtrer l'affichage.
class EcranListe extends StatefulWidget {
  const EcranListe({super.key, this.maintenant = DateTime.now});

  /// Horloge utilisée pour savoir quel jour on est. Par défaut, l'horloge
  /// réelle ; les tests passent une horloge figée pour un résultat stable.
  final DateTime Function() maintenant;

  @override
  State<EcranListe> createState() => _EcranListeState();
}

class _EcranListeState extends State<EcranListe> {
  /// Au-delà, le contenu reste centré au lieu de s'étirer (grands écrans).
  static const _largeurMax = 720.0;



  /// Toutes les tâches, quel que soit le filtre.
  List<Tache> _taches = tachesDepuisTexteJson(tachesExempleJson);

  /// Filtre d'affichage choisi.
  Filtre _filtre = Filtre.toutes;

  /// Numéro de la prochaine tâche ajoutée, pour un identifiant unique.
  int _numeroAjout = 1;



  void _ajouter() {
    setState(() {
      final nouvelle = Tache(
        id: 'ajout-$_numeroAjout',
        titre: 'Nouvelle tâche $_numeroAjout',
      );
      _numeroAjout++;
      _taches = [..._taches, nouvelle];
    });
  }

  /// Remplace la tâche [id] par une copie dont l'état est inversé.
  void _basculer(String id) {
    setState(() {
      _taches = [
        for (final tache in _taches)
          if (tache.id == id) tache.copieAvec(faite: !tache.faite) else tache,
      ];
    });
  }

  void _changerFiltre(Filtre filtre) {
    setState(() => _filtre = filtre);
  }

  /// Ouvrira l'écran de détail de la tâche [id] (partie D).
  void _ouvrir(String id) {}



  @override
  Widget build(BuildContext context) {
    // Lue une seule fois : toutes les tuiles jugent le retard au même instant.
    final aujourdhui = widget.maintenant();
    final (:faites, :total) = bilan(_taches);
    final visibles = [
      for (final tache in _taches)
        if (_filtre.accepte(tache)) tache,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Mes tâches')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _largeurMax),
          // En-tête fixe (compteur, filtre) puis liste qui défile :
          // Expanded donne à la ListView une hauteur bornée, l'espace restant.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CompteurTaches(faites: faites, total: total),
              SelecteurFiltre(filtre: _filtre, surChangement: _changerFiltre),
              Expanded(
                child: visibles.isEmpty
                    ? _MessageVide(texte: _filtre.messageVide)
                    : ListView.builder(
                  // Laisse la place du bouton flottant sous la dernière tâche.
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: visibles.length,
                  itemBuilder: (context, index) {
                    final tache = visibles[index];
                    return TuileTache(
                      key: ValueKey(tache.id),
                      tache: tache,
                      aujourdhui: aujourdhui,
                      surBascule: () => _basculer(tache.id),
                      surOuverture: () => _ouvrir(tache.id),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ajouter,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }
}

/// Message centré qui remplace la liste quand le filtre ne retient rien.
class _MessageVide extends StatelessWidget {
  const _MessageVide({required this.texte});

  final String texte;

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: couleurs.outline),
            const SizedBox(height: 12),
            Text(
              texte,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: couleurs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}