-- ============================================================
-- editor.lua — quality-of-life: which-key + autopairs
-- ============================================================
return {
  -- Popup that shows available keybindings as you type a prefix (e.g. <leader>)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      delay = 400,   -- ms before the popup appears
    },
  },

  -- Auto-close brackets/quotes: type ( and get () with the cursor inside
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = { map_bs = false },   -- Backspace deletes only one char, not the pair
  },
}
