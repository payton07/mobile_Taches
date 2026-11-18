// « Mes tâches », un gestionnaire de tâches personnel.
// Point d'entrée : runApp() attache la racine de l'arbre de widgets à l'écran.
// Tout le reste est une composition de widgets.
import 'package:material_ui/material_ui.dart';
import 'ecrans/ecrans.dart';

void main() => runApp(const MesTachesApp());

class MesTachesApp extends StatelessWidget {
  const MesTachesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mes tâches',
      debugShowCheckedModeBanner: false,
      // Material 3 est le défaut et tout le thème dérive d'une couleur.
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.white)),
      // Écran provisoire : à remplacer par votre écran de liste (B1).
      home: const EcranListe(),
    );
  }
}

