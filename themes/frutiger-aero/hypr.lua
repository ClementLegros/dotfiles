-- ─── Hyprland — apparence ─── Frutiger Aero ─────────────────────────────────
-- Chargé par ~/.config/hypr/hyprland.lua via themes/current/hypr.lua.
-- Ce fichier ne contient QUE du visuel. Le comportement (layout, keybinds,
-- monitors, règles de fenêtres) reste dans hyprland.lua et ne change pas
-- quand on bascule de thème.

-- ── Palette ──
-- Frutiger Aero = verre + eau + lumière. Les bordures sont des *reflets* :
-- un dégradé qui va du blanc (arête éclairée) à l'aqua (masse d'eau).
local glassHi = "rgba(ffffffee)" -- arête supérieure, lumière directe
local aqua    = "rgba(7fe3f0ff)"
local azure   = "rgba(1e88e5ff)"
local ocean   = "rgba(0b4c8caa)"
local deep    = "rgba(041e3399)" -- ombre : bleu profond, pas du noir

hl.config({
    general = {
        gaps_in  = 6,
        gaps_out = 14,

        border_size = 2,

        col = {
            -- Trois arrêts : blanc → aqua → azure. Lu de haut en bas, c'est
            -- exactement le biseau vitré d'une fenêtre Aero.
            active_border   = { colors = { glassHi, aqua, azure }, angle = 45 },
            inactive_border = ocean,
        },
    },

    decoration = {
        rounding       = 14,
        rounding_power = 2,

        -- Les fenêtres inactives « s'enfoncent » légèrement dans le verre.
        active_opacity   = 1.0,
        inactive_opacity = 0.92,

        shadow = {
            enabled      = true,
            range        = 18,
            render_power = 3,
            -- Une ombre bleutée, pas noire : c'est ce qui fait lire la barre
            -- comme du verre posé sur de l'eau plutôt que comme un panneau opaque.
            color          = deep,
            color_inactive = "rgba(041e3355)",
        },

        blur = {
            enabled = true,
            -- UHD 620 : size 6 / passes 2 est le palier où le flou reste crédible
            -- sans coûter d'images par seconde. Monter à passes 3 si tu branches
            -- un GPU dédié.
            size   = 6,
            passes = 2,

            -- Le cœur du rendu « verre » : on éclaircit et on sature ce qui passe
            -- à travers, au lieu de simplement le brouiller.
            brightness        = 1.15,
            contrast          = 1.05,
            vibrancy          = 0.35,
            vibrancy_darkness = 0.0,
            noise             = 0.015,

            -- xray : les fenêtres floutent le *fond d'écran*, pas les fenêtres
            -- derrière elles. Sans ça, empiler deux fenêtres translucides donne
            -- une bouillie grise au lieu d'un empilement de plaques de verre.
            xray = true,

            popups             = true,
            popups_ignorealpha = 0.2,
        },
    },

    animations = {
        enabled = true,
    },
})

-- ── Flou des layer-surfaces ──
-- waybar / rofi / dunst ne sont pas des fenêtres mais des « layers » : le blur
-- de `decoration` ne les touche pas. Sans ces règles, la barre en dégradé
-- translucide laisse voir le fond d'écran net et perd tout l'effet verre.
hl.layer_rule({
    name  = "blur-bar",
    match = { namespace = "^(waybar)$" },

    blur = true,
    -- En dessous de ce seuil d'opacité, le pixel n'est pas flouté — c'est ce
    -- qui garde les coins arrondis nets au lieu d'un halo rectangulaire.
    ignore_alpha = 0.1,
})

hl.layer_rule({
    name  = "blur-menus",
    match = { namespace = "^(rofi|notifications)$" },

    blur         = true,
    ignore_alpha = 0.3,
})

-- ── Animations ──
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 },   { 0.32, 1 } } })
hl.curve("linear",       { type = "bezier", points = { { 0, 0 },      { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 },  { 0.75, 1 } } })
hl.curve("quick",        { type = "bezier", points = { { 0.15, 0 },   { 0.1, 1 } } })
-- « aero » dépasse la cible puis revient : le rebond élastique des bulles
-- et des fenêtres qui « gonflent » à l'ouverture.
hl.curve("aero",         { type = "bezier", points = { { 0.34, 1.56 }, { 0.64, 1 } } })
hl.curve("ripple",       { type = "bezier", points = { { 0.16, 1 },   { 0.3, 1 } } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,  bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 4,   bezier = "ripple" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.5, bezier = "aero" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.5, bezier = "aero",         style = "popin 80%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 3,   bezier = "easeOutQuint", style = "popin 85%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 2.5, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 2,   bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3,   bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.5, bezier = "aero" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 3.5, bezier = "aero",         style = "slide top" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 2,   bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 2,   bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.5, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 3,   bezier = "ripple",       style = "slidefade 20%" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,   bezier = "quick" })

-- ── Curseur ──
-- Taille alignée sur celle déclarée dans gtk.conf : sans ça les applis GTK et
-- les surfaces natives Wayland affichent deux tailles de curseur différentes.
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
