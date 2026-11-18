/// Priorité d'une tâche, ordonnée selon l'ordre de déclaration :
/// basse < normale < haute.
enum Priorite implements Comparable<Priorite> {
  basse('Basse'),
  normale('Normale'),
  haute('Haute');

  const Priorite(this.libelle);

  /// Libellé affichable.
  final String libelle;

  @override
  int compareTo(Priorite autre) => index.compareTo(autre.index);

  bool operator <(Priorite autre) => index < autre.index;
  bool operator <=(Priorite autre) => index <= autre.index;
  bool operator >(Priorite autre) => index > autre.index;
  bool operator >=(Priorite autre) => index >= autre.index;
}