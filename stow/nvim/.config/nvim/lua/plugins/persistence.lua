-- ============================================================
-- persistence.lua — session save/restore (remember open files)
-- ============================================================
return {
  "folke/persistence.nvim",
  lazy = false,             -- load at startup so it can auto-restore + auto-save
  opts = {},                -- defaults: saves a session per working directory
  config = function(_, opts)
    -- Save per-buffer local options (esp. filetype) so EVERY restored buffer
    -- gets syntax/treesitter highlighting, not just the focused one.
    vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

    require("persistence").setup(opts)

    -- Auto-restore the session for this directory ONLY when you launch
    -- `nvim` with no file arguments (e.g. just `nvim`). If you open a
    -- specific file (`nvim foo.lua`), it won't override your intent.
    vim.api.nvim_create_autocmd("VimEnter", {
      nested = true,
      callback = function()
        if vim.fn.argc() == 0 then
          require("persistence").load()
        end
      end,
    })
  end,
  -- Manual controls (in case you want to restore on demand)
  keys = {
    { "<leader>qs", function() require("persistence").load() end,            desc = "Restore session (this dir)" },
    { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
    { "<leader>qd", function() require("persistence").stop() end,            desc = "Don't save this session" },
  },
}
