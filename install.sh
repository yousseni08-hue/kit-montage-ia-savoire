#!/bin/bash
# Kit Montage IA — installation complète sur Mac
# Relançable sans risque : ce qui est déjà installé est gardé, tes fichiers ne sont jamais écrasés.
set -e
KIT="$HOME/Montage-IA"
ok()   { printf "\033[32m✔ %s\033[0m\n" "$1"; }
etape(){ printf "\n\033[1m== %s ==\033[0m\n" "$1"; }

etape "1/5 Homebrew"
if [ -z "$SKIP_BREW" ]; then
  if ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do [ -x "$b" ] && eval "$($b shellenv)" && BREW="$b"; done
    grep -q "brew shellenv" "$HOME/.zprofile" 2>/dev/null || echo "eval \"\$($BREW shellenv)\"" >> "$HOME/.zprofile"
  fi
  ok "Homebrew"

  etape "2/5 Outils vidéo (ffmpeg-full, yt-dlp, python, node)"
  brew install ffmpeg-full yt-dlp python node
  FF="$(brew --prefix)/opt/ffmpeg-full/bin"
  grep -q "ffmpeg-full/bin" "$HOME/.zshrc" 2>/dev/null || echo "export PATH=\"$FF:\$PATH\"" >> "$HOME/.zshrc"
  export PATH="$FF:$PATH"
  ok "Outils vidéo"

  etape "3/5 Claude Code"
  if ! command -v claude >/dev/null 2>&1 && [ ! -x "$HOME/.local/bin/claude" ]; then
    curl -fsSL https://claude.ai/install.sh | bash
  fi
  grep -q ".local/bin" "$HOME/.zshrc" 2>/dev/null || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
  ok "Claude Code"
fi

etape "4/5 Dossier de travail ~/Montage-IA"
mkdir -p "$KIT/moteur" "$KIT/styles/references" "$KIT/musiques" "$KIT/sfx" "$KIT/projets"
ecrire() { # ecrire <fichier> : écrit le contenu reçu seulement si le fichier n'existe pas
  if [ -e "$1" ]; then cat > /dev/null; echo "  (gardé, déjà présent) $1"; else cat > "$1"; echo "  créé $1"; fi
}
ecrire "$KIT/CLAUDE.md" <<'KIT_FILE_END'
# Montage IA — règles permanentes

Ce dossier sert à monter des reels avec Claude Code, du rush brut jusqu'à la publication dans Metricool.

## Comment l'utilisateur te parle
Il te parle normalement, comme à un monteur : « monte-moi ce rush », « copie le style de ces reels », « refais le 4 et le 11 », « mets-les sur le Drive », « programme-les à partir de lundi ». Il ne connaît aucun code d'étape et n'a rien à retenir.
- Reconnais l'étape dans ETAPES.md et exécute-la. S'il manque une info, demande-la en une seule question groupée.
- À la fin de chaque étape, dis en une phrase ce qui vient ensuite et propose de le lancer (« Je monte le clip test ? »). Un « oui » suffit.
- S'il dit « monte ce rush de A à Z », enchaîne toutes les étapes et ne t'arrête qu'aux validations : page de revue, clip test, lot monté, descriptions, planning Metricool.
- Ne lui demande jamais de taper un code ou une commande.

## Avant tout montage
- Suivre le skill methode-savoire (notre méthode : choix des clips, coupes, hooks, habillage, contrôle), lire ERREURS.md et la fiche de style du format dans styles/.
- Au début de chaque nouveau lot, mettre à jour les skills SAVOIRE sans rien demander : `claude plugin marketplace update savoire && claude plugin update montage-savoire@savoire`. S'ils ne sont pas installés : `claude plugin marketplace add yousseni08-hue/kit-montage-ia-savoire && claude plugin install montage-savoire@savoire`.
- Pas encore de fiche de style ? Proposer styles/savoire-audit.md (le style des reels SAVOIRE, aussi dans le skill style-savoire) ou de copier le style de reels qu'il aime.
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
KIT_FILE_END
ecrire "$KIT/ETAPES.md" <<'KIT_FILE_END'
# Les étapes du montage

