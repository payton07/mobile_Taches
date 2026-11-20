import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart' show MaxLengthEnforcement;

import '../modele/taches.dart';

/// Écran de formulaire : saisie d'une nouvelle tâche.
///
/// Son état ne contient que la saisie en cours ; les tâches restent dans
/// l'écran de liste. « Enregistrer » ferme l'écran en renvoyant la nouvelle
/// tâche (Navigator.pop) ; un simple retour ne renvoie rien (null).
class EcranFormulaire extends StatefulWidget {
  const EcranFormulaire({
    super.key,
    required this.identifiant,
    required this.aujourdhui,
  });

  /// Identifiant de la tâche créée, choisi par la liste qui seule connaît
  /// les identifiants déjà pris.
  final String identifiant;

  /// Date du jour, fournie par la liste : le formulaire ne lit jamais
  /// l'horloge.
  final DateTime aujourdhui;

  @override
  State<EcranFormulaire> createState() => _EcranFormulaireState();
}

class _EcranFormulaireState extends State<EcranFormulaire> {
  /// Clé du Form : donne accès à validate() au moment d'enregistrer.
  final _cleFormulaire = GlobalKey<FormState>();
  final _titre = TextEditingController();
  final _note = TextEditingController();

  /// Clé du champ d'échéance : sa valeur est lue à l'enregistrement.
  final _cleEcheance = GlobalKey<FormFieldState<Echeance>>();
  Priorite _priorite = Priorite.normale;

  /// Désactivée à l'ouverture : aucun message sur un formulaire vierge.
  /// Après un premier refus, chaque champ est revalidé dès qu'il change.
  AutovalidateMode _validation = AutovalidateMode.disabled;

  @override
  void dispose() {
    // Les contrôleurs écoutent les champs : on les libère avec l'écran.
    _titre.dispose();
    _note.dispose();
    super.dispose();
  }

  /// Ouvre le calendrier ; une date choisie remplace l'échéance du champ
  /// [champ], une annulation la laisse inchangée.
  Future<void> _choisirDate(FormFieldState<Echeance> champ) async {
    final jour = DateUtils.dateOnly(widget.aujourdhui);
    final date = await showDatePicker(
      context: context,
      initialDate: switch (champ.value!) {
        EcheanceDate(:final date) => date,
        SansEcheance() || EcheanceHebdomadaire() => jour,
      },
      firstDate: jour,
      lastDate: DateTime(jour.year + 5, 12, 31),
    );
    if (date == null || !mounted) return;
    champ.didChange(EcheanceDate(date));
  }

  /// Valide la saisie puis ferme l'écran en renvoyant la nouvelle tâche ;
  /// si une règle n'est pas respectée, le formulaire reste ouvert.
  void _enregistrer() {
    if (!_cleFormulaire.currentState!.validate()) {
      setState(() => _validation = AutovalidateMode.onUserInteraction);
      return;
    }
    // Espaces de début et de fin retirés ; une note vide = pas de note.
    final note = _note.text.trim();
    Navigator.of(context).pop(
      Tache(
        id: widget.identifiant,
        titre: _titre.text.trim(),
        priorite: _priorite,
        echeance: _cleEcheance.currentState!.value!,
        note: note.isEmpty ? null : note,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle tâche')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Form(
            key: _cleFormulaire,
            autovalidateMode: _validation,
            // ListView : le formulaire défile sur un petit écran ou quand
            // le clavier est ouvert.
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _titre,
                  decoration: const InputDecoration(
                    labelText: 'Titre',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                  // Compteur « n/60 » sans bloquer la frappe : un titre trop
                  // long reste saisissable, puis il est refusé avec un message.
                  maxLength: longueurMaxTitre,
                  maxLengthEnforcement: MaxLengthEnforcement.none,
                  validator: (texte) => erreurTitre(texte ?? ''),
                ),
                const SizedBox(height: 16),
                const _Libelle('Priorité'),
                SegmentedButton<Priorite>(
                  segments: [
                    for (final priorite in Priorite.values)
                      ButtonSegment(
                        value: priorite,
                        label: Text(priorite.libelle),
                      ),
                  ],
                  selected: {_priorite},
                  showSelectedIcon: false,
                  onSelectionChanged: (choix) =>
                      setState(() => _priorite = choix.first),
                ),
                const SizedBox(height: 16),
                const _Libelle('Échéance'),
                // FormField : l'échéance passe par le même validate() que les
                // champs de texte, et son message s'affiche sous le bouton.
                FormField<Echeance>(
                  key: _cleEcheance,
                  initialValue: const SansEcheance(),
                  validator: (echeance) =>
                      erreurEcheance(echeance!, aujourdhui: widget.aujourdhui),
                  builder: (champ) => InputDecorator(
                    decoration: InputDecoration(
                      errorText: champ.errorText,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    child: Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _choisirDate(champ),
                          icon: const Icon(Icons.event_outlined),
                          // Libellé du modèle : « sans échéance », « pour le 3/12 ».
                          label: Text(libelleEcheance(champ.value!)),
                        ),
                        if (champ.value is EcheanceDate)
                          TextButton(
                            onPressed: () =>
                                champ.didChange(const SansEcheance()),
                            child: const Text('Retirer la date'),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _note,
                  decoration: const InputDecoration(
                    labelText: 'Note (facultative)',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  keyboardType: TextInputType.multiline,
                  minLines: 3,
                  maxLines: 6,
                  maxLength: longueurMaxNote,
                  maxLengthEnforcement: MaxLengthEnforcement.none,
                  validator: (texte) => erreurNote(texte ?? ''),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _enregistrer,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Enregistrer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Petit titre discret placé au-dessus d'un champ sans libellé propre.
class _Libelle extends StatelessWidget {
  const _Libelle(this.texte);

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        texte,
        style: Theme.of(context).textTheme.labelLarge
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}
