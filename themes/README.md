# Thèmes

Bascule de tout l'environnement (Hyprland, hyprlock, kitty, waybar, rofi,
dunst, GTK, nvim, curseur, fond d'écran) d'un thème à l'autre en une commande.

```bash
theme-switch                # thème actif + liste
theme-switch frutiger-aero  # bascule + recharge à chaud
theme-switch catppuccin     # retour au thème sombre
theme-switch sakura         # sombre et translucide, fleurs de cerisier
theme-switch -n <nom>       # bascule sans recharger (--no-reload)
```

## Principe

Chaque config inclut **en permanence** un fichier sous `themes/current/`, qui
est un symlink vers le thème actif. Changer de thème = repointer le symlink et
signaler aux programmes de relire leur config. Les configs elles-mêmes ne sont
jamais modifiées.

```
themes/
├── bin/theme-switch
├── frutiger-aero/       ← un dossier = un thème
│   ├── hypr.lua         palette, gaps, bordures, decoration, blur, layerrules, animations
│   ├── hyprlock.conf    écran de verrouillage (fond, champ de saisie, horloge)
│   ├── kitty.conf       police, opacité, palette 16 couleurs
│   ├── waybar.css       feuille de style complète de la barre
│   ├── rofi.rasi        thème autonome (palette inlinée)
│   ├── dunstrc          couleurs/police des notifications (drop-in)
│   ├── gtk.conf         thème GTK, icônes, curseur, polices
│   ├── starship.toml    la table [palettes.theme] du prompt, rien d'autre
│   ├── firefox.css      userChrome (barre d'onglets, URL, menus)
│   ├── spicetify.conf   quel thème Spotify sélectionner
│   ├── spicetify/       le thème Spotify lui-même (color.ini + user.css)
│   ├── sddm/            écran de connexion (thème SDDM ; installation `sudo`)
│   ├── nvim.lua         setup du plugin + `vim.cmd.colorscheme(...)`
│   ├── wallpaper.jpg
│   └── wallpaper-engine.conf   (optionnel) fond animé Wallpaper Engine
├── catppuccin/
├── sakura/
└── current -> frutiger-aero
```

## Qui pointe où

Deux mécanismes selon ce que le programme sait faire.

**Ceux qui savent suivre un symlink** — le fichier du thème est inclus
directement, rien à générer :

| Fichier | Directive |
|---|---|
| `hypr/hyprland.lua` | `dofile(home .. "/.config/themes/current/hypr.lua")` |
| `hypr/hyprlock.conf` | `source = ~/.config/themes/current/hyprlock.conf` |
| `hypr/hyprpaper.conf` | `path = ~/.config/themes/current/wallpaper.jpg` |
| `kitty/kitty.conf` | `include ~/.config/themes/current/kitty.conf` |
| `waybar/style.css` | `@import url("../themes/current/waybar.css")` |
| `rofi/config.rasi` | `@theme "~/.config/themes/current/rofi.rasi"` |
| `nvim/lua/plugins/colorscheme.lua` | `dofile(...)` avec repli sur catppuccin |

**Ceux qui ne savent pas** — `theme-switch` fait le pont :

| Cible | Comment |
|---|---|
| dunst | pas d'`include`, mais un dossier de drop-ins : symlink vers `dunstrc.d/50-theme.conf`, appliqué après le `dunstrc` principal |
| GTK 3 / 4 | `gtk.conf` est *dérivé* en `gtk-3.0/settings.ini` et `gtk-4.0/settings.ini` (fichiers **générés**, ne pas éditer) |
| GTK 4 / libadwaita | ignore `settings.ini` pour le thème : `gtk-4.0/gtk.css` est symlinké vers celui du thème, et les clés sont aussi poussées dans `gsettings` |
| starship | pas d'`include` non plus : `starship.toml` est **généré** par concaténation de `starship/base.toml` (structure) et de la palette du thème |
| Firefox | le `chrome/userChrome.css` du profil est un simple `@import` vers `themes/current/firefox.css` — donc rien à faire à la bascule, mais Firefox ne relit cette feuille qu'au démarrage |
| Spotify | spicetify ne lit pas un thème à la volée, il **réécrit les fichiers de Spotify** : theme-switch symlinke `themes/current/spicetify/` dans `~/.config/spicetify/Themes/`, pousse la config, puis lance `apply` |
| fond d'écran | `bin/wallpaper-apply` : hyprpaper par défaut, `linux-wallpaperengine` si le thème le demande — voir « Fond d'écran animé » |
| curseur | `gsettings`, `~/.icons/default/index.theme` et `hyprctl setcursor` — les trois sont nécessaires, chaque type de client lit une source différente |
| SDDM | **hors de portée de `theme-switch`** : les fichiers appartiennent à root. Voir « L'écran de connexion » plus bas |

`theme-switch` vérifie que le thème GTK, le thème d'icônes, le curseur et la
police déclarés existent réellement, et retombe sur Adwaita / Noto Sans en le
signalant. Sans ce contrôle, GTK retombe *silencieusement* sur Adwaita et on
cherche longtemps pourquoi « le thème ne s'applique pas ».

