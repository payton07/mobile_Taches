
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

on retrouve la tache par son identifiant unique.

Pourquoi on ne peut pas écrire tache.faite = true. Le champ faite de la classe Tache étant déclaré final, il ne possède pas de setter : l’instruction tache.faite = true est rejetée dès la compilation, avec une erreur indiquant que faite ne peut pas être utilisé comme setter car il est final. Ainsi, une tâche ne peut jamais changer après sa construction, et le seul moyen d’obtenir une tâche faite est d’en créer une nouvelle avec copieAvec(faite: true), de même identifiant, l’originale restant intacte.

Ce qu’apporte l’immuabilité. Une tâche pouvant être transmise à plusieurs widgets, notamment à LigneTache et au calcul du compteur par bilan, l’immuabilité garantit qu’aucun d’eux ne peut la modifier à l’insu des autres, toute modification passant obligatoirement par l’écran qui possède l’état. Or ce passage obligé est précisément ce qui maintient l’affichage cohérent : en remplaçant la tâche dans un appel à setState, l’écran signale le changement à Flutter, qui reconstruit alors la liste ainsi que le compteur. Une modification directe de l’objet, si elle était possible, changerait les données sans que Flutter en soit averti, laissant l’écran afficher un état périmé jusqu’à la reconstruction suivante. Enfin, l’ancienne version de la tâche restant disponible, il devient simple d’envisager des fonctionnalités comme l’annulation d’une action.

Comment la tâche à remplacer est retrouvée. Chaque ligne reçoit de l’écran une fonction surBascule, qui appelle la méthode _basculer avec l’identifiant de la tâche affichée. Cette méthode construit, dans un setState, une nouvelle liste dans laquelle la tâche portant cet identifiant est remplacée par sa copie à l’état inversé, les autres tâches étant reprises sans changement. L’identifiant est utilisé plutôt que la position dans la liste car il est unique et ne change jamais, tandis que la position d’une tâche à l’écran peut différer de sa position dans l’état dès que la liste est triée ou filtrée.

Partie C1 :

L’état de l’écran et ce qui s’en déduit. L’état de l’écran de liste se compose de trois informations, conservées dans les champs de l’objet _EcranListeState : la liste complète des tâches _taches, le filtre d’affichage _filtre, valant « Toutes » par défaut, ainsi que le numéro _numeroAjout servant à générer un identifiant unique pour chaque tâche ajoutée. Or toutes les autres informations affichées s’en déduisent : la liste des tâches visibles est recalculée à chaque appel de build() en ne retenant que les tâches acceptées par le filtre, et le compteur « n à faire » est obtenu en appliquant la fonction bilan à la liste complète, ce qui lui permet de compter toutes les tâches non faites quel que soit le filtre choisi. Ainsi, cocher une tâche avec le filtre « À faire » la remplace dans _taches par une copie marquée faite, et la reconstruction déclenchée par setState l’écarte naturellement de la liste visible, sans qu’aucun code spécifique ne soit nécessaire pour la faire disparaître.

Pourquoi ne pas conserver la liste filtrée dans l’état. Conserver la liste filtrée dans l’état reviendrait à stocker deux fois les mêmes tâches, chaque modification devant alors être reportée dans les deux listes. Cependant, il suffirait d’oublier une mise à jour, notamment lors d’un ajout ou d’un changement de filtre, pour que l’affichage contredise les données, en montrant par exemple une tâche faite dans la vue « À faire ». En ne conservant qu’une seule source de vérité, la liste complète, et en dérivant la liste visible à chaque construction, l’écran ne peut jamais être incohérent, le coût de ce recalcul restant négligeable pour quelques dizaines de tâches. Enfin, le filtrage se contentant de lire chaque tâche par la méthode accepte, il ne modifie jamais aucune tâche, ce qui respecte la contrainte de l’énoncé et garantit qu’un changement de filtre n’a d’effet que sur l’affichage.


Partie C2 :

