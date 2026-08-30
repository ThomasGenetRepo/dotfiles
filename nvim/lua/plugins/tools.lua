-- lua/plugins/tools.lua

return {
	-- Better diagnostics, references, quickfix, and location list UI.
	{
		"folke/trouble.nvim",
		cmd = "Trouble",
		keys = {
			{
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Diagnostics",
			},
			{
				"<leader>xX",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Buffer diagnostics",
			},
			{
				"<leader>cs",
				"<cmd>Trouble symbols toggle focus=false<cr>",
				desc = "Symbols",
			},
			{
				"<leader>cl",
				"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
				desc = "LSP definitions/references",
			},
			{
				"<leader>xL",
				"<cmd>Trouble loclist toggle<cr>",
				desc = "Location list",
			},
			{
				"<leader>xQ",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "Quickfix list",
			},
		},
		opts = {
			focus = true,
		},
	},

	-- Inline diagnostics at end of line, replacing the native virtual_text
	-- (which was off - long Terraform/module errors were unreadable as
	-- virtual text). This one wraps/truncates instead of overflowing.
	{
		"rachartier/tiny-inline-diagnostic.nvim",
		event = "VeryLazy",
		priority = 1000,
		config = function()
			require("tiny-inline-diagnostic").setup({
				preset = "modern",
				options = {
					show_source = { enabled = false },
					multilines = { enabled = false },
				},
			})

			vim.diagnostic.config({ virtual_text = false })
		end,
	},

	-- Sticky header showing the enclosing function/class/block while
	-- scrolled past its definition.
	{
		"nvim-treesitter/nvim-treesitter-context",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		event = "BufReadPost",
		opts = {
			max_lines = 3,
			mode = "cursor",
		},
	},

	-- LSP progress notifications (indexing, mason installs, etc.) as a
	-- small corner spinner instead of blocking or cluttering the command line.
	{
		"j-hui/fidget.nvim",
		event = "LspAttach",
		opts = {},
	},

	-- Statusline. Minimal on purpose: no chevrons/separators, no mode block
	-- (mode-cursorline.lua already conveys mode via the line number color),
	-- just filename + diagnostics + git branch.
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		event = "VeryLazy",
		opts = {
			options = {
				theme = "auto",
				component_separators = "",
				section_separators = "",
				globalstatus = false,
			},
			sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = {
					{
						"filename",
						path = 1,
						symbols = { modified = " ●", readonly = "" },
					},
				},
				lualine_x = { "diagnostics" },
				lualine_y = { "branch" },
				lualine_z = {},
			},
			inactive_sections = {
				lualine_c = { { "filename", path = 1 } },
				lualine_x = {},
			},
		},
	},

	-- Code outline / symbols tree window.
	{
		"stevearc/aerial.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		cmd = "AerialToggle",
		keys = {
			{
				"<leader>co",
				"<cmd>AerialToggle<cr>",
				desc = "Toggle outline",
			},
		},
		opts = {
			show_guides = true,
		},
	},

	-- File explorer that lets you edit directories like normal buffers.
	{
		"stevearc/oil.nvim",
		cmd = "Oil",
		keys = {
			{
				"<leader>o",
				"<cmd>Oil<cr>",
				desc = "Open Oil",
			},
		},
		opts = {
			default_file_explorer = true,
			columns = {
				"icon",
			},
			view_options = {
				show_hidden = true,
			},
			float = {
				border = "rounded",
				padding = 2,
				-- Preview split direction when oil is opened as a floating window.
				preview_split = "right",
			},
			keymaps = {
				["q"] = "actions.close",
				["<C-c>"] = "actions.close",
				["<CR>"] = "actions.select",
				["<C-v>"] = "actions.select_vsplit",
				["<C-s>"] = "actions.select_split",
				["<C-t>"] = "actions.select_tab",
				["-"] = "actions.parent",
				["_"] = "actions.open_cwd",
				["g."] = "actions.toggle_hidden",
				-- Override the default preview action: it derives its split
				-- direction from &splitright, which is left in this config,
				-- so force it right explicitly instead of flipping splitright
				-- globally (that would also affect unrelated vertical splits).
				["<C-p>"] = {
					callback = function()
						require("oil").open_preview({ split = "belowright" })
					end,
					desc = "Preview (right split)",
				},
			},
		},
	},

	-- Formatting.
	{
		"stevearc/conform.nvim",
		event = {
			"BufWritePre",
		},
		cmd = {
			"ConformInfo",
		},
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({
						async = true,
						lsp_format = "fallback",
					})
				end,
				mode = "",
				desc = "Format buffer",
			},
		},
		opts = {
			formatters_by_ft = {
				go = { "gofumpt", "goimports" },
				python = { "ruff_format" },
				lua = { "stylua" },
				json = { "jq" },
				jsonc = { "jq" },
				terraform = { "terraform_fmt" },
				hcl = { "terraform_fmt" },
				sh = { "shfmt" },
				bash = { "shfmt" },
				javascript = { "prettier" },
				javascriptreact = { "prettier" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				svelte = { "prettier" },
				html = { "prettier" },
				css = { "prettier" },
				scss = { "prettier" },
			},

			-- Run ruff through `uv` so formatting uses the project's pinned
			-- ruff version (from pyproject.toml/uv.lock) instead of the
			-- mason-installed global binary. Requires ruff to be a project
			-- dependency (e.g. a dev-dependency) - otherwise `uv run ruff`
			-- has nothing to resolve and errors.
			formatters = {
				ruff_format = {
					command = "uv",
					args = { "run", "--", "ruff", "format", "--force-exclude", "--stdin-filename", "$FILENAME", "-" },
				},
			},

			format_on_save = function(bufnr)
				local disabled_filetypes = {}

				if disabled_filetypes[vim.bo[bufnr].filetype] then
					return
				end

				return {
					timeout_ms = 1000,
					lsp_format = "fallback",
				}
			end,
		},
	},
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {
			style = "normal",
			left_pad = 2,
		},
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			preset = "modern",
			delay = 500,
			spec = {
				{ "<leader>f", group = "find" },
				{ "<leader>h", group = "git hunk" },
				{ "<leader>x", group = "diagnostics/trouble" },
				{ "<leader>c", group = "code" },
				{ "<leader>l", group = "lsp" },
				{ "<leader>u", group = "toggle" },
			},
		},
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer keymaps",
			},
		},
	},
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
			current_line_blame = false,
		},
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		},
	},

	-- Inline image preview (opening a .png/.jpg/.svg buffer renders it)
	-- via the Kitty graphics protocol, which WezTerm supports.
	{
		"3rd/image.nvim",
		build = false,
		event = "VeryLazy",
		opts = {
			backend = "kitty",
			processor = "magick_cli",
			integrations = {},
			hijack_file_patterns = {
				"*.png",
				"*.jpg",
				"*.jpeg",
				"*.gif",
				"*.webp",
				"*.avif",
				"*.svg",
			},
		},
	},

	-- Hover-to-preview images in file explorers (oil, neo-tree, etc),
	-- rendered via image.nvim.
	{
		"hmdfrds/focal.nvim",
		dependencies = { "3rd/image.nvim" },
		event = "VeryLazy",
		opts = {},
	},

	-- Toggleable file tree, off by default; oil stays the main explorer.
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		cmd = "Neotree",
		keys = {
			{
				"<leader>ft",
				"<cmd>Neotree toggle<cr>",
				desc = "Toggle file tree",
			},
		},
		opts = {},
	},

	-- Keeps a Session.vim in the cwd up to date (buffers, splits, cwd) so
	-- tmux-resurrect's `@resurrect-strategy-nvim 'session'` can bring this
	-- nvim back with `nvim -S` after a reboot. Loaded eagerly rather than on
	-- `cmd` because a session restored by `nvim -S` re-enables tracking via a
	-- hook baked into Session.vim, which needs the plugin already present.
	--
	-- Opt in per project with <leader>us; after that it's automatic.
	{
		"tpope/vim-obsession",
		lazy = false,
		keys = {
			{
				"<leader>us",
				"<cmd>Obsession<cr>",
				desc = "Toggle session tracking",
			},
		},
	},

	-- Floating terminal.
	{
		"nvzone/floaterm",
		dependencies = "nvzone/volt",
		keys = {
			{
				"<C-\\>",
				"<cmd>FloatermToggle<cr>",
				desc = "Toggle floating terminal",
			},
		},
		config = function()
			require("floaterm").setup({})

			-- Also bind inside the floaterm terminal buffer itself (scoped to
			-- its "Floaterm" filetype so this doesn't shadow <C-\><C-n> in
			-- ordinary :terminal buffers elsewhere).
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "Floaterm",
				callback = function(args)
					vim.keymap.set("t", "<C-\\>", "<cmd>FloatermToggle<cr>", {
						buffer = args.buf,
						desc = "Toggle floating terminal",
					})
				end,
			})
		end,
	},
}
