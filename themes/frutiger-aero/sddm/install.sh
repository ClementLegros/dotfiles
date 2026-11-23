#!/usr/bin/env bash
#
# install.sh — installe ce thème SDDM et l'active.
#
# SDDM lit ses thèmes dans /usr/share/sddm/themes, sous l'utilisateur `sddm` :
# il ne peut pas lire /home/optimusprime (700). Le thème doit donc être COPIÉ,
# pas lié. Relancer ce script après toute modification.
#
#   sudo ~/.config/themes/frutiger-aero/sddm/install.sh
#   sudo ~/.config/themes/frutiger-aero/sddm/install.sh --revert   (retour à breeze)

set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NAME="frutiger-aero"
DEST="/usr/share/sddm/themes/$NAME"
CONF="/etc/sddm.conf.d/10-theme.conf"

[[ $EUID -eq 0 ]] || { echo "install.sh : à lancer avec sudo." >&2; exit 1; }

if [[ ${1:-} == --revert ]]; then
    printf '[Theme]\nCurrent=breeze\n' > "$CONF"
    echo "→ thème SDDM : breeze (le dossier $DEST est conservé)"
    exit 0
fi

# Le fond d'écran suit celui du thème : on le resynchronise à chaque install.
cp -f "$SRC/../wallpaper.jpg" "$SRC/backgrounds/wallpaper.jpg"

rm -rf "$DEST"
mkdir -p "$DEST"
cp -r "$SRC"/{Main.qml,Components,icons,backgrounds,metadata.desktop,theme.conf} "$DEST/"
[[ -f "$SRC/preview.png" ]] && cp "$SRC/preview.png" "$DEST/"

chown -R root:root "$DEST"
find "$DEST" -type d -exec chmod 755 {} +
find "$DEST" -type f -exec chmod 644 {} +

# /etc/sddm.conf.d prime sur /etc/sddm.conf : c'est ici qu'il faut écrire.
mkdir -p /etc/sddm.conf.d
printf '[Theme]\nCurrent=%s\n' "$NAME" > "$CONF"

echo "→ thème SDDM : $NAME"
echo "  Aperçu sans redémarrer :  sddm-greeter-qt6 --test-mode --theme $DEST"
