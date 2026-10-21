# NEON RIFT

Jeu de survie en arène 2D : élimine des drones, survis à des vagues infinies et améliore ton personnage. Première version jouable solo, dessinée avec des formes et des effets lumineux sans assets externes.

## Jouer immédiatement

Télécharger `Neon-Rift.html`, puis ouvrir le fichier téléchargé dans Chrome, Edge ou Firefox. Cette version autonome contient le jeu, ses règles et sa mise en forme.

## Jouer sous Windows

**Navigateur** (Python 3 requis) : décompresser le projet, ouvrir un terminal dans ce dossier puis exécuter :

```powershell
python tools/build.py
python -m http.server 8000 --bind 127.0.0.1
```

Ouvrir http://localhost:8000/web/ dans Chrome, Firefox ou Edge. On peut aussi ouvrir directement `web/index.html`, car les règles générées sont incluses. Les restrictions du navigateur peuvent désactiver la sauvegarde du record avec une URL locale.

**Version PC Lua** : installer [LÖVE 11.4 ou ultérieur](https://love2d.org), puis glisser le dossier du jeu ou `dist/neon-rift.love` sur `love.exe`. Si LÖVE est dans le PATH, exécuter `love .` dans ce dossier.

Linux / macOS : `bash run.sh` pour le navigateur ou `bash run.sh desktop` pour Lua. Windows : `powershell -ExecutionPolicy Bypass -File run.ps1` (ajouter `-Mode desktop` pour Lua).

## Commandes

| Action | Commande |
| --- | --- |
| Bouger | ZQSD, WASD ou flèches |
| Viser / tirer | Souris / clic gauche maintenu |
| Dash invulnérable | Espace + déplacement |
| Pause / reprendre | Échap |
| Amélioration | Touches 1, 2, 3 ou boutons web |
| Commencer / recommencer | Entrée |

Après chaque vague : cadence améliorée, dégâts augmentés, ou soin et vitesse. Le record est conservé localement. Le son synthétique est optionnel dans la version navigateur ; la version Lua est silencieuse. Jeu conçu pour clavier et souris, sans commandes tactiles.

## Langages et rôles

| Langage | Utilisation réelle |
| --- | --- |
| Lua | Jeu PC complet, règles et tests |
| JavaScript | Jeu navigateur Canvas, audio et sauvegarde locale |
| HTML | Structure de la page et commandes |
| CSS | Interface responsive et thème néon |
| Python | Génération des règles web et archives de distribution |
| Bash | Lanceur Linux / macOS |
| PowerShell | Lanceur Windows |

`rules.lua` est la source des constantes communes. Exécuter `python tools/build.py` après chaque modification. Les deux moteurs sont indépendants : les nouvelles mécaniques doivent être implémentées dans `main.lua` et `web/game.js`.

## Vérifier et distribuer

```bash
python tools/build.py
lua tests/rules_test.lua
luac -p main.lua conf.lua rules.lua
node --check web/game.js
```

GitHub Actions vérifie les sources et produit les archives à chaque push. `dist/neon-rift.love` nécessite LÖVE installé : ce n'est pas un exécutable autonome Windows.

## Dépôt

Sources : https://github.com/Steven111602/neon-rift
