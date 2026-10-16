-- ============================================================
-- lualine.lua — statusline (mode, file, git, diagnostics, position)
-- ============================================================
return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",               -- load after startup (UI, not critical-path)
  config = function()
    require("lualine").setup({
      options = {
        theme = "auto",             -- auto-detects catppuccin; never errors on load order
        globalstatus = true,        -- one statusline for all splits
        section_separators = "",
        component_separators = "|",
      },
    })
  end,
}
