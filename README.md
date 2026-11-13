# Kit Montage IA — SAVOIRE

Le kit de montage IA du programme SAVOIRE : un installateur pour Mac, les règles de montage, notre méthode, les étapes d'un lot et la bibliothèque d'erreurs.

## Installer

1. Ouvre une nouvelle conversation sur claude.ai.
2. Colle le contenu de [GUIDE-CLAUDE.md](GUIDE-CLAUDE.md).
3. Claude te guide étape par étape, en commençant par installer Claude Code dans ton Terminal (la priorité). Si quelque chose bloque, envoie-lui une capture d’écran.

L'installateur (`install.sh`) installe les outils vidéo, Claude Code, crée le dossier `~/Montage-IA` et le raccourci `cc`. Il se relance sans risque : rien n'est écrasé.

## Monter

Ouvre le Terminal, tape `cc`, puis parle-lui normalement, comme à un monteur. Aucun code à retenir : à la fin de chaque étape, Claude te propose la suivante, tu réponds « oui ».

| Tu lui dis par exemple | Claude fait |
|---|---|
| « Copie le style de ces reels : <liens> » | Écrit la fiche du style |
| « Monte-moi ce rush » | Transcrit et ouvre la page de revue |
| Tu colles tes choix de la page | Écrit les hooks, propose un clip test |
| « C'est bon, lance tout » | Monte tout le lot |
| « Refais le 4 et le 11 : … » | Refait seulement ces clips |
| « Mets-les sur le Drive » | Range et vérifie chaque fichier |
| « Programme-les à partir de lundi » | Descriptions, puis Metricool |
| « On clôt le lot » | Garde tes corrections comme règles |

## Nos skills : la méthode et le style SAVOIRE

Notre méthode (choix des clips, coupes, hooks, habillage, contrôle) et le style des reels SAVOIRE sont des skills Claude. L'installateur les ajoute tout seul. Pour les installer seuls, colle cette ligne dans Claude Code :

```
/plugin install montage-savoire --marketplace yousseni08-hue/kit-montage-ia-savoire
```

Ou dans le Terminal :

```
claude plugin marketplace add yousseni08-hue/kit-montage-ia-savoire && claude plugin install montage-savoire@savoire
```

Quand on améliore la méthode, Claude récupère la mise à jour au début de chaque lot. Sources : [plugin/skills](plugin/skills).

Le détail de chaque étape est dans [ETAPES.md](ETAPES.md), les erreurs à éviter dans [ERREURS.md](ERREURS.md).
