  -- ============================================================
  -- options.lua — built-in editor settings
  -- ============================================================
  local opt = vim.opt   -- shorthand

  -- Line numbers
  opt.number = true            -- absolute number on the current line
  opt.relativenumber = true    -- relative numbers on the others (easy 5j, 12dd)

  -- Indentation
  opt.expandtab = true         -- Tab key inserts spaces, not a tab char
  opt.shiftwidth = 2           -- size of an indent (>> and auto-indent)
  opt.tabstop = 2              -- how wide a literal tab looks
  opt.softtabstop = 0          -- Backspace deletes one space at a time
  opt.smartindent = true       -- auto-indent new lines based on context

  -- Search
  opt.ignorecase = true        -- case-insensitive...
  opt.smartcase = true         -- ...unless you type an uppercase letter
  opt.incsearch = true         -- jump to matches as you type
  opt.hlsearch = true          -- highlight all matches

  -- UI / display
  opt.termguicolors = true     -- enable 24-bit true color (needed for themes)
  opt.signcolumn = "yes"       -- always show the left gutter (no text-shift)
  opt.cursorline = true        -- highlight the line the cursor is on
  opt.scrolloff = 8            -- keep 8 lines visible above/below cursor
  opt.wrap = false             -- don't wrap long lines (IDE-style)
  opt.colorcolumn = "80"       -- vertical guide at column 80

  -- Editing behavior
  -- clipboard left unset: yy/p stay inside Neovim; use "+y and "+p for the system clipboard
  opt.undofile = true           -- persistent undo across sessions
  opt.swapfile = false          -- no .swp files
  opt.updatetime = 250          -- faster CursorHold (default 4000ms)
  opt.timeoutlen = 400          -- time to wait for a mapped key sequence

  -- Splits (match natural reading + your tmux habit)
  opt.splitright = true        -- vertical splits open to the right
  opt.splitbelow = true        -- horizontal splits open below

  -- Completion menu behavior (used later by blink.cmp)
  opt.completeopt = "menu,menuone,noselect"


