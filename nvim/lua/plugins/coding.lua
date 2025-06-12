return {
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        trigger = {

          prefetch_on_insert = true,

          show_in_snippet = true,

          show_on_keyword = true,

          show_on_trigger_character = false,

          show_on_blocked_trigger_characters = { " ", "\n", "\t" },

          show_on_accept_on_trigger_character = true,

          show_on_insert_on_trigger_character = true,

          show_on_x_blocked_trigger_characters = { "'", '"', "(" },
        },
      },
    },
  },
}
