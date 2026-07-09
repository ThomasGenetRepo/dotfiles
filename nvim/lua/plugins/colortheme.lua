local default_theme = "nightfox"

-- Maps a short theme name to its owning plugin (must match the "name" field below).
local theme_plugin = {
	["rose-pine"] = "rose-pine",

	["kanagawa"] = "kanagawa",
	["kanagawa-dragon"] = "kanagawa",
	["kanagawa-lotus"] = "kanagawa",

	["embark"] = "embark",

	["nightfox"] = "nightfox",
	["duskfox"] = "nightfox",
	["nordfox"] = "nightfox",
	["carbonfox"] = "nightfox",

	["nvim-tundra"] = "nvim-tundra",

	["catppuccin-mocha"] = "catppuccin",
	["catppuccin-macchiato"] = "catppuccin",

	["tokyonight-moon"] = "tokyonight",
}

-- Maps a short theme name to the actual :colorscheme name to invoke.
local scheme_map = {
	["rose-pine"] = "rose-pine-moon",

	["kanagawa"] = "kanagawa-wave",
	["kanagawa-dragon"] = "kanagawa-dragon",
	["kanagawa-lotus"] = "kanagawa-lotus",

	["embark"] = "embark",

	["nightfox"] = "nightfox",
	["duskfox"] = "duskfox",
	["nordfox"] = "nordfox",
	["carbonfox"] = "carbonfox",

	["nvim-tundra"] = "tundra",

	["catppuccin-mocha"] = "catppuccin-mocha",
	["catppuccin-macchiato"] = "catppuccin-macchiato",

	["tokyonight-moon"] = "tokyonight-moon",
}

vim.api.nvim_create_autocmd("User", {
	pattern = "VeryLazy",
	once = true,
	callback = function()
		require("lazy").load({ plugins = { theme_plugin[default_theme] } })
		vim.cmd.colorscheme(scheme_map[default_theme])
	end,
})

return {
	{
		"rose-pine/neovim",
		name = "rose-pine",
		lazy = true,
		opts = {
			variant = "moon",
		},
	},

	{
		"rebelot/kanagawa.nvim",
		name = "kanagawa",
		lazy = true,
		opts = {
			compile = false,
			theme = "wave",
		},
	},

	{
		"embark-theme/vim",
		name = "embark",
		lazy = true,
		branch = "main",
		build = ":UpdateRemotePlugins",
	},

	{
		"EdenEast/nightfox.nvim",
		name = "nightfox",
		lazy = true,
		opts = {
			options = {
				transparent = false,
			},
		},
	},

	{
		"sam4llis/nvim-tundra",
		name = "nvim-tundra",
		lazy = true,
		opts = {
			transparent_background = false,
			dim_inactive_windows = { enabled = false },
			sidebars = { enabled = true },
		},
	},

	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = true,
		opts = {
			flavour = "mocha", -- only affects plain `:colorscheme catppuccin`, not the -mocha/-macchiato variants
		},
	},

	{
		"folke/tokyonight.nvim",
		name = "tokyonight",
		lazy = true,
		opts = {
			style = "moon", -- only affects plain `:colorscheme tokyonight`, not `tokyonight-moon` directly
		},
	},
}
