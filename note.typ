
**Rechargement à chaud et redémarrage**

Le *rechargement à chaud* (`r`) injecte le code source modifié dans la machine virtuelle Dart déjà en cours d'exécution,
 puis demande à Flutter de reconstruire l'interface en rappelant les méthodes `build()` des widgets, sans réexécuter
 la fonction `main()`. Or Flutter distingue les *widgets*, simples descriptions immuables recréées à chaque construction,
 des objets `State`, qui sont rattachés à l'*arbre des éléments* et conservés d'une construction à l'autre tant que
 le widget correspondant reste à la même place dans l'arbre.
 Ainsi, le `MaterialApp` étant reconstruit avec le nouveau code, la couleur du thème change immédiatement.
 Cependant, l'objet `_EcranListeState` n'étant pas recréé, ses champs, et notamment la liste `_taches` contenant
 les deux tâches ajoutées, restent intacts. Il en découle une conséquence moins visible : les initialisations
 exécutées à la création de l'état, comme l'initialiseur du champ `_taches`, ne sont pas rejouées.
 Une modification apportée à ce code ne serait donc pas prise en compte par un simple rechargement à chaud.

Le *redémarrage * (`R`) recharge lui aussi le code, mais relance l'application depuis `main()`.
Toute la mémoire de l'application est alors réinitialisée, les variables globales comme l'arbre des widgets et les objets
 `State`. Un nouvel objet `_EcranListeState` est ainsi créé, sa liste `_taches` étant relue depuis `tachesExempleJson`
 et son compteur `_numeroAjout` revenant à 1, ce qui fait disparaître les tâches ajoutées. Seul le code est conservé par ce geste,
 tandis que le rechargement à chaud conserve à la fois le code modifié et l'état de l'application.

**Où vit l'état de l'écran**

L'état de l'écran de liste vit dans les champs `_taches` et `_numeroAjout` de l'objet `_EcranListeState`,
créé une seule fois par la méthode `createState()` du `StatefulWidget` `EcranListe`, puis conservé par Flutter dans l'arbre des
éléments pendant toute la durée d'affichage de l'écran. C'est donc le widget `EcranListe` qui possède cet état, par l'intermédiaire
de son objet `State`, le widget lui-même restant immuable et pouvant être recréé à tout moment sans perte de données.
Le widget `LigneTache`, quant à lui, ne possède aucun état : étant un `StatelessWidget`, il se contente d'afficher la tâche
qui lui est transmise par l'écran. Chaque modification de l'état passe par `setState`, qui applique le changement puis
signale à Flutter que l'écran doit être reconstruit, ce qui garantit que l'affichage reste cohérent avec les données.
Enfin, cet état n'existe qu'en mémoire : aucun des deux gestes ne l'enregistre de façon durable, et la fermeture de l'application
fait perdre les tâches ajoutées.


La reponse de l'etape du dessu est peut etre un peu trop longue : lors de la redaction du compte rendu , il faut aller à l'essentiel
tout en detaillant.

