import 'echeance.dart';
import 'regles_echeance.dart';
import 'tache.dart';

/// Ordre d'affichage de la liste (bonus G3).
enum Tri {
  ajout("Ordre d'ajout"),
  priorite('Priorité'),
  echeance('Échéance'),
  titre('Titre');

  const Tri(this.libelle);

  /// Libellé affichable dans le menu.
  final String libelle;
}

/// Groupes affichés, dans cet ordre, quand la liste est triée par échéance.
enum GroupeEcheance {
  enRetard('En retard'),
  datees('Datées'),
  hebdomadaires('Hebdomadaires'),
  sansEcheance('Sans échéance');

  const GroupeEcheance(this.libelle);

  /// Libellé affichable en en-tête de groupe.
  final String libelle;
}

/// Groupe de [tache] : « en retard » reprend exactement la règle de
/// [estEnRetard], si bien qu'une tâche faite à la date passée est « datée ».
GroupeEcheance groupeDe(Tache tache, {required DateTime aujourdhui}) =>
    switch (tache.echeance) {
      EcheanceDate() when estEnRetard(tache, aujourdhui: aujourdhui) =>
        GroupeEcheance.enRetard,
      EcheanceDate() => GroupeEcheance.datees,
      EcheanceHebdomadaire() => GroupeEcheance.hebdomadaires,
      SansEcheance() => GroupeEcheance.sansEcheance,
    };

/// Nouvelle liste des tâches dans l'ordre [tri] ; la collection reçue n'est
/// jamais modifiée. [Tri.ajout] conserve l'ordre reçu.
List<Tache> trier(Iterable<Tache> taches, Tri tri) {
  final resultat = taches.toList();
  switch (tri) {
    case Tri.ajout:
      break;
    case Tri.priorite:
      resultat.sort(comparerParUrgence);
    case Tri.echeance:
      resultat.sort(_parEcheance);
    case Tri.titre:
      resultat.sort(_parTitre);
  }
  return resultat;
}

/// Tâches réparties par [GroupeEcheance], dans l'ordre des groupes et, dans
/// chaque groupe, par échéance la plus proche puis par titre. Les groupes
/// vides sont omis.
List<({GroupeEcheance groupe, List<Tache> taches})> grouperParEcheance(
  Iterable<Tache> taches, {
  required DateTime aujourdhui,
}) {
  final parGroupe = {
    for (final groupe in GroupeEcheance.values) groupe: <Tache>[],
  };
  for (final tache in taches) {
    parGroupe[groupeDe(tache, aujourdhui: aujourdhui)]!.add(tache);
  }
  return [
    for (final MapEntry(key: groupe, value: liste) in parGroupe.entries)
      if (liste.isNotEmpty) (groupe: groupe, taches: liste..sort(_parEcheance)),
  ];
}

/// Priorité décroissante, puis titre croissant : l'ordre « de la plus
/// urgente à la moins urgente » de aFaire (A3), partagé avec le tri.
int comparerParUrgence(Tache a, Tache b) {
  final parPriorite = b.priorite.compareTo(a.priorite);
  return parPriorite != 0 ? parPriorite : a.titre.compareTo(b.titre);
}

/// Titre croissant, sans tenir compte des majuscules.
int _parTitre(Tache a, Tache b) =>
    a.titre.toLowerCase().compareTo(b.titre.toLowerCase());

/// Dates d'abord (la plus proche en premier), puis hebdomadaires (de lundi
/// à dimanche), puis sans échéance ; à égalité, par titre.
int _parEcheance(Tache a, Tache b) {
  final parCle = _cleEcheance(a.echeance).compareTo(_cleEcheance(b.echeance));
  return parCle != 0 ? parCle : _parTitre(a, b);
}

/// Clé de tri d'une échéance : un seul entier qui range les dates dans
/// l'ordre chronologique, puis les jours de la semaine, puis l'absence.
int _cleEcheance(Echeance echeance) => switch (echeance) {
  EcheanceDate(:final annee, :final mois, :final jour) =>
    annee * 10000 + mois * 100 + jour,
  EcheanceHebdomadaire(:final jourSemaine) => 100000000 + jourSemaine,
  SansEcheance() => 200000000,
};
