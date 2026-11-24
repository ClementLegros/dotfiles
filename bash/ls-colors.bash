# Couleurs de `ls` (et de tout ce qui lit LS_COLORS : tree, fd, complétion…)
# tirées du thème actif. Sourcé par bashrc.
#
# Le thème fournit ~/.config/themes/current/ls.conf : des lignes rôle=#rrggbb.
# Ce fichier porte le reste — quel rôle s'applique à quel type de fichier ou à
# quelle extension — pour que ces listes n'existent qu'à un seul endroit.
#
# Un rôle absent du thème n'est pas émis : ls retombe alors sur sa couleur
# par défaut pour ce type. Sans ls.conf du tout, on garde les réglages de
# `dircolors`.

_ls_theme() {
    local conf=~/.config/themes/current/ls.conf

    # Appelée à chaque prompt : ne rien refaire tant que le symlink `current`
    # pointe sur le même fichier (-ef compare les inodes, sans fork).
    if [[ ! -f $conf ]]; then
        [[ ${_LS_THEME_SRC-} == none ]] && return
        _LS_THEME_SRC=none
        eval "$(dircolors -b)"
        return
    fi
    [[ -n ${_LS_THEME_SRC-} && $conf -ef $_LS_THEME_SRC ]] && return
    _LS_THEME_SRC=$(realpath "$conf")

    # rôle=#rrggbb → séquence truecolor « 38;2;r;g;b »
    local -A c=()
    local k v
    while IFS='=' read -r k v; do
        v=${v%%[[:space:]]*}
        [[ $k =~ ^[a-z]+$ && $v =~ ^#[0-9a-fA-F]{6}$ ]] || continue
        c[$k]="38;2;$((16#${v:1:2}));$((16#${v:3:2}));$((16#${v:5:2}))"
    done < "$conf"

    # rôle : style : clés LS_COLORS (types de fichiers)
    local types=(
        "dir:1:di tw ow st"          # tw/ow/st : sans les fonds verts par défaut
        "link::ln"
        "exec:1:ex"
        "special::pi so bd cd do"    # tubes, sockets, périphériques
        "broken:1:or mi su sg"       # liens cassés, setuid/setgid
    )
    # rôle : style : extensions
    local exts=(
        "archive::tar tgz tbz2 txz gz bz2 xz zst lz4 zip 7z rar jar deb rpm iso img pkg"
        "image::png jpg jpeg gif bmp webp svg ico tif tiff avif heic xcf kra"
        "media::mp4 mkv webm mov avi m4v flv mp3 flac ogg opus wav m4a aac"
        "doc::pdf md txt rst org tex odt ods odp docx xlsx pptx epub"
        "muted::bak old orig tmp swp log lock pyc o"
    )

    local out="" spec role style list item
    for spec in "${types[@]}"; do
        IFS=: read -r role style list <<< "$spec"
        [[ -n ${c[$role]-} ]] || continue
        for item in $list; do out+="$item=${style:+$style;}${c[$role]}:"; done
    done
    for spec in "${exts[@]}"; do
        IFS=: read -r role style list <<< "$spec"
        [[ -n ${c[$role]-} ]] || continue
        for item in $list; do out+="*.$item=${style:+$style;}${c[$role]}:"; done
    done
    [[ -n ${c[muted]-} ]] && out+="*~=${c[muted]}:"

    export LS_COLORS=${out%:}
}

_ls_theme
