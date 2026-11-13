# Montage IA — règles permanentes

Ce dossier sert à monter des reels avec Claude Code, du rush brut jusqu'à la publication dans Metricool.

## Comment l'utilisateur te parle
Il te parle normalement, comme à un monteur : « monte-moi ce rush », « copie le style de ces reels », « refais le 4 et le 11 », « mets-les sur le Drive », « programme-les à partir de lundi ». Il ne connaît aucun code d'étape et n'a rien à retenir.
- Reconnais l'étape dans ETAPES.md et exécute-la. S'il manque une info, demande-la en une seule question groupée.
- À la fin de chaque étape, dis en une phrase ce qui vient ensuite et propose de le lancer (« Je monte le clip test ? »). Un « oui » suffit.
- S'il dit « monte ce rush de A à Z », enchaîne toutes les étapes et ne t'arrête qu'aux validations : page de revue, clip test, lot monté, descriptions, planning Metricool.
- Ne lui demande jamais de taper un code ou une commande.

## Avant tout montage
- Lire METHODE.md (notre méthode : choix des clips, coupes, hooks, habillage), ERREURS.md et la fiche de style du format dans styles/.
- Pas encore de fiche de style ? Proposer styles/savoire-audit.md (le style des reels SAVOIRE) ou de copier le style de reels qu'il aime.
- S'il n'existe pas encore de moteur dans moteur/, proposer de le construire (ETAPES.md, « Construire le moteur ») avant tout.

## Le moteur
- Un seul moteur dans moteur/. Jamais de copie par projet.
- Toute correction validée va le jour même dans le moteur, la fiche de style ou ERREURS.md, pas seulement dans le projet en cours.

## Transcription
- Coupes et sous-titres : ElevenLabs Scribe (clé ELEVENLABS_API_KEY), mot à mot, avec horaires.
- Groq (GROQ_API_KEY) : seulement pour lire un long rush et choisir les clips.

## Montage
- Rendu depuis la source pleine définition, jamais depuis un proxy.
- Plages des clips figées AVANT les coupes fines.
- Un clip test validé avant le lot. Jamais le clip le plus court comme test.
- Chiffres en chiffres dans les sous-titres et les hooks.
- Jamais de hook ni de sous-titre sur la bouche ou le visage.
- 3 rendus en parallèle maximum (2 si le Mac a 8 Go).

## Contrôle (chaque rendu)
- Avant de montrer un reel, passer la checklist en 10 points en tête d'ERREURS.md et donner le résultat point par point. Un point raté = corriger d'abord.
- Retranscrire le rendu et comparer au sous-titre : tout écart = sous-titre faux ou tic resté audible.
- Chaque chaîne audio ffmpeg finit par asetpts=N/SR/TB ; vérifier que le son démarre à 0.
- Planche d'images à chaque raccord pour repérer les faux plans.
- Ouvrir le reel une seule fois, quand il est fini et contrôlé.

## Livraison
- Nouvelle version = nouveau nom -vN, jamais écraser un fichier.
- Correction = re-rendre uniquement les clips signalés.
- Ne rien publier sans l'accord explicite de l'utilisateur.

## Sécurité
- Ne jamais afficher ni écrire une clé API dans un fichier du dossier.
