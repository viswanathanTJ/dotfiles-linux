-- ============================================================
-- init.lua — entry point
-- ============================================================
vim.g.mapleader = " " -- Space is the <leader>
vim.g.maplocalleader = " " -- and the <localleader>

-- 1. Leader key MUST be set before lazy/plugins load.
-- 2. Bootstrap lazy.nvim (clone it on first run if absent)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath) -- put lazy on the runtime path

-- 3. Load our own config modules (we'll create these next)
require("config.options")
require("config.keymaps")

-- 4. Hand off to lazy: load every spec in lua/plugins/
--    Skipped inside VS Code (vscode-neovim): VS Code already provides the
--    file tree, statusline, LSP, completion and git, and these plugins clash.
if not vim.g.vscode then
	require("lazy").setup("plugins")
end
