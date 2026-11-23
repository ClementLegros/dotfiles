-- Configuration Hyprland (Lua).
--
-- Remplace hyprland.conf : Hyprland 0.57 ne lit plus le format hyprlang.
-- Documentation : https://wiki.hypr.land/Configuring/
-- Référence de l'API (complétion dans l'éditeur) : /usr/share/hypr/stubs/hl.meta.lua

local home = os.getenv("HOME")


------------------
---- MONITORS ----
------------------

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})


---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "kitty"
local fileManager = "nemo"
local menu        = "rofi -show drun"
local clipHist    = [[cliphist list | rofi -dmenu -p "󰅇  Presse-papier" | cliphist decode | wl-copy]]
local powerMenu   = "~/.config/hypr/script/power-menu"


-------------------
---- AUTOSTART ----
-------------------

-- Un appel par service. La forme `waybar & hyprpaper` lancerait waybar via un
-- shell d'arrière-plan : Hyprland ne suivrait plus le processus, et un crash
-- de waybar passerait inaperçu.
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    -- Fond d'écran : hyprpaper, ou linux-wallpaperengine si le thème actif
    -- déclare un fond animé (themes/current/wallpaper-engine.conf).
    hl.exec_cmd(home .. "/.config/themes/bin/wallpaper-apply")
    hl.exec_cmd("dunst")
    hl.exec_cmd("hypridle")

    hl.exec_cmd("systemctl --user start hyprpolkitagent")

    -- cliphist : deux watchers, un par type de sélection. Sans le second, copier
    -- une image ne remplit jamais l'historique.
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- La taille du curseur est déclarée par le thème (themes/current/hypr.lua),
-- pour rester cohérente avec gtk.conf. Ici : uniquement ce qui ne change pas
-- d'un thème à l'autre.

-- Force le backend Wayland natif là où la détection automatique échoue encore.
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")
-- Electron ≥ 28 : sans ce hint, VS Code / Discord / Slack tournent en XWayland
-- (flou au scaling, pas de blur derrière eux).
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
-- Qt délègue son thème au portail XDG plutôt qu'à Breeze — c'est ce qui fait
-- suivre Dolphin & co. quand on bascule de thème GTK.
hl.env("QT_QPA_PLATFORMTHEME", "gtk3")


-----------------------
----- PERMISSIONS -----
-----------------------

-- Les changements de permissions demandent un redémarrage de Hyprland.
-- Ces règles ne s'appliquent que si ecosystem.enforce_permissions est activé :
-- hl.config({ ecosystem = { enforce_permissions = true } })

hl.permission({ binary = "/usr/(bin|local/bin)/grim", type = "screencopy", mode = "allow" })
hl.permission({ binary = "/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", type = "screencopy", mode = "allow" })


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Tout l'aspect visuel (palette, gaps, bordures, decoration, animations) vit
-- dans le thème actif. Bascule : `theme-switch <nom>` — voir ~/.config/themes/.
-- dofile et non require : require met le module en cache, et un rechargement
-- après bascule de thème ne relirait pas le fichier.
dofile(home .. "/.config/themes/current/hypr.lua")

-- Comportement de fenêtrage — hors thème, pour rester stable d'un thème à l'autre.
-- hl.config fusionne : ce bloc `general` complète celui du thème.
hl.config({
    general = {
        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        -- hyprpaper couvre l'écran de toute façon : le fond intégré ne sert qu'à
        -- clignoter une fraction de seconde au démarrage.
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,

        -- Une appli qui demande le focus (lien ouvert depuis une autre fenêtre)
        -- l'obtient, au lieu de seulement clignoter dans la barre.
        focus_on_activate = true,
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 = aucune modification.

        touchpad = {
            natural_scroll = true,
        },
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(powerMenu))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd(clipHist))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())          -- dwindle
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))    -- dwindle

-- Déplacer le focus : mainMod + flèches
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Changer de workspace : mainMod + [0-9]
-- Y envoyer la fenêtre active : mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- le workspace 10 est sur la touche 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Workspace spécial (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Parcourir les workspaces existants : mainMod + molette
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Déplacer / redimensionner : mainMod + clic gauche / droit, en glissant
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Touches multimédia : volume et luminosité
local held = { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), held)
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      held)
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     held)
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   held)
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  held)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  held)

-- Captures d'écran — hyprshot enveloppe grim+slurp et gère lui-même le nom de
-- fichier, la copie presse-papier et le gel de l'écran (-z) pendant la
-- sélection : sans gel, une popup ou une animation continue de bouger pendant
-- qu'on trace la zone.
local screenshotDir = "~/Pictures/Screenshots"
hl.bind("Print",         hl.dsp.exec_cmd("hyprshot -z -m region -o " .. screenshotDir))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m output -o " .. screenshotDir))
hl.bind("CTRL + Print",  hl.dsp.exec_cmd("hyprshot -z -m window -o " .. screenshotDir))
-- Annotation : la capture part directement dans satty (flèches, floutage,
-- surlignage) plutôt que dans un fichier qu'il faudrait rouvrir.
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd(
    "hyprshot -z -m region --raw | satty --filename - --output-filename "
    .. screenshotDir .. "/satty-$(date +'%Y%m%d-%H%M%S').png --early-exit --copy-command wl-copy"))

-- Lecture (playerctl)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.window_rule({
    -- Ignore les demandes de maximisation de toutes les applis.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    -- Corrige des problèmes de glisser-déposer avec XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

hl.window_rule({
    -- Popups de la waybar (Wi-Fi, Bluetooth, son) : des applis terminal lancées
    -- par waybar/script/tui, posées sous la barre, à droite.
    name  = "float-tui",
    match = { class = "^tui-float$" },

    float = true,
    size  = "780 520",
    move  = "monitor_w-792 52",
})

hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})
