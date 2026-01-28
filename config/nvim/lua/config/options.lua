-- basic options mirroring your doom setup
local opt = vim.opt

-- line numbers
opt.number = true
opt.relativenumber = true

-- indentation (matching your conventions)
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true

-- search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true

-- ui
opt.termguicolors = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.wrap = false

-- splits
opt.splitright = true
opt.splitbelow = true

-- clipboard (sync with system)
opt.clipboard = "unnamedplus"

-- persist undo
opt.undofile = true

-- vim.g.lazyvim_python_lsp = "basedpyright"
