import 'priorite.dart';
import 'tache.dart';

/// Nombre de tâches faites et nombre total ; `(faites: 0, total: 0)` pour
/// une collection vide.
///
/// Un seul parcours : un Iterable peut être paresseux (recalculé à chaque
/// parcours), on évite donc de le parcourir deux fois.
({int faites, int total}) bilan(Iterable<Tache> taches) {
  var faites = 0;
  var total = 0;
  for (final tache in taches) {
    total++;
    if (tache.faite) faites++;
  }
  return (faites: faites, total: total);
}

/// Nouvelle liste des tâches non faites de priorité au moins [auMoins],
/// de la plus urgente à la moins urgente puis, à priorité égale, par titre.
/// La collection reçue n'est jamais modifiée.
List<Tache> aFaire(
  Iterable<Tache> taches, {
  Priorite auMoins = Priorite.basse,
}) =>
    taches.where((tache) => !tache.faite && tache.priorite >= auMoins).toList()
      ..sort(_parUrgencePuisTitre);

/// Priorité décroissante, puis titre croissant.
int _parUrgencePuisTitre(Tache a, Tache b) {
  final parPriorite = b.priorite.compareTo(a.priorite);
  return parPriorite != 0 ? parPriorite : a.titre.compareTo(b.titre);
}
