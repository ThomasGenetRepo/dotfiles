-- lua/config/ui.lua

vim.o.winborder = "rounded"

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
end

set_ui_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
	callback = set_ui_highlights,
})
