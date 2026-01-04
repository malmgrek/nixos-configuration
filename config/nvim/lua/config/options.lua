-- Basic options mirroring your Doom setup
local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Indentation (matching your conventions)
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true

-- UI
opt.termguicolors = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.wrap = false

-- Splits
opt.splitright = true
opt.splitbelow = true

-- Clipboard (sync with system)
opt.clipboard = "unnamedplus"

-- Persist undo
opt.undofile = true
