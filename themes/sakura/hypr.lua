-- ─── Hyprland — apparence ─── Sakura ────────────────────────────────────────
-- Chargé par ~/.config/hypr/hyprland.lua via themes/current/hypr.lua.
-- Ce fichier ne contient QUE du visuel. Le comportement (layout, keybinds,
-- monitors, règles de fenêtres) reste dans hyprland.lua et ne change pas
-- quand on bascule de thème.

-- ── Palette ──
-- Sombre et translucide : des plaques brun-noir floutées, et UN accent rouge érable.
-- Pas de dégradé, pas de reflet — la bordure active est un aplat.
local sakura = "rgba(e0604fff)" -- l'accent
local blush  = "rgba(7d443999)" -- fenêtre inactive : le même rouge, éteint
local plum   = "rgba(0d080799)" -- ombre : brun très sombre

hl.config({
    general = {
        gaps_in  = 4,
        gaps_out = 12,

        border_size = 2,

        col = {
            active_border   = sakura,
            inactive_border = blush,
        },
    },

    decoration = {
        rounding       = 8,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 10,
            render_power = 2,
            color          = plum,
            color_inactive = "rgba(0d080755)",
        },

        blur = {
            enabled = true,
            -- C'est le flou qui rend le translucide lisible : sans lui, les
            -- fleurs du fond d'écran passent nettes derrière le texte.
            -- UHD 620 : size 6 / passes 2 est le palier raisonnable.
            size   = 6,
            passes = 2,

            -- < 1 : on ASSOMBRIT ce qui passe à travers les surfaces translucides.
            -- Avec un fond animé clair (rose pâle, blanc), c'est ce qui garde le
            -- texte lisible sans avoir à renoncer à la transparence.
            brightness        = 0.7,
            contrast          = 1.0,
            vibrancy          = 0.15,
            vibrancy_darkness = 0.0,
            noise             = 0.01,

            xray   = false,
            popups = true,
            popups_ignorealpha = 0.2,
        },
    },

    animations = {
        enabled = true,
    },
})

-- ── Flou des layer-surfaces ──
-- waybar / rofi / dunst sont des « layers » : le blur de `decoration` ne les
-- touche pas sans ces règles.
hl.layer_rule({
    name  = "blur-bar",
    match = { namespace = "^(waybar)$" },

    blur         = true,
    ignore_alpha = 0.1,
})

hl.layer_rule({
    name  = "blur-menus",
    match = { namespace = "^(rofi|notifications)$" },

    blur         = true,
    ignore_alpha = 0.3,
})

-- ── Animations ──
-- Courtes et sans rebond : un pétale qui se pose, pas une bulle qui gonfle.
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 },  { 0.32, 1 } } })
hl.curve("linear",       { type = "bezier", points = { { 0, 0 },     { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick",        { type = "bezier", points = { { 0.15, 0 },  { 0.1, 1 } } })
hl.curve("drift",        { type = "bezier", points = { { 0.25, 0.8 }, { 0.3, 1 } } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,  bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 4,   bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 3.5, bezier = "drift" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 3.5, bezier = "drift",        style = "popin 92%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 2,   bezier = "linear",       style = "popin 94%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 2,   bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.5, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3,   bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3,   bezier = "drift" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 3,   bezier = "drift",        style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5, bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.8, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.4, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 2.5, bezier = "drift",        style = "slidefade 10%" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,   bezier = "quick" })

-- ── Curseur ──
-- Taille alignée sur celle déclarée dans gtk.conf.
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