## Créer un thème

```bash
cp -r ~/.config/themes/catppuccin ~/.config/themes/mon-theme
# éditer les 9 fichiers, remplacer wallpaper.jpg
theme-switch mon-theme
```

### Fond d'écran animé (Wallpaper Engine)

Optionnel, par thème. `bin/wallpaper-apply` (appelé par `theme-switch` et au
démarrage de la session) lit `themes/current/wallpaper-engine.conf` :

```ini
bg=1845706469      # identifiant Steam Workshop, ou chemin d'un dossier de fond
fps=24
scaling=fill
```

Si `bg` est renseigné **et** que `linux-wallpaperengine` est installé, le fond
animé remplace hyprpaper. Dans tous les autres cas — pas de conf, `bg`
commenté, binaire absent, moteur qui s'arrête au démarrage — c'est
`wallpaper.jpg` qui est affiché. `wallpaper.jpg` reste donc obligatoire, et
sert de toute façon à hyprlock.

Prérequis, à faire une fois :

1. posséder Wallpaper Engine sur Steam et l'installer (`steam`, en activant
   Proton pour ce titre : l'appli elle-même n'a pas à tourner, seuls ses
   `assets` et les fonds téléchargés du Workshop sont lus) ;
2. `yay -S linux-wallpaperengine-git` ;
3. s'abonner à un fond dans le Workshop, reporter son identifiant dans `bg=`.

Le moteur est une réimplémentation OpenGL libre, pas le logiciel officiel :
tous les fonds ne fonctionnent pas (les fonds « scène » simples et les vidéos
passent le mieux). Journal : `~/.cache/wallpaper-engine.log`. Sur le GPU
intégré de cette machine, `fps` est le réglage qui décide de l'autonomie.

### L'écran de connexion (SDDM)

`frutiger-aero/sddm/` est un thème SDDM complet (QML/Qt6) accordé à hyprlock et
à waybar : fond d'écran flouté et *éclairci*, plaque de verre à cassure nette,
bulles montantes, pilule de saisie bleue à liseré blanc, billes d'alimentation.

Il ne peut pas suivre le symlink `current/`, pour deux raisons :

- le greeter tourne sous l'utilisateur `sddm`, qui ne peut pas lire
  `/home/optimusprime` (mode 700) — d'où la copie du fond d'écran dans
  `sddm/backgrounds/` ;
- `/usr/share/sddm/themes` appartient à root, donc `theme-switch` (qui tourne
  sans privilèges) ne peut ni installer ni basculer quoi que ce soit.

```bash
sudo ~/.config/themes/frutiger-aero/sddm/install.sh            # installe + active
sudo ~/.config/themes/frutiger-aero/sddm/install.sh --revert   # retour à breeze
sddm-greeter-qt6 --test-mode --theme ~/.config/themes/frutiger-aero/sddm  # aperçu
```

Relancer `install.sh` après **toute** modification : le système lit la copie,
pas la source. Le thème actif se lit dans `/etc/sddm.conf.d/10-theme.conf`, qui
prime sur `/etc/sddm.conf`.

### Le prompt starship

`starship/base.toml` porte la structure (format, modules, symboles) et déclare
`palette = 'theme'`. Le thème ne fournit qu'une table `[palettes.theme]` avec
dix rôles :

| Rôle | Où |
|---|---|
| `seg1` … `seg6` | fonds des six segments powerline, de gauche à droite |
| `segfg` | texte posé sur ces segments — **un seul**, donc les six fonds doivent partager le même niveau de clarté |
| `ok` / `err` / `alt` | caractère de prompt et modes vim — posés sur le fond du terminal, pas sur un segment : il leur faut des valeurs vives |

L'ordre de concaténation n'est pas arbitraire : en TOML une clé de premier
niveau (`palette = 'theme'`) ne peut pas suivre un en-tête de table. La
structure doit donc venir en premier, la palette en dernier.

### Firefox

Le `userChrome.css` du profil ne contient qu'un `@import` vers le thème. Deux
conditions, faciles à oublier :

- `toolkit.legacyUserProfileCustomizations.stylesheets` doit valoir `true`,
  sinon Firefox ignore **silencieusement** le fichier. C'est le rôle du
  `user.js` déposé dans le profil.
- le chemin de l'`@import` est **absolu** : Firefox résout les imports d'un
  userChrome relativement au dossier `chrome/` du profil.

Et deux règles CSS faciles à violer :

- l'`@import` doit précéder **toute** règle de style. Une seule déclaration
  avant lui et il est invalide — silencieusement, comme toujours en CSS ;
- le thème Firefox actif est une *extension*, pas une feuille de style : elle
  ne pose pas de règles que `!important` pourrait battre, elle redéfinit les
  variables `--toolbar-field-*`, `--lwt-*`, `--arrowpanel-*` que le chrome
  consomme ensuite. `firefox.css` les réécrit donc explicitement — sans ça, la
  barre d'adresse reste aux couleurs de l'extension au milieu d'une barre
  claire.

