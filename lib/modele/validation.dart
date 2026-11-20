import 'echeance.dart';

/// Règles de saisie d'une tâche (formulaire, partie E2).
///
/// Chaque fonction renvoie `null` si la saisie est valide, sinon le message
/// à afficher sous le champ : c'est exactement la forme attendue par le
/// `validator` d'un champ de formulaire Flutter.

/// Nombre maximal de caractères d'un titre, espaces de bord retirés.
const longueurMaxTitre = 60;

/// Nombre maximal de caractères d'une note, espaces de bord retirés.
const longueurMaxNote = 200;

/// Le titre est obligatoire (des espaces seuls ne comptent pas) et fait
/// [longueurMaxTitre] caractères au plus, une fois les espaces de début et
/// de fin retirés, comme ils le seront à l'enregistrement.
String? erreurTitre(String saisie) {
  final titre = saisie.trim();
  if (titre.isEmpty) return 'Le titre est obligatoire';
  if (titre.length > longueurMaxTitre) {
    return 'Le titre fait $longueurMaxTitre caractères au plus';
  }
  return null;
}

/// La note est facultative et fait [longueurMaxNote] caractères au plus,
/// une fois les espaces de début et de fin retirés.
String? erreurNote(String saisie) => saisie.trim().length > longueurMaxNote
    ? 'La note fait $longueurMaxNote caractères au plus'
    : null;

/// Une échéance datée ne peut pas être antérieure au jour de [aujourdhui] ;
/// l'heure ne compte pas, une échéance fixée à aujourd'hui reste valide.
///
/// Aucun cas par défaut : une nouvelle forme d'échéance devra être traitée.
String? erreurEcheance(Echeance echeance, {required DateTime aujourdhui}) =>
    switch (echeance) {
      EcheanceDate(:final annee, :final mois, :final jour)
          when _jour(annee, mois, jour).isBefore(
            _jour(aujourdhui.year, aujourdhui.month, aujourdhui.day),
          ) =>
        "L'échéance ne peut pas être antérieure à aujourd'hui",
      EcheanceDate() || SansEcheance() || EcheanceHebdomadaire() => null,
    };

/// Un jour calendaire à minuit UTC : comparer deux de ces valeurs revient à
/// comparer les jours, sans que l'heure ni l'heure d'été n'interviennent.
DateTime _jour(int annee, int mois, int jour) =>
    DateTime.utc(annee, mois, jour);
