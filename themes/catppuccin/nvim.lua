require("catppuccin").setup({
    flavour = "mocha",
    transparent_background = true,
    term_colors = true,
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
