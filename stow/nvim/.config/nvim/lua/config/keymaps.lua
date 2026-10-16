-- ============================================================
-- keymaps.lua — general (non-plugin) keybindings
-- Leader is set in init.lua (Space)
-- ============================================================
local map = vim.keymap.set

-- Escape insert mode with jj (your existing one, kept)
map("i", "jj", "<Esc>", { desc = "Exit insert mode" })

-- Clear search highlight with Esc in normal mode
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Quick file ops
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit window" })
map("n", "<leader>Q", "<cmd>qa!<CR>", { desc = "Quit all (force)" })

-- Window navigation (Ctrl + h/j/k/l) — like your tmux pane nav
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Window splits (mirrors your tmux s/v feel)
map("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Split vertical" })
map("n", "<leader>sh", "<cmd>split<CR>", { desc = "Split horizontal" })

-- Resize windows with arrows
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Grow height" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Shrink height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Shrink width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Grow width" })

-- Buffer navigation (buffers = open files)
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })
map("n", "<leader>zq", "<cmd>bdelete<CR>", { desc = "Close buffer" })

-- Move selected lines up/down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep cursor centered when jumping half-pages / search results
map("n", "<C-d>", "<C-d>zz", { desc = "Half-page down + center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half-page up + center" })
map("n", "n", "nzzzv", { desc = "Next match + center" })
map("n", "N", "Nzzzv", { desc = "Prev match + center" })

-- Better indenting: stay in visual mode after < >
map("v", "<", "<gv", { desc = "Indent left, keep selection" })
map("v", ">", ">gv", { desc = "Indent right, keep selection" })

map("n", "<leader>R", function()
	for name, _ in pairs(package.loaded) do
		if name:match("^config") then
			package.loaded[name] = nil
		end
	end
	dofile(vim.env.MYVIMRC)
	vim.notify("Config reloaded")
end, { desc = "Reload config" })

-- Inside VS Code (vscode-neovim): point the plugin and window keys at VS Code's own features
if vim.g.vscode then
	local vscode = require("vscode")
	local function action(cmd)
		return function()
			vscode.action(cmd)
		end
	end
	map("n", "<leader>ff", action("workbench.action.quickOpen"), { desc = "Find files" })
	map("n", "<leader>fg", action("workbench.action.findInFiles"), { desc = "Search text in files" })
	map("n", "<leader>fb", action("workbench.action.showAllEditors"), { desc = "Open editors" })
	map("n", "<leader>fr", action("workbench.action.openRecent"), { desc = "Recent files" })
	map("n", "<leader>e", action("workbench.view.explorer"), { desc = "File explorer" })
	map("n", "<leader>gg", action("workbench.view.scm"), { desc = "Source control" })
	map("n", "<S-l>", action("workbench.action.nextEditor"), { desc = "Next tab" })
	map("n", "<S-h>", action("workbench.action.previousEditor"), { desc = "Previous tab" })
	map("n", "<leader>bd", action("workbench.action.closeActiveEditor"), { desc = "Close tab" })
	map("n", "<leader>zq", action("workbench.action.closeActiveEditor"), { desc = "Close tab" })
	map("n", "<C-h>", action("workbench.action.navigateLeft"), { desc = "Go to left group" })
	map("n", "<C-j>", action("workbench.action.navigateDown"), { desc = "Go to lower group" })
	map("n", "<C-k>", action("workbench.action.navigateUp"), { desc = "Go to upper group" })
	map("n", "<C-l>", action("workbench.action.navigateRight"), { desc = "Go to right group" })
	map("n", "<leader>sv", action("workbench.action.splitEditorRight"), { desc = "Split vertical" })
	map("n", "<leader>sh", action("workbench.action.splitEditorDown"), { desc = "Split horizontal" })
end
