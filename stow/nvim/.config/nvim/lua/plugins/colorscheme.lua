-- ============================================================
-- colorscheme.lua — Catppuccin (Mocha), matches your tmux
-- ============================================================
return {
	"catppuccin/nvim",
	name = "catppuccin", -- override the default name (the repo is just "nvim")
	priority = 1000, -- load before everything else
	lazy = false, -- load on startup
	config = function()
		require("catppuccin").setup({
			flavour = "mocha", -- latte / frappe / macchiato / mocha
			integrations = { -- let catppuccin theme our other plugins
				treesitter = true,
				telescope = true,
				neotree = true,
				gitsigns = true,
				native_lsp = { enabled = true },
				cmp = true, -- blink.cmp uses cmp highlight groups
			},
		})
		vim.cmd.colorscheme("catppuccin") -- activate it
	end,
}
