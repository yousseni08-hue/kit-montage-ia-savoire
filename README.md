# Kit Montage IA — SAVOIRE

Le kit de montage IA du programme SAVOIRE : un installateur pour Mac, les règles de montage, les raccourcis (P0 à P10, STYLE) et la bibliothèque d'erreurs.

## Installer

1. Ouvre une nouvelle conversation sur claude.ai.
2. Colle le contenu de [GUIDE-CLAUDE.md](GUIDE-CLAUDE.md).
3. Claude te guide étape par étape, en commençant par installer Claude Code dans ton Terminal (la priorité). Si quelque chose bloque, envoie-lui une capture d’écran.

L'installateur (`install.sh`) installe les outils vidéo, Claude Code, crée le dossier `~/Montage-IA` et le raccourci `cc`. Il se relance sans risque : rien n'est écrasé.

## Monter

Ouvre le Terminal, tape `cc`, puis les raccourcis :

| Raccourci | Ce que fait Claude |
|---|---|
| STYLE | Copie un style de montage à partir de liens |
| P0 | Construit ton moteur de montage, une fois |
| P1 | Crée le projet et transcrit le rush |
| P2 | Ouvre la page de revue des clips |
| P3 | Écrit un hook par clip |
| P4 | Monte le clip test |
| P5 | Monte tout le lot |
| P6 | Refait les clips signalés |
| P7 | Range les reels dans le Drive |
| P8 | Écrit les descriptions |
| P9 | Programme dans Metricool |
| P10 | Clôt le lot et garde tes corrections |

## Notre méthode

[METHODE.md](METHODE.md) : comment on choisit les clips, comment on coupe, comment on écrit les hooks, l'habillage, le contrôle et le rangement. Claude la lit avant chaque montage.

Tu veux le même rendu que les reels SAVOIRE ? La fiche [styles/savoire-audit.md](styles/savoire-audit.md) est prête, tu peux la reprendre telle quelle ou l'adapter.

Les consignes complètes sont dans [PROMPTS.md](PROMPTS.md), les erreurs à éviter dans [ERREURS.md](ERREURS.md).
