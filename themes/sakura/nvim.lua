-- ─── neovim — apparence ─── Sakura ───────────────────────────────────────────
-- Chargé par nvim/lua/plugins/colorscheme.lua via themes/current/nvim.lua.
--
-- Même principe que frutiger-aero : on garde le plugin catppuccin (mocha) et
-- on ne remplace que la palette. Le fond reste transparent : c'est celui de
-- kitty, translucide, qui se voit.

require("catppuccin").setup({
    flavour = "mocha",
    transparent_background = true,
    term_colors = true,

    color_overrides = {
        mocha = {
            -- Fonds : brun-noir chaud, jamais du gris-bleu.
            base     = "#1f1513",
            mantle   = "#1a110f",
            crust    = "#140c0b",
            surface0 = "#2b1d1a",
            surface1 = "#3a2824",
            surface2 = "#4d3731",
            overlay0 = "#6e5952",
            overlay1 = "#8c746c",
            overlay2 = "#a8918a",

            -- Textes : blanc rosé.
            text     = "#f5e6e0",
            subtext1 = "#e5d2cb",
            subtext0 = "#cbb5ad",

            -- Accents.
            pink      = "#f5bfae",
            mauve     = "#e0604f",  -- mots-clés : la couleur signature
            red       = "#ff6b7a",
            maroon    = "#f08a80",
            flamingo  = "#f2c4b8",
            rosewater = "#f8e0d8",
            peach     = "#f0a880",
            yellow    = "#e0b872",
            green     = "#9fc79a",
            teal      = "#7fc4c4",
            sky       = "#8fd0dc",
            sapphire  = "#7ab8d8",
            blue      = "#8fb4dc",
            lavender  = "#c8a2e0",
        },
    },

    integrations = {
        blink_cmp = true,
        telescope = { enabled = true },
        mason = true,
        native_lsp = {
            enabled = true,
            virtual_text = {
                errors = { "italic" },
                hints = { "italic" },
                warnings = { "italic" },
                information = { "italic" },
            },
            underlines = {
                errors = { "underline" },
                hints = { "underline" },
                warnings = { "underline" },
                information = { "underline" },
            },
        },
    },
})

vim.cmd.colorscheme("catppuccin")
