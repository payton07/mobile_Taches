import 'echeance.dart';
import 'priorite.dart';

/// Une tâche immuable : toute « modification » renvoie une nouvelle tâche
/// de même identifiant, l'originale restant intacte.
final class Tache {
  /// Identifiant non vide ; absent de [copieAvec], il ne change donc jamais.
  final String id;
  final String titre;
  final Priorite priorite;
  final Echeance echeance;
  final String? note;
  final bool faite;

  /// Un [id] ou un [titre] vide est une erreur de programmation :
  /// [ArgumentError].
  Tache({
    required this.id,
    required this.titre,
    this.priorite = Priorite.normale,
    this.echeance = const SansEcheance(),
    this.note,
    this.faite = false,
  }) {
    if (id.isEmpty) {
      throw ArgumentError.value(id, 'id', 'ne doit pas être vide');
    }
    if (titre.isEmpty) {
      throw ArgumentError.value(titre, 'titre', 'ne doit pas être vide');
    }
  }

  /// Nouvelle tâche où seuls les éléments fournis diffèrent.
  ///
  /// Pour retirer la note, utiliser [sansNote] : ici, `note: null`
  /// signifie « conserver la note actuelle ».
  Tache copieAvec({
    String? titre,
    Priorite? priorite,
    Echeance? echeance,
    String? note,
    bool? faite,
  }) =>
      Tache(
        id: id,
        titre: titre ?? this.titre,
        priorite: priorite ?? this.priorite,
        echeance: echeance ?? this.echeance,
        note: note ?? this.note,
        faite: faite ?? this.faite,
      );

  /// Nouvelle tâche identique, mais sans note.
  Tache sansNote() => Tache(
    id: id,
    titre: titre,
    priorite: priorite,
    echeance: echeance,
    faite: faite,
  );

  /// Égalité par valeur : tous les champs sont comparés.
  @override
  bool operator ==(Object other) =>
      other is Tache &&
          other.id == id &&
          other.titre == titre &&
          other.priorite == priorite &&
          other.echeance == echeance &&
          other.note == note &&
          other.faite == faite;

  @override
  int get hashCode => Object.hash(id, titre, priorite, echeance, note, faite);

  @override
  String toString() => 'Tache(id: $id, titre: $titre, '
      'priorite: ${priorite.libelle}, echeance: $echeance, '
      'note: $note, faite: $faite)';
}