-- ============================================================
-- treesitter.lua — fast, accurate syntax highlighting & indent
-- ============================================================
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",            -- stable classic API (the `main` branch is a rewrite)
  build = ":TSUpdate",          -- compile/update parsers after install
  event = { "BufReadPost", "BufNewFile" },  -- load when a real file opens
  config = function()
    require("nvim-treesitter.configs").setup({
      -- parsers for your languages (+ essentials)
      ensure_installed = {
        "lua", "vim", "vimdoc", "bash",
        "python",
        "javascript", "typescript", "tsx", "html", "css", "json",
        "kotlin", "java",
        "markdown", "markdown_inline",
      },
      auto_install = true,        -- install missing parsers when you open a new filetype
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
