-- ─── neovim — apparence ─── Frutiger Aero ────────────────────────────────────
-- Chargé par nvim/lua/plugins/colorscheme.lua via themes/current/nvim.lua.
--
-- On reste sur le plugin catppuccin (déjà déclaré dans plugins/init.lua) et on
-- ne remplace que la palette : aucun plugin supplémentaire à installer, donc le
-- dépôt nvim autonome continue de fonctionner tel quel.
--
-- La palette transpose Frutiger Aero sous l'eau : base bleu abyssal, syntaxe en
-- aqua / lime / azur. Les teintes chaudes de mocha (peach, yellow, maroon)
-- deviennent des jaunes filtrés par l'eau plutôt que des oranges terreux.

return {
    flavour = "mocha",

    color_overrides = {
        mocha = {
            -- Fonds : du bleu profond, jamais du gris-violet.
            base     = "#041e33",
            mantle   = "#031624",
            crust    = "#020f19",
            surface0 = "#0a3352",
            surface1 = "#12496f",
            surface2 = "#1d648f",
            overlay0 = "#3d7ba6",
            overlay1 = "#5a97bf",
            overlay2 = "#79b3d6",

            -- Textes : écume.
            text     = "#d8f1ff",
            subtext1 = "#b9e2f5",
            subtext0 = "#9acbe3",

            -- Accents.
            blue      = "#4fc3f7",  -- azur
            sapphire  = "#29a8e0",
            sky       = "#7fe3f0",  -- aqua, la couleur signature
            teal      = "#5ad9d0",
            green     = "#9ede4a",  -- lime Aero
            yellow    = "#ffd24a",
            peach     = "#ffb35c",
            maroon    = "#ff8f7e",
            red       = "#ff6b57",  -- corail
            mauve     = "#b39ef5",
            pink      = "#e8a5e8",
            flamingo  = "#f0c0b8",
            rosewater = "#f5ded8",
            lavender  = "#a5c8ff",
        },
    },
}
