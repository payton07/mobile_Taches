import 'echeance.dart';
import 'priorite.dart';
import 'tache.dart';

/// Priorité désignée par un code JSON, ou `null` si le code est inconnu.
/// La comparaison est sensible à la casse : `'High'` renvoie `null`.
Priorite? prioriteDepuisCode(String code) => switch (code) {
  'low' => Priorite.basse,
  'normal' => Priorite.normale,
  'high' => Priorite.haute,
  _ => null,
};

/// Construit une tâche à partir d'un document JSON déjà décodé.
///
/// Lève une [FormatException] si une clé obligatoire est absente, si une
/// valeur a le mauvais type, si une chaîne obligatoire est vide, si la
/// priorité est inconnue ou si `"due"` n'est pas une date `AAAA-MM-JJ` valide.
/// Les clés non reconnues sont ignorées.
Tache tacheDepuisJson(Map<String, Object?> json) => Tache(
  id: _chaineNonVide(json, 'id'),
  titre: _chaineNonVide(json, 'title'),
  priorite: _priorite(json, 'priority'),
  faite: _booleen(json, 'done'),
  echeance: _echeance(json, 'due'),
  note: _chaineFacultative(json, 'note'),
);

// ---------------------------------------------------------------------------
// Lecteurs de champs : chacun valide une clé et lève une FormatException.
// Une clé absente et une clé valant null sont traitées de la même façon,
// puisque json[cle] renvoie null dans les deux cas.
// ---------------------------------------------------------------------------

String _chaineNonVide(Map<String, Object?> json, String cle) =>
    switch (json[cle]) {
      String texte when texte.isNotEmpty => texte,
      final valeur =>
      throw FormatException('"$cle" doit être une chaîne non vide', valeur),
    };

String? _chaineFacultative(Map<String, Object?> json, String cle) =>
    switch (json[cle]) {
      null => null,
      String texte => texte,
      final valeur =>
      throw FormatException('"$cle" doit être une chaîne ou null', valeur),
    };

bool _booleen(Map<String, Object?> json, String cle) => switch (json[cle]) {
  bool booleen => booleen,
  final valeur =>
  throw FormatException('"$cle" doit être un booléen', valeur),
};

Priorite _priorite(Map<String, Object?> json, String cle) {
  final valeur = json[cle];
  if (valeur is String) {
    final priorite = prioriteDepuisCode(valeur);
    if (priorite != null) return priorite;
  }
  throw FormatException(
      '"$cle" doit valoir "low", "normal" ou "high"', valeur);
}

Echeance _echeance(Map<String, Object?> json, String cle) =>
    switch (json[cle]) {
      null => const SansEcheance(),
      String texte => EcheanceDate(_dateStricte(texte, cle)),
      final valeur =>
      throw FormatException('"$cle" doit être une date AAAA-MM-JJ', valeur),
    };

final _formatDate = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

/// Lit une date au format exact `AAAA-MM-JJ` et refuse les dates
/// inexistantes. `DateTime.parse` ne convient pas : il accepte d'autres
/// formats (heure, fuseau) et normalise silencieusement `2026-02-30`
/// en `2026-03-02`.
DateTime _dateStricte(String texte, String cle) {
  final correspondance = _formatDate.firstMatch(texte);
  if (correspondance != null) {
    final annee = int.parse(correspondance[1]!);
    final mois = int.parse(correspondance[2]!);
    final jour = int.parse(correspondance[3]!);
    // UTC : aucun décalage horaire ne peut modifier le jour obtenu.
    final date = DateTime.utc(annee, mois, jour);
    if (date.year == annee && date.month == mois && date.day == jour) {
      return date;
    }
  }
  throw FormatException(
      '"$cle" doit être une date AAAA-MM-JJ existante', texte);
}