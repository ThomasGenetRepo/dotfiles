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

	["kanso"] = "kanso",
	["kanso-zen"] = "kanso",
	["kanso-mist"] = "kanso",
	["kanso-pearl"] = "kanso",

	["vague"] = "vague",

	["no-clown-fiesta"] = "no-clown-fiesta",
	["no-clown-fiesta-dim"] = "no-clown-fiesta",
	["no-clown-fiesta-light"] = "no-clown-fiesta",

	["darkvoid"] = "darkvoid",
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

	["kanso"] = "kanso-ink",
	["kanso-zen"] = "kanso-zen",
	["kanso-mist"] = "kanso-mist",
	["kanso-pearl"] = "kanso-pearl",

	["vague"] = "vague",

	["no-clown-fiesta"] = "no-clown-fiesta",
	["no-clown-fiesta-dim"] = "no-clown-fiesta-dim",
	["no-clown-fiesta-light"] = "no-clown-fiesta-light",

	["darkvoid"] = "darkvoid",
}

-- Explicit order (not `pairs()` over the maps above, which don't have a
-- stable iteration order) -- this is both the picker's display order and
-- what themery.nvim's persisted theme_id indexes into.
local theme_order = {
	"rose-pine",

	"kanagawa",
	"kanagawa-dragon",
	"kanagawa-lotus",

	"embark",

	"nightfox",
	"duskfox",
	"nordfox",
	"carbonfox",

	"nvim-tundra",

	"catppuccin-mocha",
	"catppuccin-macchiato",

	"tokyonight-moon",

	"kanso",
	"kanso-zen",
	"kanso-mist",
	"kanso-pearl",

	"vague",

	"no-clown-fiesta",
	"no-clown-fiesta-dim",
	"no-clown-fiesta-light",

	"darkvoid",
}

-- themery.nvim's picker/persistence replaces the old manual
-- default_theme + VeryLazy-autocmd approach. Each entry's `before` hook
-- lazy-loads the owning plugin first, since themery just runs
-- `:colorscheme <name>` directly and every theme plugin here is
-- `lazy = true` -- without this, picking an unloaded theme would fail
-- with "colorscheme not found". `before` must be a literal code string
-- (not a function): themery persists it verbatim into its state.json and
-- replays that same string on every future startup.
local themery_themes = {}
for _, name in ipairs(theme_order) do
	table.insert(themery_themes, {
		name = name,
		colorscheme = scheme_map[name],
		before = string.format([[require('lazy').load({ plugins = { %q } })]], theme_plugin[name]),
	})
end

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

	{
		"webhooked/kanso.nvim",
		name = "kanso",
		lazy = true,
		opts = {
			transparent = false,
		},
	},

	{
		"vague-theme/vague.nvim",
		name = "vague",
		lazy = true,
		opts = {
			transparent = false,
			bold = true,
			italic = true,
		},
	},

	{
		"aktersnurra/no-clown-fiesta.nvim",
		name = "no-clown-fiesta",
		lazy = true,
		opts = {
			theme = "dark", -- only affects plain `:colorscheme no-clown-fiesta`, not the -dim/-light variants
		},
	},

	{
		"darkvoid-theme/darkvoid.nvim",
		name = "darkvoid",
		lazy = true,
		opts = {
			transparent = false,
			glow = false,
		},
	},

	-- Theme picker (`:Themery`): j/k previews live, <cr> applies and
	-- persists to stdpath("data")/themery/state.json, q/<esc> reverts.
	-- Not lazy -- it needs to run at startup to restore the persisted
	-- theme; loading its own small Lua module is cheap.
	{
		"zaldih/themery.nvim",
		lazy = false,
		config = function()
			require("themery").setup({
				themes = themery_themes,
				livePreview = true,
			})
		end,
	},
}
