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

vim.keymap.set("n", "<leader>w", "<cmd>w<cr>")
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>")

require("config.lazy")
require("config.lsp")
require("config.keymaps")
require("config.ui")
