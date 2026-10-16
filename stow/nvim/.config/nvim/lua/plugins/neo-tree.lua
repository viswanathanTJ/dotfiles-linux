-- ============================================================
-- neo-tree.lua — file explorer sidebar
-- ============================================================
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",           -- UI component library neo-tree needs
  },
  cmd = "Neotree",
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "Toggle file explorer" },
  },
  config = function()
    require("neo-tree").setup({
      close_if_last_window = true,    -- close nvim if neo-tree is the last window
      filesystem = {
        follow_current_file = { enabled = true },  -- highlight the file you're editing
        use_libuv_file_watcher = true,             -- auto-refresh on disk changes
        filtered_items = { hide_dotfiles = false, hide_gitignored = false },
      },
      window = {
        width = 32,
        mappings = {
          ["<space>"] = "none",       -- free up Space (it's our leader)
        },
      },
    })
  end,
}
