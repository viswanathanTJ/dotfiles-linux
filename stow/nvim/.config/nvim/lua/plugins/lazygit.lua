-- ============================================================
-- lazygit.lua — full git TUI (commit, stage, branch, merge) in a float
-- Requires the `lazygit` binary on PATH (installed at ~/.local/bin/lazygit)
-- ============================================================
return {
  "kdheepak/lazygit.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = {
    "LazyGit",
    "LazyGitConfig",
    "LazyGitCurrentFile",
    "LazyGitFilter",
    "LazyGitFilterCurrentFile",
  },
  keys = {
    { "<leader>gg", "<cmd>LazyGit<CR>", desc = "Open lazygit" },
  },
}