### Spotify

`spicetify.conf` déclare `theme=` et `color_scheme=`. Deux cas :

- le thème fournit son propre dossier `spicetify/` (frutiger-aero) → il est
  symlinké dans `~/.config/spicetify/Themes/` sous ce nom ;
- il désigne un thème déjà installé via le marketplace (catppuccin) → il est
  seulement sélectionné.

Les sélecteurs de `spicetify/user.css` s'appuient sur `[data-encore-id]` (le
design-system de Spotify, stable par vocation) et `[data-testid]`, jamais sur
les classes hachées du genre `.dF0nNv60L70DYyvz` : celles-ci sont régénérées à
chaque build et cassent un thème sans le moindre message d'erreur.

## Frontière visuel / comportement

Les thèmes ne contiennent **que** de l'apparence. Ce qui doit rester stable
d'un thème à l'autre reste dans les configs :

- `hyprland.lua` garde keybinds, monitors, règles de fenêtres, variables
  d'environnement, et un bloc `general` réduit (`layout`, `resize_on_border`,
  `allow_tearing`) — `hl.config` fusionne les deux blocs `general`.
- `hyprlock.conf` garde son bloc `general` (comportement du verrouillage).
- `dunst/dunstrc` garde la géométrie, les timeouts et le comportement souris.
- `waybar/config.jsonc` garde la composition des modules ; seul le style bascule.

## Dépendances des thèmes

`frutiger-aero` suppose installés :

- thème GTK `diinki-aero` et icônes `crystal-remix-icon-theme-diinki-version`
  dans `~/.themes` / `~/.local/share/icons`
  (source : <https://github.com/diinki/diinki-aero>, MIT) ;
- `inter-font` (repli automatique sur Noto Sans sinon) ;
- curseur `Bibata-Modern-Ice` (AUR `bibata-cursor-theme-bin`, repli Adwaita).

`sakura` ne dépend que de paquets déjà présents (Adwaita, `papirus-icon-theme`,
`inter-font`). Son `wallpaper.jpg` est dessiné par programme (pycairo), donc
libre de droits. Le thème est sombre et **translucide** : sa lisibilité repose
sur le flou d'Hyprland (`decoration.blur` et les `layer_rule` de son `hypr.lua`).

`wallpaper-archpool.jpg` est un fond alternatif du même jeu : le renommer en
`wallpaper.jpg` pour l'utiliser.

## Limites connues

- **nvim** : le thème est lu au démarrage, il faut relancer les instances
  ouvertes. Le *plugin* de colorscheme reste déclaré dans `plugins/init.lua` —
  `frutiger-aero` s'en accommode en ne surchargeant que la palette de
  catppuccin (`color_overrides`), donc aucun plugin à ajouter.
- **rofi** et **hyprlock** lisent leur thème à chaque lancement — rien à
  recharger.
- **Applis GTK déjà ouvertes** : elles ne relisent pas `settings.ini`. Les
  relancer.
- **starship** relit sa config à chaque prompt : le changement est visible dès
  le prochain Entrée, y compris dans les shells déjà ouverts.
- **Firefox** doit être redémarré : il lit `userChrome.css` une seule fois.
- `userChrome.css` ne touche que le *chrome* (barre d'onglets, menus). La zone
  de contenu — page « Nouvel onglet », `about:preferences` — suit le thème
  Firefox actif. Le mettre sur **Système** dans Modules et thèmes → Thèmes le
  fait suivre GTK, donc `theme-switch`.
- Le `chrome/userChrome.css` et le `user.js` vivent dans le *profil* Firefox
  (`~/.config/mozilla/firefox/<profil>/`), qui n'est pas versionné — c'est un
  dossier plein d'état (cookies, bases sqlite). Sur une nouvelle machine, il
  faut donc les recréer à la main ; seul `themes/*/firefox.css` suit le dépôt.
- **Spotify** doit être redémarré. Et quand `spotify-launcher` a mis Spotify à
  jour, le backup de spicetify devient périmé : `spicetify apply` affiche alors
  « Spotify client is in stock state », ne fait rien, et sort quand même en
  code 0. `theme-switch` détecte ce cas sur la sortie (pas sur le code de
  retour) et enchaîne automatiquement sur `spicetify backup apply`.
- Les variantes catppuccin frappe / latte / macchiato, qui dormaient dans
  l'ancien `starship.toml` sans être utilisées, ont été retirées. Elles restent
  récupérables dans git (`git show baseline-catppuccin:starship.toml`).
- Les wallpapers sont versionnés dans git : attention au poids du dépôt si tu
  en accumules beaucoup.

## Revenir en arrière

```bash
theme-switch catppuccin              # simple bascule
git -C ~/.config diff baseline-catppuccin        # ce qui a changé depuis
git -C ~/.config checkout baseline-catppuccin -- .   # tout restaurer
```
