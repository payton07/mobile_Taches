/// Échéance d'une tâche : exactement l'un des trois cas ci-dessous.
///
/// `sealed` : les sous-classes ne peuvent être déclarées que dans ce fichier,
/// ce qui rend les `switch` sur une [Echeance] vérifiés exhaustifs.
sealed class Echeance {
  const Echeance();
}

/// Aucune échéance (valeur par défaut d'une tâche).
final class SansEcheance extends Echeance {
  const SansEcheance();

  @override
  bool operator ==(Object other) => other is SansEcheance;

  @override
  int get hashCode => (SansEcheance).hashCode;

  @override
  String toString() => 'SansEcheance()';
}

/// Échéance à une date : seuls le jour, le mois et l'année comptent.
final class EcheanceDate extends Echeance {
  final int annee;
  final int mois;
  final int jour;

  const EcheanceDate._(this.annee, this.mois, this.jour);

  /// Toute composante horaire de [date] est ignorée.
  factory EcheanceDate(DateTime date) =>
      EcheanceDate._(date.year, date.month, date.day);

  /// La date à minuit (heure locale).
  DateTime get date => DateTime(annee, mois, jour);

  @override
  bool operator ==(Object other) =>
      other is EcheanceDate &&
      other.annee == annee &&
      other.mois == mois &&
      other.jour == jour;

  @override
  int get hashCode => Object.hash(annee, mois, jour);

  @override
  String toString() => 'EcheanceDate($annee-$mois-$jour)';
}

/// Échéance hebdomadaire : un jour de la semaine, de lundi (1) à dimanche (7),
/// comme les constantes `DateTime.monday` … `DateTime.sunday`.
final class EcheanceHebdomadaire extends Echeance {
  final int jourSemaine;

  /// Un jour hors de [1, 7] est une erreur de programmation : [RangeError].
  EcheanceHebdomadaire(this.jourSemaine) {
    RangeError.checkValueInInterval(
      jourSemaine,
      DateTime.monday,
      DateTime.sunday,
      'jourSemaine',
    );
  }

  @override
  bool operator ==(Object other) =>
      other is EcheanceHebdomadaire && other.jourSemaine == jourSemaine;

  @override
  int get hashCode => jourSemaine.hashCode;

  @override
  String toString() => 'EcheanceHebdomadaire($jourSemaine)';
}
