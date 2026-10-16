-- ============================================================
-- lsp.lua — the IDE brain: Mason + LSP servers + keymaps
-- ============================================================
return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "mason-org/mason.nvim",                  -- installs language servers/tools
    "mason-org/mason-lspconfig.nvim",        -- bridges Mason <-> lspconfig
    "WhoIsSethDaniel/mason-tool-installer.nvim", -- also installs formatters
    "saghen/blink.cmp",                      -- completion (for capabilities)
  },
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    -- LSP servers to ensure installed (your four languages)
    local servers = {
      "lua_ls",                 -- Lua
      "basedpyright",           -- Python
      "ts_ls", "html", "cssls", "jsonls",  -- JS/TS + web
      "kotlin_language_server", "jdtls",   -- Kotlin / Java
    }

    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = servers,
    })
    -- formatters (used by conform.lua) — installed via Mason too
    require("mason-tool-installer").setup({
      ensure_installed = { "stylua", "prettier", "ruff" },
    })

    -- Completion capabilities advertised to servers (blink.cmp augments these)
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local ok, blink = pcall(require, "blink.cmp")
    if ok then
      capabilities = blink.get_lsp_capabilities(capabilities)
    end
    vim.lsp.config("*", { capabilities = capabilities })  -- default for every server

    -- Per-server tweak: tell lua_ls that `vim` is a known global
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          workspace = { checkThirdParty = false },
        },
      },
    })

    -- Diagnostics appearance
    vim.diagnostic.config({
      virtual_text = true,
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
    })

    -- Keymaps that activate only once a language server attaches to a buffer
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(ev)
        local function map(keys, fn, desc)
          vim.keymap.set("n", keys, fn, { buffer = ev.buf, desc = desc })
        end
        -- Telescope pickers: floating list that auto-closes on selection
        map("gd", "<cmd>Telescope lsp_definitions<CR>",     "Go to definition")
        map("gr", "<cmd>Telescope lsp_references<CR>",       "References")
        map("gi", "<cmd>Telescope lsp_implementations<CR>",  "Go to implementation")
        map("K",  vim.lsp.buf.hover,          "Hover docs")
        map("<leader>rn", vim.lsp.buf.rename,      "Rename symbol")
        map("<leader>ca", vim.lsp.buf.code_action, "Code action")
        map("<leader>d",  vim.diagnostic.open_float, "Line diagnostics")
        map("[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev diagnostic")
        map("]d", function() vim.diagnostic.jump({ count = 1,  float = true }) end, "Next diagnostic")
      end,
    })
  end,
}
