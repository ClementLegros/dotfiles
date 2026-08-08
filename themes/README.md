# Thèmes

Bascule de tout l'environnement (Hyprland, kitty, waybar, rofi, nvim, fond
d'écran) d'un thème à l'autre en une commande.

```bash
theme-switch                # thème actif + liste
theme-switch frutiger-aero  # bascule + recharge à chaud
theme-switch -n <nom>       # bascule sans recharger
```

## Principe

Chaque config inclut **en permanence** un fichier sous `themes/current/`, qui
est un symlink vers le thème actif. Changer de thème = repointer le symlink et
signaler aux programmes de relire leur config. Les configs elles-mêmes ne sont
jamais modifiées.

```
themes/
├── bin/theme-switch
├── catppuccin/          ← un dossier = un thème
│   ├── hypr.conf        palette, gaps, bordures, decoration, animations
│   ├── kitty.conf       police, opacité, couleurs
│   ├── waybar.css       feuille de style complète de la barre
│   ├── rofi.rasi        thème autonome (palette inlinée)
│   ├── nvim.lua         setup du plugin + `vim.cmd.colorscheme(...)`
│   └── wallpaper.jpg
└── current -> catppuccin
```

## Qui pointe où

| Fichier | Directive |
|---|---|
| `hypr/hyprland.conf` | `source = ~/.config/themes/current/hypr.conf` |
| `hypr/hyprpaper.conf` | `path = ~/.config/themes/current/wallpaper.jpg` |
| `kitty/kitty.conf` | `include ~/.config/themes/current/kitty.conf` |
| `waybar/style.css` | `@import url("../themes/current/waybar.css")` |
| `rofi/config.rasi` | `@theme "~/.config/themes/current/rofi.rasi"` |
| `nvim/lua/plugins/colorscheme.lua` | `dofile(...)` avec repli sur catppuccin |

## Créer un thème

```bash
cp -r ~/.config/themes/catppuccin ~/.config/themes/mon-theme
# éditer les 5 fichiers, remplacer wallpaper.jpg
theme-switch mon-theme
```

## Frontière visuel / comportement

Les thèmes ne contiennent **que** de l'apparence. Ce qui doit rester stable
d'un thème à l'autre reste dans les configs :

- `hyprland.conf` garde keybinds, monitors, règles de fenêtres, et un bloc
  `general` réduit (`layout`, `resize_on_border`, `allow_tearing`) — Hyprland
  fusionne les deux blocs `general`.
- `waybar/config.jsonc` garde la composition des modules ; seul le style bascule.

## Limites connues

- **nvim** : le thème est lu au démarrage, il faut relancer les instances
  ouvertes. Le *plugin* de colorscheme reste déclaré dans `plugins/init.lua` —
  un thème utilisant une autre colorscheme doit y ajouter son plugin.
- **rofi** : lit son thème à chaque lancement, donc rien à recharger.
- **hyprlock**, **GTK** et **starship.toml** ne sont pas encore thémés.
- Les wallpapers sont versionnés dans git : attention au poids du dépôt si tu
  en accumules beaucoup.

## Revenir en arrière

L'état d'origine est tagué :

```bash
git -C ~/.config diff baseline-catppuccin   # ce qui a changé depuis
git -C ~/.config checkout baseline-catppuccin -- .   # tout restaurer
```