L'utilisateur ne connaît aucun code d'étape : il parle normalement. Reconnais l'étape à ce qu'il dit (les phrases « Il peut dire » sont des exemples, pas des formules à respecter). Les < > sont à remplir avec ce qu'il donne ; s'il manque quelque chose, demande-le en une seule question groupée.
À la fin de chaque étape, dis en une phrase ce qui vient ensuite et propose de le lancer. Un « oui » suffit.

## Construire le moteur (une seule fois)
Il peut dire : « construis mon moteur », « prépare tout pour monter ». À proposer de toi-même s'il n'y a rien dans moteur/.
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

## Copier un style à partir de liens
Il peut dire : « copie le style de ces reels : <liens> », « je veux ce montage-là ».
Je veux reproduire le style de montage de ces vidéos (pas leur contenu) : <liens>. Nom du style : <nom>.
1. Télécharge chaque vidéo avec yt-dlp dans styles/references/<nom>/ (Instagram bloque : ajoute --cookies-from-browser chrome).
2. Extrais des images : une toutes les 0,5 s sur les 5 premières secondes, puis une par seconde, plus une à chaque changement de plan. Fais des planches de 12 images et regarde-les toutes.
3. Transcris le son avec ElevenLabs Scribe pour voir comment les sous-titres suivent la voix.
4. Mesure : durée de chaque plan, blancs entre les phrases, volume de la musique dans les pauses par rapport à la voix, couleurs exactes (hex) des textes et encarts, position des textes en pixels sur une image 1080x1920.
5. Pour chaque police, donne la plus proche disponible sur Mac ou Google Fonts.
6. Écris la fiche dans styles/<nom>.md avec le modèle styles/_modele-fiche.md : chaque réglage chiffré, avec la référence et le moment exact où tu l'as vu.
7. Sépare ce qui revient sur toutes les références (le style) de ce qui n'apparaît qu'une fois (à me faire trancher).
8. Montre-moi une image de chaque élément (hook, sous-titres, nom à l'écran) recréé à côté de l'original, avant tout montage.

## Nouveau projet et transcription
Il peut dire : « monte-moi ce rush : <chemin> », « j'ai un nouveau call à clipper ».
Nouveau projet : <nom>. Le rush est ici : <chemin>.
Crée projets/<date> <nom>/ avec rush/, _projet/ et releases/, copie le rush dans rush/.
Vérifie le format avec ffprobe (définition, i/s, codec, HDR, orientation). Si c'est du 4K, du 50 i/s ou du HEVC : fais un proxy 25 i/s H.264 en pleine définition sur la zone utile, avec le son.
Transcris tout le rush avec ElevenLabs Scribe, par morceaux de 5 min en parallèle, mot à mot avec horaires et locuteurs. Cherche les trous (mot de plus de 4 s, blanc de plus de 6 s) et relance ces morceaux.
Dis-moi qui parle, en vérifiant 2 ou 3 passages.

## Sélection des clips
Enchaîne directement après la transcription, sans attendre qu'on te le demande.
Lis toute la transcription et propose les meilleurs clips.
- un clip = un seul propos, du début à la fin ;
- 30 s minimum, 30 à 60 s visé ; s'il manque du contexte, remonte plus haut ;
- il commence sur la phrase qui porte l'idée, jamais sur « Et », « Donc », « Ouais » ou une phrase qui renvoie à avant ;
- il finit sur une phrase complète ;
- garde les passages où <qui enseigne> enseigne, les chiffres forts et les phrases choc ; coupe quand l'autre personne parle trop longtemps.
Pour chaque clip : numéro, IN, OUT (HH:MM:SS:FF), durée, sujet en 5 mots. Écris _projet/clips.md, puis une page de revue HTML : la vidéo, chaque clip cliquable qui se lit de IN à OUT, Garder / Sortir, un champ commentaire et un bouton « Copier mes choix ». Vérifie que la vidéo a du son, puis ouvre-la.

## Les hooks
Il colle le résultat de « Copier mes choix », ou dit : « voilà mes choix », « écris les hooks ».
Voici mes choix : <résultat de « Copier mes choix »>.
Pour chaque clip gardé, écris UN hook : question ou mystère, en « tu », phrase complète, 2 lignes maximum, repris des mots exacts du clip, chiffres en chiffres, jamais un titre descriptif.
Écris _projet/hooks.json et montre-moi toute la liste d'un coup.

## Le clip test
Il peut dire : « vas-y », « monte le clip test ». À proposer dès que les hooks sont validés.
Monte un clip test avec la fiche styles/<style>.md. Choisis un clip qui a du contexte, un chiffre et un changement de plan, jamais le plus court.
1. Fige ses plages. 2. Montre-moi le texte final mot à mot (DRY) et la planche des plans (PIECES). 3. Rends-le et fais le contrôle complet (CLAUDE.md + ERREURS.md). 4. Ouvre-le une seule fois, fini et contrôlé. 5. Donne-moi le temps estimé pour tout le lot.

## Le lot
Il peut dire : « c'est bon, lance tout », « monte le reste ».
Clip test validé. Applique exactement les mêmes réglages à tous les clips gardés.
1. Fige les plages de TOUS les clips avant la moindre coupe fine. 2. Relis le texte de chaque clip mot à mot : tics, redites, faux départs, mots mal transcrits. 3. Rends le lot, 3 clips à la fois maximum, les plus longs d'abord. 4. Contrôle chaque rendu. 5. Livre dans releases/ et donne-moi la liste : numéro, hook, durée, alertes.

## Les corrections
Il envoie ses retours, souvent avec des captures : « refais le 4 et le 11 : … », « les sous-titres sont trop bas ».
Corrections : <liste, une ligne par clip avec le timecode>.
Refais UNIQUEMENT ces clips, en nouvelle version (-v2). Vérifie si le même défaut existe dans les autres clips, sans les re-rendre, et dis-moi lesquels. Ajoute chaque correction qui peut revenir dans le moteur, la fiche de style ou ERREURS.md.

## Le Drive
Il peut dire : « mets-les sur le Drive ».
Copie les reels validés de releases/ dans mon Google Drive (dossier monté dans le Finder) : Reels/<Personne>/<AAAA>/<MM - Mois>/S<n> (<lundi> - <dimanche>)/<source>/.
Attends la fin de la synchronisation, puis vérifie avec le connecteur Google Drive que chaque fichier est en ligne et fait la bonne taille. Partage le dossier en lecture par lien et enregistre le lien de chaque fichier dans _projet/drive-links.json.

## Les descriptions
Il peut dire : « écris les descriptions », avec ou sans appel à l'action.
Écris la description Instagram de chaque reel dans _projet/descriptions.json : en « tu », adressée au viewer (jamais « X et Y parlent de… »), 1re phrase = l'idée du reel, 2 à 4 lignes, chiffres en chiffres, un seul appel à l'action : <CTA>, 3 hashtags maximum. Montre-les-moi toutes avant de publier.

## La programmation dans Metricool
Il peut dire : « programme-les à 11 h et 17 h à partir de lundi ».
Programme les reels avec le connecteur Metricool, marque <nom>, fuseau Europe/Paris. Créneaux : <heures>, à partir du <date>, dans l'ordre <ordre>. Jamais deux reels de la même source à la suite. Média = le lien Drive (drive-links.json), description = descriptions.json. Réseaux : <Instagram, TikTok, YouTube Shorts, Facebook>.
Quand c'est fait, relis la liste programmée dans Metricool et donne-moi le tableau date → reel, sans trou ni doublon.

## Clore le lot
Il peut dire : « on clôt le lot », « c'est fini ». À proposer de toi-même une fois tout programmé.
Vérifie que chaque reel de releases/ est sur le Drive et programmé dans Metricool. Supprime les fichiers de travail lourds (proxy, morceaux de rendu), garde les réglages et la transcription. Liste ce qu'on a corrigé pendant ce lot et ajoute à ERREURS.md ou à la fiche de style ce qui doit devenir une règle.
KIT_FILE_END
ecrire "$KIT/ERREURS.md" <<'KIT_FILE_END'
# Les erreurs à ne pas commettre

Claude relit ce fichier avant chaque montage et chaque contrôle. Chaque ligne vient d'un vrai reel raté.

## Checklist obligatoire avant de rendre un reel
Après chaque rendu, Claude vérifie ces 10 points sur le fichier fini et donne le résultat point par point. Un seul point raté = le reel est corrigé avant d'être montré.
1. Sous-titres : bien placés (jamais sur le menton, la bouche ou le micro) et fidèles à l'audio.
2. Changements de plan : propres, sans flash d'un autre plan au raccord ; la personne à l'écran est celle qui parle.
3. Musique : bien dosée, toujours sous la voix, jusqu'à la fin du reel.
4. Coupes : bonnes, aucune au milieu d'un mot.
5. Hook : lisible et hors du visage, s'il y en a un (certains formats n'en ont pas).
6. Faux départs : retirés, aucune phrase ratée ni reprise audible.
7. Phrases inutiles : enlevées (redites, tics, phrases qui ne servent pas le propos).
8. Son : bon, sans blanc au début une fois sur Instagram.
9. Durée : conforme à la règle de durée de la fiche de style.
10. Chiffres : écrits en chiffres.
Tout est coché : le reel est bon.

