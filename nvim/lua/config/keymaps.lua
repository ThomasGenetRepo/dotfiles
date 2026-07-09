-- lua/config/keymaps.lua

local map = vim.keymap.set

-- Keep this file for non-LSP, general editor keymaps.
-- LSP-specific keymaps should stay in lua/config/lsp.lua inside LspAttach.

-- Better command-line behavior.
map("n", "<leader>w", "<cmd>write<cr>", {
  desc = "Save file",
})

map("n", "<leader>q", "<cmd>quit<cr>", {
  desc = "Quit window",
})

-- Clear search highlighting.
map("n", "<Esc>", "<cmd>nohlsearch<cr>", {
  desc = "Clear search highlight",
})

-- Keep lines selected after indenting in visual mode.
map("v", "<", "<gv", {
  desc = "Indent left",
})

map("v", ">", ">gv", {
  desc = "Indent right",
})

-- Move selected lines up/down in visual mode.
map("v", "J", ":m '>+1<cr>gv=gv", {
  desc = "Move selection down",
})

map("v", "K", ":m '<-2<cr>gv=gv", {
  desc = "Move selection up",
})

-- Better scrolling: keep cursor centered.
map("n", "<C-d>", "<C-d>zz", {
  desc = "Half-page down",
})

map("n", "<C-u>", "<C-u>zz", {
  desc = "Half-page up",
})

-- Search next/previous and center result.
map("n", "n", "nzzzv", {
  desc = "Next search result",
})

map("n", "N", "Nzzzv", {
  desc = "Previous search result",
})

-- Native undo/redo reminders:
-- u       undo
-- <C-r>   redo
-- g;      previous edit location
-- g,      next edit location
-- <C-o>   jump back
-- <C-i>   jump forward

local diagnostics_virtual_text = true

vim.keymap.set("n", "<leader>uv", function()
  diagnostics_virtual_text = not diagnostics_virtual_text

  vim.diagnostic.config({
    virtual_text = diagnostics_virtual_text and {
      spacing = 4,
      source = "if_many",
      prefix = "●",
    } or false,
  })
end, {
  desc = "Toggle diagnostic virtual text",
})
