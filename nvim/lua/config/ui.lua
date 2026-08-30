-- lua/config/ui.lua

vim.o.winborder = "rounded"

-- Color CursorLineNr by mode, sourced from semantic highlight groups so it
-- adapts across whichever colortheme.lua theme is active.
local function get_fg(name)
	local hl = vim.api.nvim_get_hl(0, {
		name = name,
		link = false,
	})

	return hl.fg
end

local function mode_cursorline_colors()
	local colors = {}

	-- Capture the theme's own CursorLineNr styling for normal mode (and as
	-- the fallback for any submode not listed below) before we touch it.
	colors.n = vim.api.nvim_get_hl(0, {
		name = "CursorLineNr",
		link = false,
	})

	local by_mode = {
		i = "String",
		v = "Constant",
		V = "Constant",
		[string.char(22)] = "Constant",
		R = "DiagnosticError",
		c = "Function",
		t = "Type",
	}

	for mode, group in pairs(by_mode) do
		local fg = get_fg(group)
		if fg then
			colors[mode] = { fg = fg }
		end
	end

	return colors
end

local function set_mode_cursorline()
	require("config.mode-cursorline").setup({
		mode = mode_cursorline_colors(),
	})
end

set_mode_cursorline()

vim.api.nvim_create_autocmd("ColorScheme", {
	callback = set_mode_cursorline,
})

local function set_ui_highlights()
	-- Native floating windows.
	-- Do not link NormalFloat to Normal. Let the colorscheme own it,
	-- or override it explicitly in the colorscheme config.
	vim.api.nvim_set_hl(0, "FloatBorder", {
		link = "Comment",
	})

	vim.api.nvim_set_hl(0, "FloatTitle", {
		link = "Title",
	})

	-- Native popup menu fallback groups.
	vim.api.nvim_set_hl(0, "Pmenu", {
		link = "NormalFloat",
	})

	vim.api.nvim_set_hl(0, "PmenuSel", {
		link = "Visual",
	})

	vim.api.nvim_set_hl(0, "PmenuThumb", {
		link = "Visual",
	})

	vim.api.nvim_set_hl(0, "PmenuSbar", {
		link = "NormalFloat",
	})

	-- blink.cmp completion menu.
	vim.api.nvim_set_hl(0, "BlinkCmpMenu", {
		link = "NormalFloat",
	})

	vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", {
		link = "FloatBorder",
	})

	vim.api.nvim_set_hl(0, "BlinkCmpMenuSelection", {
		link = "Visual",
	})

	-- blink.cmp documentation window.
	vim.api.nvim_set_hl(0, "BlinkCmpDoc", {
		link = "NormalFloat",
	})

	vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", {
		link = "FloatBorder",
	})

	-- blink.cmp labels/kinds.
	vim.api.nvim_set_hl(0, "BlinkCmpKind", {
		link = "Type",
	})

	vim.api.nvim_set_hl(0, "BlinkCmpLabel", {
		link = "Normal",
	})

	vim.api.nvim_set_hl(0, "BlinkCmpLabelDescription", {
		link = "Comment",
	})

	vim.api.nvim_set_hl(0, "BlinkCmpSource", {
		link = "Comment",
	})

	vim.api.nvim_set_hl(0, "BlinkCmpGhostText", {
		link = "Comment",
	})
	vim.api.nvim_set_hl(0, "ColorColumn", {
		bg = "#252535",
	})
end

set_ui_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
	callback = set_ui_highlights,
})

-- Make tmux pane titles useful when Neovim is running.
vim.o.title = true
vim.o.titlelen = 0

_G.nvim_tmux_title = function()
	local bufname = vim.api.nvim_buf_get_name(0)
	local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")

	if bufname == "" then
		return "nvim:" .. cwd
	end

	local parent = vim.fn.fnamemodify(bufname, ":p:h:t")
	local filename = vim.fn.fnamemodify(bufname, ":t")
	local modified = vim.bo.modified and "*" or ""

	return "nvim:" .. cwd .. ":" .. parent .. "/" .. filename .. modified
end

vim.o.titlestring = "%{%v:lua.nvim_tmux_title()%}"

-- Make split separators more visible.
vim.opt.fillchars = {
	vert = "│",
	horiz = "─",
	horizup = "┴",
	horizdown = "┬",
	vertleft = "┤",
	vertright = "├",
	verthoriz = "┼",
}

-- Use per-window statuslines so horizontal splits have a clear separator.
vim.opt.laststatus = 2

local function set_split_highlights()
	vim.api.nvim_set_hl(0, "WinSeparator", {
		fg = "#c4a7e7",
		bg = "#191724",
	})

	vim.api.nvim_set_hl(0, "WinBar", {
		fg = "#e0def4",
		bg = "#191724",
	})

	vim.api.nvim_set_hl(0, "WinBarNC", {
		fg = "#6e6a86",
		bg = "#191724",
	})
end

set_split_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
	callback = set_split_highlights,
})

-- Put horizontal bars at various char lengths.
-- (ColorColumn's highlight is owned by set_ui_highlights above, which the
-- ColorScheme autocmd re-applies on every theme load.)
vim.opt.colorcolumn = { "80", "100", "120" }
