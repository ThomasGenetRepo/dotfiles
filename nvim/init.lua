vim.loader.enable()

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = true
vim.opt.conceallevel = 2

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"

vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.o.breakindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.o.undofile = true

vim.o.signcolumn = "yes"

vim.o.inccommand = "split"

vim.o.cursorline = true

-- Show a visible mark over trailing whitespace. Setting listchars replaces
-- the whole option, so tab must be respecified or tabs render as "^I".
vim.opt.list = true
vim.opt.listchars = { tab = "  ", trail = "·" }

-- Native popup-menu-style cmdline completion (reuses Pmenu/PmenuSel/
-- winborder), instead of the classic single-line wildmenu bar.
vim.opt.wildmenu = true
vim.opt.wildoptions = "pum"

require("config.filetype")
require("config.keymaps")
require("config.lazy")
require("config.lsp")
require("config.ui")
