// Outil interne du modèle : non exporté par taches.dart, il ne fait donc pas
// partie du contrat public.
import 'echeance.dart';

/// Vrai si le jour de [echeance] est strictement antérieur au jour de
/// [aujourdhui] ; l'heure ne compte pas.
///
/// Les deux jours sont ramenés à minuit UTC : les comparer revient à comparer
/// les jours, sans que l'heure ni l'heure d'été n'interviennent.
bool estAvantAujourdhui(EcheanceDate echeance, DateTime aujourdhui) =>
    DateTime.utc(
      echeance.annee,
      echeance.mois,
      echeance.jour,
    ).isBefore(DateTime.utc(aujourdhui.year, aujourdhui.month, aujourdhui.day));
