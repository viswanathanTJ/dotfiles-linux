-- ============================================================
-- gitsigns.lua — git add/change/delete marks in the sign column
-- ============================================================
return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("gitsigns").setup({
      signs = {
        add          = { text = "+" },
        change       = { text = "~" },
        delete       = { text = "_" },
        topdelete    = { text = "‾" },
        changedelete = { text = "~" },
      },
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end
        -- navigate hunks
        map("n", "]h", gs.next_hunk, "Next git hunk")
        map("n", "[h", gs.prev_hunk, "Prev git hunk")
        -- actions
        map("n", "<leader>gp", gs.preview_hunk,      "Preview hunk")
        map("n", "<leader>gb", gs.blame_line,        "Blame line")
        map("n", "<leader>gr", gs.reset_hunk,        "Reset hunk")
        map("n", "<leader>gs", gs.stage_hunk,        "Stage hunk")
      end,
    })
  end,
}