La durée est un choix, pas une règle universelle : chez SAVOIRE on vise 30 s minimum, mais chaque fiche de style fixe la sienne (un reel de 20 s est très bien si c'est ce que tu veux).

## Coupes
- Couper au milieu d'un mot : un bout de mot reste audible. Caler chaque coupe sur le creux de son entre deux mots, pas seulement sur l'horaire de la transcription (il peut être décalé de 0,4 s).
- Laisser un faux départ (« il faut… il faut que tu… ») : garder uniquement la reprise, couper le raté ET le blanc qui suit.
- Commencer sur « Et », « Donc », « Ouais » ou une phrase qui renvoie à avant. Finir en suspens (« genre… », « bref »).
- Couper les blancs trop court : le débit devient robotique. Garder environ 0,07 s d'air de chaque côté d'une coupe.
- Changer la plage d'un clip après avoir posé les coupes fines : la transcription change et toutes les coupes se décalent. Plages d'abord, coupes ensuite.
- Un clip de moins de 25-30 s : il s'arrête trop tôt. Aller chercher la suite du même propos.
- Mettre deux idées dans un clip. Un clip = un seul propos, du début à la fin.
- Garder les démonstrations et les jeux de rôle (« dis-lui ça : … ») : on garde la thèse et ses arguments.
- Croire la transcription pour les tics : certains « euh » n'y sont pas et restent audibles. Seule la re-transcription du rendu final les montre.

## Sous-titres
- Sous-titre sur la bouche ou le menton, ou trop bas (sur le micro, sous les boutons d'Instagram). Lignes de 700 à 800 px de large maximum, rien dans les 300 px du bas.
- Sous-titre qui affiche un mot que personne n'entend : le sous-titre suit toujours l'audio.
- Noms d'outils, de marques, de personnes mal transcrits. Tenir une liste de vocabulaire et la corriger à chaque lot.
- Deux sous-titres qui se chevauchent (horaires de transcription dans le désordre) : vérifier avant chaque rendu.
- Ligne qui finit sur « de », « le », « la ». Chiffre séparé de son unité (« 10 000 | € »).
- Chiffres écrits en lettres. Toujours « 40 % », « 3 millions », « 2 fois ».
- Alourdir le style (gros contour, grosse ombre) : ça fait cheap tout de suite.
- Sous-titres pendant le hook : le hook est seul à l'écran.

## Changements de plan et cadrage
- Un cadrage qui suit la tête en permanence : ça bouge, c'est moche. Un cadrage fixe par plan.
- Un faux plan : 1 ou 2 images d'un autre plan collées à un raccord, vues comme un flash. Un plan de moins de 12 images est remplacé par une image figée du plan d'avant.
- Zoomer (punch-in) sur un gros plan : trop proche. Le zoom alterné, seulement sur un plan large.
- Cadrer sur un faux visage (reflet, bout de tête flou au bord de l'image). Regarder la planche des 2 premières secondes de chaque clip.
- Ouvrir un clip sur un carton du vidéaste ou un écran titre.
- Montrer quelqu'un qui bouge les lèvres sans son, ou poser une autre image pendant qu'une personne parle face caméra (lèvres pas synchro).
- Rendre depuis le proxy : image molle. Toujours la source pleine définition.
- Rush iPhone en HDR + image ou photo normale posée dessus : peau rouge et cramée. Convertir l'image au même espace couleur.

## Deux personnes à l'écran
- Laisser à l'écran celle qui ne parle pas pendant longtemps. Celle qui parle est à l'image.
- Écran partagé haut/bas seulement quand les deux réagissent en même temps.
- Se fier à la transcription pour savoir qui parle : elle se trompe. Vérifier à l'image (qui bouge la bouche).
- Les sous-titres vont sous le menton de la personne à l'écran, pas à une hauteur fixe pensée pour l'autre.

## Nommer quelqu'un à l'écran
- Une carte ou un bandeau de nom à chaque mention : seulement à la première, environ 1 s.
- Un nom mal orthographié. Vérifier l'orthographe avant le rendu.
- Une photo tirée d'une capture du rush : toujours une vraie photo propre, validée avant le rendu.
- Pendant la carte, le sous-titre = le nom de la personne, pas la phrase.

## Musique
- Une musique avec paroles sous la voix : on ne comprend plus rien.
- Musique trop forte. Repère : volume 0,07 sous une voix à -15 LUFS.
- Musique qui s'arrête avant la fin du clip : la mettre en boucle.
- La même musique sur tous les reels : faire tourner 4 ou 5 musiques.

## Son
- Isolation de voix « pour faire propre » : elle étouffe les mots et crée des fautes de transcription. Son naturel, juste normalisé.
- Blanc de 1 à 3 s au début du reel une fois sur Instagram (invisible sur le Mac) : finir chaque chaîne audio ffmpeg par asetpts=N/SR/TB et vérifier les horaires du son.
- Un bip qui laisse passer un mot court : couper le son du mot ET poser le bip.

## Bruitages (SFX)
- Whoosh et pop partout : ça fait amateur. Un clic discret sur les moments clés suffit.
- Un bruitage plus fort que la voix.
- Un bruitage sans rien à l'image qui le justifie.

## Couleurs
- Demander à Claude d'étalonner lui-même : il est mauvais en étalonnage aujourd'hui. Utiliser des LUTs (l'outil de LUTs partagé avec le programme) ou un rush déjà étalonné.
- Monter un rush tourné en log : il sort gris et terne. Toujours demander une vidéo étalonnée au tournage. À l'Osmo Pocket en mode normal, il n'y a rien à régler.
- Étalonnage différent d'un plan à l'autre dans le même reel.
- Filtre fort sur la peau.
- Image délavée après export : vérifier l'espace couleur (bt709) à l'export.

## Hook et animations
- Hook descriptif (« Les 3 erreurs du closing ») au lieu d'une question ou d'un mystère.
- Hook qui reprend une idée d'un autre clip au lieu des mots exacts de celui-ci.
- Hook de plus de 2-3 lignes, ou posé sur le visage.
- Animation qui cache le visage, qui dure plus de 2-3 s, ou écran noir avec du texte au milieu d'un reel.
- Sur YouTube : jamais de carton titre plein écran au début, démarrer direct sur la phrase d'accroche.

## Livraison
- Monter tout le lot sans clip test validé.
- Écraser un fichier déjà ouvert ou envoyé (il apparaît « corrompu ») : nouvelle version -v2.
- Ouvrir un reel avant la fin du rendu et du contrôle.
- Tout re-rendre pour une correction sur un clip.
- Lancer plus de 3 rendus en même temps.
- Corriger un bug dans le projet sans le reporter dans le moteur ou les règles : il revient au lot suivant.
KIT_FILE_END
ecrire "$KIT/styles/_modele-fiche.md" <<'KIT_FILE_END'
# Style : <nom>
Références : <liens>   Validé le : <date>   Clip test : <fichier>

## Format
- Sortie : 1080x1920, 25 i/s, H.264 ~18 Mb/s, son AAC 192k
- Recadrage : <fixe par plan / suit la tête> ; visage à <x> % de la hauteur

## Rythme
- Blancs coupés au-delà de <0,30> s (marge <0,08> s avant, <0,14> s après)
- Tics retirés : euh, bah, en fait, du coup, tu vois (sauf s'il porte le sens)
- Durée cible d'un clip : <30-60> s

## Hook
- Présent : oui/non ; seul à l'écran pendant <3> s
- Encart : <blanc, coins 7 px> ; police <Montserrat Bold 40> <noir>
- Position : y = <1170> px ; 2 lignes max, équilibrées

## Sous-titres
- Police <Helvetica Neue Medium 46>, <MAJUSCULES>, <blanc>, contour <2 px noir flou>
- Blocs de <4> mots / <26> caractères ; <mot à mot / par bloc>
- Position : <y fixe 1000 / sous le menton + 165 px>
- Mots mis en avant : <aucun / un mot clé en italique par bloc>

## Plans
- Zoom aux coupes : <1,00 / 1,12 en alternance>, seulement sur <plan large>
- Deux personnes : <celle qui parle seule / écran partagé>

## Habillage
- Nom à l'écran : <carte photo 1 s / bandeau bas / aucun>
- Transitions : <coupe sèche / flash + clic à 3 s>
- Bruitages : <clic discret sur les cartes>
- Textes animés : <aucun / chiffres clés en gros>

## Son
- Voix normalisée à -15 LUFS, son naturel (pas d'isolation de voix)
- Musique : <sans paroles>, volume <0,07>, en boucle jusqu'à la fin

## Couleurs
- <image brute / LUT chaude / contraste +10 %>

## Fin
- <coupe sur la dernière phrase / carton / CTA>
KIT_FILE_END
ecrire "$KIT/styles/savoire-audit.md" <<'KIT_FILE_END'
# Style : SAVOIRE audit (reels de Mason)
Références : les reels de @mason (audits et calls filmés)   Validé le : 02/11/2026   Clip test : à faire sur ton premier rush
Pour quoi : un call, un audit ou un podcast filmé à 2 ou 3 caméras, un expert face à un client. Méthode complète : METHODE.md.

## Format
- Sortie : 1080x1920, fps du rush (24 ou 25 i/s), H.264 ~18 Mb/s, son AAC 192k
- Recadrage 9:16 : FIXE par plan, jamais de suivi de tête ; jamais de 16:9 avec bandes noires
- Plan large central : à éviter. S'il couvre un passage, mettre à la place la cliente qui écoute en gros plan

## Rythme
- Coupes au mot près, sur le creux de son entre deux mots ; faux départs et reprises supprimés
- Tics retirés : euh, bah, ben, en fait, du coup, je veux dire, enfin, quoi final, tu vois de remplissage
- 2-3 réactions du client gardées par lot (question, surprise)
- Durée : 30 s minimum, idéalement 30-45 s, plus long si le propos l'exige ; jamais un clip qui coupe un raisonnement

## Hook
- Présent : oui ; seul à l'écran ~3 s
- Encart : blanc unique, coins arrondis, ombre portée douce vers le bas, ≤ 800 px de large (zone x 140-940)
- Police : Montserrat Bold, noir, centrée ; taille auto : la plus grande entre 40 et 34 qui tient sur 2 lignes, sinon 3 lignes courtes en 38, jamais 4
- Position : y ≈ 1170 px, toujours sous le menton (vérifier l'image à 0,5 s : jamais sur la bouche)
- Lignes équilibrées, coupure après une virgule ; jamais séparer « 72 heures », « 10 000 € », « ne … pas » ; jamais une ligne qui finit sur de/le/la/tu

## Sous-titres
- Helvetica Neue Bold, blanc, MAJUSCULES, mot à mot
- Un bloc sur deux : un mot clé mis en avant, en Didot italique ou en plus gros gras
- Position : sous le menton de la personne qui parle (menton + 165 px, entre y 1150 et 1440), une hauteur par phrase
- Lignes ≤ 700 px (zone sûre Instagram) ; jamais une ligne qui finit sur de/le/la
- Chiffres en chiffres ; nom ou chiffre confidentiel = « *** » + bip

## Plans
- Zoom aux coupes : 1,00 / 1,12 en alternance, seulement sur le plan large ; jamais sur un gros plan
- Même caméra et image continue = même cadrage (pas de micro-saut)
- Plan de moins de 12 images ou morceau de moins de 8 images : figé sur le plan d'avant
- Une cliente qui parle = elle seule à l'écran, sous-titres sous son menton ; deux qui réagissent = écran partagé haut/bas
- Plan par-dessus l'épaule où l'expert n'est qu'un bout de tête flou : cliente seule, fond noir ou blanc

## Habillage
- Transition après le hook : flash orange (light leak) + clic léger, posé sur une pause entre deux phrases, entre 3 et 4,2 s
- Bruitages : clic léger sur le flash, rien d'autre
- Textes animés : aucun
- Nom à l'écran : aucun

## Son
- Voix normalisée à -15 LUFS, son naturel (pas d'isolation de voix)
- Bip : son coupé + bip 1 kHz
- Musique : sans paroles, tendance Instagram, volume 0,07, en boucle jusqu'à la fin
- Chaîne audio terminée par asetpts=N/SR/TB : le son démarre à 0

## Couleurs
- Image telle que tournée (déjà étalonnée, jamais en log) ; LUT si besoin, pas d'étalonnage par Claude

## Fin
- Coupe sèche sur la dernière phrase complète ; pas de carton, pas de CTA vidéo
KIT_FILE_END
if [ ! -x "$KIT/.venv/bin/python" ]; then python3 -m venv "$KIT/.venv"; fi
"$KIT/.venv/bin/pip" install -q --upgrade pip >/dev/null 2>&1 || true
"$KIT/.venv/bin/pip" install -q numpy pillow opencv-python requests
ok "Dossier prêt"
# Raccourci : taper cc dans le Terminal ouvre Claude dans le dossier de montage, sans demandes d'autorisation
grep -q "alias cc=" "$HOME/.zshrc" 2>/dev/null || echo "alias cc='cd ~/Montage-IA 2>/dev/null; claude --dangerously-skip-permissions'" >> "$HOME/.zshrc"
ok "Raccourci cc créé"
# Les skills SAVOIRE (notre méthode et notre style) : installés depuis le GitHub, mis à jour avec la même commande
CL="$(command -v claude || echo "$HOME/.local/bin/claude")"
if [ -x "$CL" ]; then
  "$CL" plugin marketplace add yousseni08-hue/kit-montage-ia-savoire >/dev/null 2>&1 || "$CL" plugin marketplace update savoire >/dev/null 2>&1 || true
  if "$CL" plugin install montage-savoire@savoire >/dev/null 2>&1 || "$CL" plugin update montage-savoire@savoire >/dev/null 2>&1; then
    ok "Skills SAVOIRE installés (méthode + style)"
  else
    echo "  Skills SAVOIRE : à installer dans Claude avec /plugin install montage-savoire --marketplace yousseni08-hue/kit-montage-ia-savoire"
  fi
fi

etape "5/5 Clés API (tape Entrée pour passer, tu pourras relancer plus tard)"
cle() { # cle <NOM> <libellé>
  if grep -q "export $1=" "$HOME/.zshrc" 2>/dev/null; then ok "$1 déjà enregistrée"; return; fi
  printf "Colle ta clé %s puis Entrée : " "$2"
  { read -r -s VAL < /dev/tty; } 2>/dev/null || VAL=""
  echo
  if [ -n "$VAL" ]; then echo "export $1=\"$VAL\"" >> "$HOME/.zshrc"; ok "$1 enregistrée"; else echo "  passée"; fi
}
cle ELEVENLABS_API_KEY "ElevenLabs (elevenlabs.io → Developers → API Keys)"
cle GROQ_API_KEY "Groq (console.groq.com → API Keys, optionnel)"

printf "\n\033[1;32mTerminé.\033[0m Ferme ce Terminal, ouvre-en un nouveau, puis tape :\n\n   cc\n\n"
