-- lua/plugins/editing.lua

return {
	-- Seamless navigation between Neovim splits and tmux panes.
	-- Ctrl-h/j/k/l moves between nvim splits and tmux panes.
	{
		"christoomey/vim-tmux-navigator",
		lazy = false,
	},

	-- Add/change/delete surrounding quotes, parens, brackets, tags, etc.
	{
		"echasnovski/mini.surround",
		version = false,
		opts = {
			mappings = {
				add = "sa",
				delete = "sd",
				replace = "sr",
				find = "sf",
				find_left = "sF",
				highlight = "sh",
				update_n_lines = "sn",
			},
		},
	},

	-- Fast fuzzy finder.
	{
		"ibhagwan/fzf-lua",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		keys = {
			{
				"<leader>ff",
				function()
					require("fzf-lua").files()
				end,
				desc = "Find files",
			},
			{
				"<leader>fg",
				function()
					require("fzf-lua").live_grep()
				end,
				desc = "Live grep",
			},
			{
				"<leader>fb",
				function()
					require("fzf-lua").buffers()
				end,
				desc = "Find buffers",
			},
			{
				"<leader>fs",
				function()
					require("fzf-lua").lsp_document_symbols()
				end,
				desc = "Document symbols",
			},
			{
				"<leader>fS",
				function()
					require("fzf-lua").lsp_workspace_symbols()
				end,
				desc = "Workspace symbols",
			},
			{
				"<leader>fr",
				function()
					require("fzf-lua").oldfiles()
				end,
				desc = "Recent files",
			},
		},
		opts = {
			winopts = {
				border = "rounded",
				preview = {
					border = "rounded",
				},
			},
		},
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	},
}
