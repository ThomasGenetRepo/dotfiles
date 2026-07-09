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

	-- File explorer that lets you edit directories like normal buffers.
	{
		"stevearc/oil.nvim",
		cmd = "Oil",
		keys = {
			{
				"-",
				"<cmd>Oil<cr>",
				desc = "Open parent directory",
			},
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
						lsp_fallback = true,
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
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
			},

			format_on_save = function(bufnr)
				local disabled_filetypes = {}

				if disabled_filetypes[vim.bo[bufnr].filetype] then
					return
				end

				return {
					timeout_ms = 1000,
					lsp_fallback = true,
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
}
