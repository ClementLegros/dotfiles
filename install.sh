#!/usr/bin/env bash
#
# install.sh — relie au dépôt les fichiers qui doivent vivre hors de ~/.config.
#
# À lancer une fois après avoir cloné le dépôt dans ~/.config. Sans danger à
# relancer : un lien déjà correct est laissé tel quel, et un fichier existant
# est mis de côté (suffixe .bak-<date>) au lieu d'être écrasé.

set -euo pipefail

# Lien dans $HOME → cible, relative à $HOME. Une ligne par fichier.
LINKS=(
    ".bashrc:.config/bash/bashrc"
    ".local/bin/theme-switch:.config/themes/bin/theme-switch"
)

for entry in "${LINKS[@]}"; do
    link="$HOME/${entry%%:*}"
    target="${entry#*:}"

    if [[ ! -e "$HOME/$target" ]]; then
        echo "  ! $target introuvable dans $HOME — lien ignoré"
        continue
    fi

    if [[ -L $link && $(readlink -f "$link") == "$(readlink -f "$HOME/$target")" ]]; then
        echo "  ✓ ${link/#$HOME/\~} (déjà en place)"
        continue
    fi

    if [[ -e $link || -L $link ]]; then
        backup="$link.bak-$(date +%Y%m%d-%H%M%S)"
        mv "$link" "$backup"
        echo "  → ancien ${link/#$HOME/\~} sauvegardé : ${backup/#$HOME/\~}"
    fi

    mkdir -p "$(dirname "$link")"
    ln -s "$HOME/$target" "$link"
    echo "  ✓ ${link/#$HOME/\~} → $target"
done
