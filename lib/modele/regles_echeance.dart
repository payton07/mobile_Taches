import 'echeance.dart';
import 'tache.dart';

/// Texte affichable d'une échéance :
/// « sans échéance », « pour le 1/12 », « chaque samedi ».
///
/// Aucun cas par défaut : Echeance étant `sealed`, le compilateur vérifie
/// que les trois formes sont traitées.
String libelleEcheance(Echeance echeance) => switch (echeance) {
  SansEcheance() => 'sans échéance',
  EcheanceDate(:final jour, :final mois) => 'pour le $jour/$mois',
  EcheanceHebdomadaire(:final jourSemaine) =>
  'chaque ${_nomsJours[jourSemaine - DateTime.monday]}',
};

/// Indexés de 0 (lundi) à 6 (dimanche).
const _nomsJours = [
  'lundi',
  'mardi',
  'mercredi',
  'jeudi',
  'vendredi',
  'samedi',
  'dimanche',
];

/// Vrai si et seulement si la tâche n'est pas faite et que son échéance est
/// une date d'un jour strictement antérieur à [aujourdhui] ; l'heure ne
/// compte pas. Une tâche sans échéance ou hebdomadaire n'est jamais en retard.
bool estEnRetard(Tache tache, {required DateTime aujourdhui}) {
  if (tache.faite) return false;
  return switch (tache.echeance) {
    EcheanceDate(:final annee, :final mois, :final jour) =>
        _jour(annee, mois, jour).isBefore(
            _jour(aujourdhui.year, aujourdhui.month, aujourdhui.day)),
    SansEcheance() || EcheanceHebdomadaire() => false,
  };
}

/// Un jour calendaire à minuit UTC : comparer deux de ces valeurs revient à
/// comparer les jours, sans que l'heure ni l'heure d'été n'interviennent.
DateTime _jour(int annee, int mois, int jour) =>
    DateTime.utc(annee, mois, jour);