-- ============================================================
-- completion.lua — blink.cmp autocomplete popup
-- ============================================================
return {
  "saghen/blink.cmp",
  version = "1.*",            -- use a release tag → ships a prebuilt matcher binary (no cargo build)
  event = "InsertEnter",
  dependencies = {
    "rafamadriz/friendly-snippets",   -- large ready-made snippet collection
  },
  opts = {
    -- default preset: <C-space> open, <C-y> accept, <C-n>/<C-p> select,
    -- <C-e> hide, <Tab>/<S-Tab> jump snippet placeholders
    keymap = { preset = "default" },
    appearance = { nerd_font_variant = "mono" },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
      menu = { border = "rounded" },
    },
    signature = { enabled = true },   -- show function signature while typing args
  },
  opts_extend = { "sources.default" },
}
