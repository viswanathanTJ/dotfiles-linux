-- ============================================================
-- telescope.lua — fuzzy finder (files, grep, buffers, help…)
-- ============================================================
return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",          -- required Lua utility library
    "nvim-tree/nvim-web-devicons",    -- file-type icons
  },
  cmd = "Telescope",                  -- load when :Telescope is used...
  keys = {                            -- ...or when one of these is pressed
    { "<leader>ff", "<cmd>Telescope find_files<CR>",  desc = "Find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<CR>",   desc = "Live grep (search text)" },
    { "<leader>fb", "<cmd>Telescope buffers<CR>",     desc = "Find open buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<CR>",   desc = "Find help tags" },
    { "<leader>fr", "<cmd>Telescope oldfiles<CR>",    desc = "Recent files" },
  },
  config = function()
    require("telescope").setup({
      defaults = {
        mappings = {
          i = { ["<C-j>"] = "move_selection_next", ["<C-k>"] = "move_selection_previous" },
        },
      },
    })
  end,
}
