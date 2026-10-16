-- ============================================================
-- conform.lua — formatting (on save + manual)
-- ============================================================
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>cf",
      function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
      desc = "Format buffer",
    },
  },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "ruff_format" },
      javascript = { "prettier" },
      typescript = { "prettier" },
      javascriptreact = { "prettier" },
      typescriptreact = { "prettier" },
      html = { "prettier" },
      css = { "prettier" },
      json = { "prettier" },
      markdown = { "prettier" },
      -- kotlin/java: no formatter here — LSP fallback handles them
    },
    format_on_save = {
      timeout_ms = 500,
      lsp_format = "fallback",   -- use the LSP formatter if no dedicated one is set
    },
  },
}
