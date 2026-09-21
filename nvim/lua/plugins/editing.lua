-- lua/plugins/editing.lua

return {
	-- Seamless navigation between Neovim splits and tmux panes.
	-- Ctrl-h/j/k/l moves between nvim splits and tmux panes.
	{
		"christoomey/vim-tmux-navigator",
		lazy = false,
		init = function()
			-- Disable all 5 default mappings so we can omit <C-\> (its
			-- "previous pane" binding), which otherwise wins the collision
			-- against floaterm's toggle keymap.
			vim.g.tmux_navigator_no_mappings = 1
		end,
		keys = {
			{ "<c-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Navigate left (tmux-aware)" },
			{ "<c-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Navigate down (tmux-aware)" },
			{ "<c-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Navigate up (tmux-aware)" },
			{ "<c-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Navigate right (tmux-aware)" },
		},
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

	{
		"echasnovski/mini.ai",
		version = false,
		event = "VeryLazy",
		opts = {
			n_lines = 500,
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
				"<leader>fd",
				function()
					require("fzf-lua").diagnostics_document()
				end,
				desc = "Buffer diagnostics",
			},
			{
				"<leader>fD",
				function()
					require("fzf-lua").diagnostics_workspace()
				end,
				desc = "Workspace diagnostics",
			},
			{
				"<leader>fr",
				function()
					require("fzf-lua").oldfiles()
				end,
				desc = "Recent files",
			},
			{
				"<leader>fj",
				function()
					require("fzf-lua").jumps()
				end,
				desc = "Jumplist",
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

	-- Neovim's bundled indent/python.vim (python#GetIndent) miscomputes
	-- indent for a closing bracket when there's a blank/whitespace-only
	-- line between it and the opener -- e.g. `{<CR><CR>}` ends up with the
	-- `}` indented a full extra level instead of matching the opener.
	-- Confirmed via `:lua =python#GetIndent(lnum)` with v:lnum set to
	-- reproduce what indentexpr actually sees: returns double the correct
	-- indent. This replaces indentexpr with a version that gets it right.
	{
		"Vimjas/vim-python-pep8-indent",
		ft = "python",
	},

	-- Pin a handful of files you're actively bouncing between and jump
	-- straight to them, instead of re-fuzzy-finding each time.
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local harpoon = require("harpoon")
			harpoon:setup()

			vim.keymap.set("n", "<leader>a", function()
				harpoon:list():add()
			end, { desc = "Harpoon: add file" })

			vim.keymap.set("n", "<C-e>", function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end, { desc = "Harpoon: toggle menu" })

			for i = 1, 4 do
				vim.keymap.set("n", "<leader>" .. i, function()
					harpoon:list():select(i)
				end, { desc = "Harpoon: jump to file " .. i })
			end
		end,
	},
}
