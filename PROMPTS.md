# Pré-prompts du montage IA

L'utilisateur tape le raccourci (P0, P1, STYLE…) suivi de ses infos. Les < > sont à remplir avec ce qu'il donne.

## P0 — Construire le moteur (une seule fois)
Construis mon moteur de montage dans moteur/, en Python (venv .venv) + ffmpeg-full. Un seul moteur pour tous mes lots.
Entrées : la fiche de style (styles/<style>.md) et un fichier de réglages par projet (_projet/clips-cfg.json). Sortie : un reel 9:16 par clip.
Il doit savoir :
- découper des plages au mot près à partir d'une transcription Scribe (re-transcrire la fenêtre de chaque clip pour des horaires exacts) ;
- couper les blancs et les tics, et les mots que je liste entre crochets ;
- corriger le texte d'un sous-titre sans toucher au son ;
- détecter les changements de plan et les visages, recadrer avec un cadrage fixe par plan, zoom alterné aux coupes si la fiche le demande ;
- gérer deux personnes (celle qui parle à l'écran, ou écran partagé) ;
- poser le hook, les sous-titres (fichier ASS), les noms à l'écran, les bips, les bruitages, la musique en boucle ;
- normaliser la voix à -15 LUFS et finir chaque chaîne audio par asetpts=N/SR/TB ;
- exporter en H.264 matériel (h264_videotoolbox).
Trois modes : DRY (texte final mot à mot + horaires, sans rendu), PIECES (planche des plans des 2 premières secondes, sans rendu), et rendu. Garde en cache ce qui n'a pas changé.
Si la fiche de style contient beaucoup de motion design, ajoute Remotion au moteur pour les habillages animés.
Teste-le sur 30 s d'un de mes rushes et montre-moi le résultat.

## STYLE — Copier un style à partir de liens
Je veux reproduire le style de montage de ces vidéos (pas leur contenu) : <liens>. Nom du style : <nom>.
1. Télécharge chaque vidéo avec yt-dlp dans styles/references/<nom>/ (Instagram bloque : ajoute --cookies-from-browser chrome).
2. Extrais des images : une toutes les 0,5 s sur les 5 premières secondes, puis une par seconde, plus une à chaque changement de plan. Fais des planches de 12 images et regarde-les toutes.
3. Transcris le son avec ElevenLabs Scribe pour voir comment les sous-titres suivent la voix.
4. Mesure : durée de chaque plan, blancs entre les phrases, volume de la musique dans les pauses par rapport à la voix, couleurs exactes (hex) des textes et encarts, position des textes en pixels sur une image 1080x1920.
5. Pour chaque police, donne la plus proche disponible sur Mac ou Google Fonts.
6. Écris la fiche dans styles/<nom>.md avec le modèle styles/_modele-fiche.md : chaque réglage chiffré, avec la référence et le moment exact où tu l'as vu.
7. Sépare ce qui revient sur toutes les références (le style) de ce qui n'apparaît qu'une fois (à me faire trancher).
8. Montre-moi une image de chaque élément (hook, sous-titres, nom à l'écran) recréé à côté de l'original, avant tout montage.

## P1 — Nouveau projet et transcription
Nouveau projet : <nom>. Le rush est ici : <chemin>.
Crée projets/<date> <nom>/ avec rush/, _projet/ et releases/, copie le rush dans rush/.
Vérifie le format avec ffprobe (définition, i/s, codec, HDR, orientation). Si c'est du 4K, du 50 i/s ou du HEVC : fais un proxy 25 i/s H.264 en pleine définition sur la zone utile, avec le son.
Transcris tout le rush avec ElevenLabs Scribe, par morceaux de 5 min en parallèle, mot à mot avec horaires et locuteurs. Cherche les trous (mot de plus de 4 s, blanc de plus de 6 s) et relance ces morceaux.
Dis-moi qui parle, en vérifiant 2 ou 3 passages.

## P2 — Sélection des clips
Lis toute la transcription et propose les meilleurs clips.
- un clip = un seul propos, du début à la fin ;
- 30 s minimum, 30 à 60 s visé ; s'il manque du contexte, remonte plus haut ;
- il commence sur la phrase qui porte l'idée, jamais sur « Et », « Donc », « Ouais » ou une phrase qui renvoie à avant ;
- il finit sur une phrase complète ;
- garde les passages où <qui enseigne> enseigne, les chiffres forts et les phrases choc ; coupe quand l'autre personne parle trop longtemps.
Pour chaque clip : numéro, IN, OUT (HH:MM:SS:FF), durée, sujet en 5 mots. Écris _projet/clips.md, puis une page de revue HTML : la vidéo, chaque clip cliquable qui se lit de IN à OUT, Garder / Sortir, un champ commentaire et un bouton « Copier mes choix ». Vérifie que la vidéo a du son, puis ouvre-la.

## P3 — Les hooks
Voici mes choix : <résultat de « Copier mes choix »>.
Pour chaque clip gardé, écris UN hook : question ou mystère, en « tu », phrase complète, 2 lignes maximum, repris des mots exacts du clip, chiffres en chiffres, jamais un titre descriptif.
Écris _projet/hooks.json et montre-moi toute la liste d'un coup.

## P4 — Le clip test
Monte un clip test avec la fiche styles/<style>.md. Choisis un clip qui a du contexte, un chiffre et un changement de plan, jamais le plus court.
1. Fige ses plages. 2. Montre-moi le texte final mot à mot (DRY) et la planche des plans (PIECES). 3. Rends-le et fais le contrôle complet (CLAUDE.md + ERREURS.md). 4. Ouvre-le une seule fois, fini et contrôlé. 5. Donne-moi le temps estimé pour tout le lot.

## P5 — Le lot
Clip test validé. Applique exactement les mêmes réglages à tous les clips gardés.
1. Fige les plages de TOUS les clips avant la moindre coupe fine. 2. Relis le texte de chaque clip mot à mot : tics, redites, faux départs, mots mal transcrits. 3. Rends le lot, 3 clips à la fois maximum, les plus longs d'abord. 4. Contrôle chaque rendu. 5. Livre dans releases/ et donne-moi la liste : numéro, hook, durée, alertes.

## P6 — Les corrections
Corrections : <liste, une ligne par clip avec le timecode>.
Refais UNIQUEMENT ces clips, en nouvelle version (-v2). Vérifie si le même défaut existe dans les autres clips, sans les re-rendre, et dis-moi lesquels. Ajoute chaque correction qui peut revenir dans le moteur, la fiche de style ou ERREURS.md.

## P7 — Le Drive
Copie les reels validés de releases/ dans mon Google Drive (dossier monté dans le Finder) : Reels/<Personne>/<AAAA>/<MM - Mois>/S<n> (<lundi> - <dimanche>)/<source>/.
Attends la fin de la synchronisation, puis vérifie avec le connecteur Google Drive que chaque fichier est en ligne et fait la bonne taille. Partage le dossier en lecture par lien et enregistre le lien de chaque fichier dans _projet/drive-links.json.

## P8 — Les descriptions
Écris la description Instagram de chaque reel dans _projet/descriptions.json : en « tu », adressée au viewer (jamais « X et Y parlent de… »), 1re phrase = l'idée du reel, 2 à 4 lignes, chiffres en chiffres, un seul appel à l'action : <CTA>, 3 hashtags maximum. Montre-les-moi toutes avant de publier.

## P9 — La programmation dans Metricool
Programme les reels avec le connecteur Metricool, marque <nom>, fuseau Europe/Paris. Créneaux : <heures>, à partir du <date>, dans l'ordre <ordre>. Jamais deux reels de la même source à la suite. Média = le lien Drive (drive-links.json), description = descriptions.json. Réseaux : <Instagram, TikTok, YouTube Shorts, Facebook>.
Quand c'est fait, relis la liste programmée dans Metricool et donne-moi le tableau date → reel, sans trou ni doublon.

## P10 — Clore le lot
Vérifie que chaque reel de releases/ est sur le Drive et programmé dans Metricool. Supprime les fichiers de travail lourds (proxy, morceaux de rendu), garde les réglages et la transcription. Liste ce qu'on a corrigé pendant ce lot et ajoute à ERREURS.md ou à la fiche de style ce qui doit devenir une règle.
