import 'package:material_ui/material_ui.dart';

import '../composants/composants.dart';
import '../donnees/exemples.dart';
import '../modele/taches.dart';
import 'ecran_detail.dart';
import 'ecran_formulaire.dart';

/// Écran de liste : affiche les tâches, permet d'en ajouter, de les cocher,
/// de les supprimer (avec annulation) et de filtrer l'affichage.
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

  /// Au-delà de cette largeur, la liste et le détail s'affichent côte à
  /// côte (bonus G4) ; en dessous, le détail s'ouvre par navigation (D1).
  static const _largeurCoteACote = 840.0;

  /// Largeur de la colonne de liste en mode côte à côte.
  static const _largeurColonneListe = 400.0;

  /// Toutes les tâches, quel que soit le filtre.
  List<Tache> _taches = tachesDepuisTexteJson(tachesExempleJson);

  /// Filtre d'affichage choisi.
  Filtre _filtre = Filtre.toutes;

  /// Ordre d'affichage choisi (G3) ; par défaut, l'ordre d'ajout.
  Tri _tri = Tri.ajout;

  /// Identifiant de la tâche affichée dans le panneau de détail (G4), ou
  /// null. On garde l'identifiant et non la tâche : le panneau relit la
  /// tâche dans _taches, et reste ainsi à jour après chaque remplacement.
  String? _idSelectionne;

  /// Numéro du prochain identifiant « ajout-n » à essayer.
  int _numeroAjout = 1;

  /// Identifiant libre pour une nouvelle tâche : « ajout-n », n ne faisant
  /// qu'augmenter, et toute valeur déjà portée par une tâche est sautée.
  String _nouvelIdentifiant() {
    final existants = {for (final tache in _taches) tache.id};
    String identifiant;
    do {
      identifiant = 'ajout-${_numeroAjout++}';
    } while (existants.contains(identifiant));
    return identifiant;
  }

  /// Ouvre le formulaire et ajoute la tâche qu'il renvoie, s'il en renvoie
  /// une. Un simple retour renvoie null : rien n'est ajouté.
  Future<void> _ajouter() async {
    final nouvelle = await Navigator.of(context).push<Tache>(
      MaterialPageRoute(
        builder: (_) => EcranFormulaire(
          identifiant: _nouvelIdentifiant(),
          aujourdhui: widget.maintenant(),
        ),
      ),
    );
    if (nouvelle == null || !mounted) return;
    setState(() => _taches = [..._taches, nouvelle]);
  }

  void _changerTri(Tri tri) {
    setState(() => _tri = tri);
  }

  void _changerFiltre(Filtre filtre) {
    setState(() => _filtre = filtre);
  }

  /// Remplace, dans l'état, la tâche de même identifiant que [modifiee].
  /// Seul point de l'écran qui remplace une tâche.
  void _remplacer(Tache modifiee) {
    setState(() {
      _taches = [
        for (final tache in _taches)
          if (tache.id == modifiee.id) modifiee else tache,
      ];
    });
  }

  /// Retire [tache] de la liste et propose d'annuler la suppression.
  ///
  /// La position retenue est celle de la tâche dans la liste complète, et
  /// non dans la liste affichée : avec un filtre actif, les deux diffèrent.
  void _supprimer(Tache tache) {
    final position = _taches.indexWhere((t) => t.id == tache.id);
    setState(() {
      _taches = [
        for (final t in _taches)
          if (t.id != tache.id) t,
      ];
    });
    ScaffoldMessenger.of(context)
      // Une seule annulation proposée à la fois : la dernière suppression.
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('« ${tache.titre} » supprimée'),
          action: SnackBarAction(
            label: 'Annuler',
            onPressed: () => _restaurer(tache, position),
          ),
        ),
      );
  }

  /// Remet [tache] à sa [position] d'origine dans la liste complète.
  void _restaurer(Tache tache, int position) {
    if (!mounted) return;
    setState(() {
      // clamp : la liste a pu raccourcir entre-temps.
      _taches = [..._taches]..insert(position.clamp(0, _taches.length), tache);
    });
  }

  /// Inverse l'état de [tache] (case à cocher de la liste).
  void _basculer(Tache tache) {
    _remplacer(tache.copieAvec(faite: !tache.faite));
  }

  /// Mode côte à côte : affiche [tache] dans le panneau de détail.
  void _selectionner(Tache tache) {
    setState(() => _idSelectionne = tache.id);
  }

  /// Mode côte à côte : ouvre le formulaire de modification de [tache] et
  /// remplace la tâche par celle qu'il renvoie, s'il en renvoie une.
  Future<void> _modifier(Tache tache) async {
    final modifiee = await Navigator.of(context).push<Tache>(
      MaterialPageRoute(
        builder: (_) => EcranFormulaire.modification(
          tache: tache,
          aujourdhui: widget.maintenant(),
        ),
      ),
    );
    if (modifiee == null || !mounted) return;
    _remplacer(modifiee);
  }

  /// Ouvre le détail de [tache] et applique la tâche qu'il renvoie, s'il en
  /// renvoie une. Un simple retour renvoie null : rien ne change.
  Future<void> _ouvrir(Tache tache) async {
    final modifiee = await Navigator.of(context).push<Tache>(
      MaterialPageRoute(
        builder: (_) =>
            EcranDetail(tache: tache, aujourdhui: widget.maintenant()),
      ),
    );
    // Après un await, l'écran a pu être retiré : plus de setState possible.
    if (modifiee == null || !mounted) return;
    _remplacer(modifiee);
  }

  /// Panneau de droite du mode côte à côte : le détail de la tâche
  /// sélectionnée, ou une invitation à en choisir une. Une tâche supprimée
  /// n'est plus trouvée : le panneau revient à l'invitation.
  Widget _panneauDetail(DateTime aujourdhui) {
    final selection = _taches.where((t) => t.id == _idSelectionne).firstOrNull;
    if (selection == null) {
      return const _MessageVide(
        texte: 'Sélectionnez une tâche pour afficher son détail',
        icone: Icons.touch_app_outlined,
      );
    }
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _largeurMax),
        child: ContenuDetail(
          // Clé par tâche : changer de sélection repart d'un défilement neuf.
          key: ValueKey(selection.id),
          tache: selection,
          aujourdhui: aujourdhui,
          surChangement: _remplacer,
          surModification: () => _modifier(selection),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lue une seule fois : toutes les tuiles jugent le retard au même instant.
    final aujourdhui = widget.maintenant();
    final (:faites, :total) = bilan(_taches);
    final visibles = [
      for (final tache in _taches)
        if (_filtre.accepte(tache)) tache,
    ];
    // Lignes à afficher : triées, et regroupées sous des en-têtes quand on
    // trie par échéance. Le tri ne touche qu'à l'affichage, jamais à l'état.
    final elements = <_Element>[
      if (_tri == Tri.echeance)
        for (final (:groupe, :taches) in grouperParEcheance(
          visibles,
          aujourdhui: aujourdhui,
        )) ...[
          _Entete(groupe.libelle, taches.length),
          for (final tache in taches) _Ligne(tache),
        ]
      else
        for (final tache in trier(visibles, _tri)) _Ligne(tache),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes tâches'),
        actions: [MenuTri(tri: _tri, surChangement: _changerTri)],
      ),
      body: LayoutBuilder(
        builder: (context, contraintes) {
          final coteACote = contraintes.maxWidth > _largeurCoteACote;
          // En-tête fixe (compteur, filtre) puis liste qui défile :
          // Expanded donne à la ListView une hauteur bornée, l'espace restant.
          final colonneListe = Column(
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
                        itemCount: elements.length,
                        itemBuilder: (context, index) =>
                            switch (elements[index]) {
                              _Entete(:final libelle, :final nombre) =>
                                EnteteGroupe(libelle: libelle, nombre: nombre),
                              // Glisser vers la gauche supprime la tâche.
                              _Ligne(:final tache) => Dismissible(
                                key: ValueKey(tache.id),
                                direction: DismissDirection.endToStart,
                                background: const _FondSuppression(),
                                onDismissed: (_) => _supprimer(tache),
                                child: TuileTache(
                                  tache: tache,
                                  aujourdhui: aujourdhui,
                                  surBascule: () => _basculer(tache),
                                  surOuverture: () => coteACote
                                      ? _selectionner(tache)
                                      : _ouvrir(tache),
                                  selectionnee:
                                      coteACote && tache.id == _idSelectionne,
                                ),
                              ),
                            },
                      ),
              ),
            ],
          );
          if (!coteACote) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _largeurMax),
                child: colonneListe,
              ),
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(width: _largeurColonneListe, child: colonneListe),
              const VerticalDivider(width: 1),
              Expanded(child: _panneauDetail(aujourdhui)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ajouter,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }
}

/// Élément de la liste affichée : un en-tête de groupe ou une tâche.
sealed class _Element {
  const _Element();
}

final class _Entete extends _Element {
  const _Entete(this.libelle, this.nombre);

  final String libelle;
  final int nombre;
}

final class _Ligne extends _Element {
  const _Ligne(this.tache);

  final Tache tache;
}

/// Fond révélé sous une tuile qu'on fait glisser pour la supprimer.
class _FondSuppression extends StatelessWidget {
  const _FondSuppression();

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: couleurs.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.delete_outline, color: couleurs.onErrorContainer),
    );
  }
}

/// Message centré : remplace la liste quand le filtre ne retient rien, ou
/// le détail quand aucune tâche n'est sélectionnée.
class _MessageVide extends StatelessWidget {
  const _MessageVide({required this.texte, this.icone = Icons.inbox_outlined});

  final String texte;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 48, color: couleurs.outline),
            const SizedBox(height: 12),
            Text(
              texte,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(color: couleurs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
