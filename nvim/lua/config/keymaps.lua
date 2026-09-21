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

-- Scroll the view without moving the cursor. Plain <C-e>/<C-y> would do
-- this natively, but harpoon.lua takes <C-e> for its quick menu, so use
-- these instead.
map("n", "<C-Down>", "<C-e>", {
	desc = "Scroll view down (cursor stays)",
})

map("n", "<C-Up>", "<C-y>", {
	desc = "Scroll view up (cursor stays)",
})

-- Search next/previous and center result.
map("n", "n", "nzzzv", {
	desc = "Next search result",
})

map("n", "N", "Nzzzv", {
	desc = "Previous search result",
})

-- j/k move by display line (wrap is on, so a long wrapped comment/string
-- shouldn't skip a whole logical line per keypress). A count > 1 falls back
-- to real linewise j/k (counting display lines would be confusing) and
-- drops a mark first so '' still jumps back, matching normal j/k behavior
-- for a "real" multi-line jump.
map("n", "k", [[v:count > 1 ? "m'" . v:count . "k" : "gk"]], {
	expr = true,
	silent = true,
	desc = "Up (display line)",
})

map("n", "j", [[v:count > 1 ? "m'" . v:count . "j" : "gj"]], {
	expr = true,
	silent = true,
	desc = "Down (display line)",
})

-- Native undo/redo reminders:
-- u       undo
-- <C-r>   redo
-- g;      previous edit location
-- g,      next edit location
-- <C-o>   jump back
-- <C-i>   jump forward

-- tiny-inline-diagnostic.nvim (tools.lua) owns inline diagnostic rendering
-- and forces the native virtual_text off, so toggle its own display instead.
vim.keymap.set("n", "<leader>uv", function()
	require("tiny-inline-diagnostic").toggle()
end, {
	desc = "Toggle inline diagnostics",
})

-- Git hunks.
map("n", "]h", function()
	require("gitsigns").next_hunk()
end, {
	desc = "Next git hunk",
})

map("n", "[h", function()
	require("gitsigns").prev_hunk()
end, {
	desc = "Previous git hunk",
})

map("n", "<leader>hs", function()
	require("gitsigns").stage_hunk()
end, {
	desc = "Stage hunk",
})

map("n", "<leader>hr", function()
	require("gitsigns").reset_hunk()
end, {
	desc = "Reset hunk",
})

map("n", "<leader>hp", function()
	require("gitsigns").preview_hunk()
end, {
	desc = "Preview hunk",
})

map("n", "<leader>hb", function()
	require("gitsigns").blame_line()
end, {
	desc = "Blame line",
})

-- System clipboard.
map("n", "<leader>y", '"+y', {
	desc = "Yank to system clipboard",
})

map("v", "<leader>y", '"+y', {
	desc = "Yank selection to system clipboard",
})

map("n", "<leader>Y", '"+Y', {
	desc = "Yank line to system clipboard",
})

map("n", "<leader>p", '"+p', {
	desc = "Paste from system clipboard",
})

map("v", "<leader>p", '"+p', {
	desc = "Paste from system clipboard",
})

-- Copy file paths.
map("n", "<leader>cp", function()
	vim.fn.setreg("+", vim.fn.expand("%"))
end, {
	desc = "Copy relative file path",
})

map("n", "<leader>cP", function()
	vim.fn.setreg("+", vim.fn.expand("%:p"))
end, {
	desc = "Copy absolute file path",
})

-- Capital L: lowercase <leader>cl is Trouble's LSP definitions/references
-- toggle (tools.lua) and wins at runtime, so this can't share that key.
map("n", "<leader>cL", function()
	vim.fn.setreg("+", vim.fn.expand("%") .. ":" .. vim.fn.line("."))
end, {
	desc = "Copy file path with line",
})

-- Todo comments.
map("n", "<leader>td", "<cmd>TodoLocList<cr>", {
	desc = "Todo location list",
})

-- LSP management.
map("n", "<leader>li", "<cmd>checkhealth vim.lsp<cr>", {
	desc = "LSP info",
})

-- Restart every LSP client on the current buffer, then re-fire FileType so
-- the enabled servers re-attach with fresh project state. Useful when the
-- server goes stale relative to on-disk changes made in another tmux pane.
--
-- Re-fires FileType directly (rather than `:edit`) because vim.lsp.enable()
-- attaches clients via a FileType autocommand, and Vim only re-triggers
-- FileType when the filetype value actually changes -- re-opening a buffer
-- whose filetype is unchanged (e.g. still "python") is a silent no-op, and
-- `:edit` errors outright (E37) if the buffer has unsaved changes.
map("n", "<leader>lr", function()
	local bufnr = vim.api.nvim_get_current_buf()
	local clients = vim.lsp.get_clients({ bufnr = bufnr })

	if vim.tbl_isempty(clients) then
		vim.notify("No LSP clients attached to this buffer", vim.log.levels.INFO)
		return
	end

	local names = {}
	local filetype = vim.bo[bufnr].filetype
	for _, client in ipairs(clients) do
		table.insert(names, client.name)
		vim.lsp.stop_client(client.id)
	end

	-- Give the clients a moment to exit before re-attaching.
	vim.defer_fn(function()
		vim.api.nvim_exec_autocmds("FileType", { pattern = filetype })
		vim.notify("Restarted LSP: " .. table.concat(names, ", "), vim.log.levels.INFO)
	end, 500)
end, {
	desc = "Restart LSP (current buffer)",
})
