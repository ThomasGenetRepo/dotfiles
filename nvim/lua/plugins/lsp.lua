-- lua/plugins/lsp.lua
--
-- Plugin specs for lazy.nvim. This file only handles installation/setup
-- of the tools themselves. Actual LSP server enabling lives in
-- lua/config/lsp.lua (loaded separately from init.lua).

return {
	-- Mason: installs LSP server binaries (gopls, basedpyright, etc.)
	-- and puts them on Neovim's PATH. It does NOT enable/configure servers;
	-- that's done via vim.lsp.enable() in the native LSP client.
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		dependencies = {
			"WhoIsSethDaniel/mason-tool-installer.nvim",
		},
		opts = {
			ensure_installed = {
				"gopls",
				"basedpyright",
				"lua-language-server",
				"gofumpt",
				"terraform-ls",

				-- formatters
				"goimports",
				"ruff",
				"stylua",
				"shfmt",
			},
		},
		config = function(_, opts)
			require("mason").setup()
			require("mason-tool-installer").setup(opts)
		end,
	},

	-- Treesitter: parsers, queries, highlighting.
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
		lazy = false,
		config = function()
			require("nvim-treesitter").setup({
				install_dir = vim.fn.stdpath("data") .. "/site",
			})

			local group = vim.api.nvim_create_augroup("UserTreesitterStart", { clear = true })

			vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
				group = group,
				callback = function(args)
					if vim.bo[args.buf].buftype ~= "" then
						return
					end

					local ft = vim.bo[args.buf].filetype
					if ft == "" then
						return
					end

					local lang = vim.treesitter.language.get_lang(ft)
					if not lang then
						return
					end

					pcall(vim.treesitter.start, args.buf, lang)
				end,
			})
		end,
	},

	-- blink.cmp: completion popups, snippets, path completion.
	{
		"saghen/blink.cmp",
		version = "*",
		opts = {
			keymap = {
				preset = "default",
				["<CR>"] = { "accept", "fallback" },
			},

			appearance = {
				nerd_font_variant = "mono",
			},

			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},

			completion = {
				menu = {
					border = "rounded",
					scrollbar = false,
					scrolloff = 2,

					winhighlight = table.concat({
						"Normal:BlinkCmpMenu",
						"FloatBorder:BlinkCmpMenuBorder",
						"CursorLine:BlinkCmpMenuSelection",
						"Search:None",
					}, ","),

					draw = {
						columns = {
							{ "kind_icon", "label", "label_description", gap = 1 },
							{ "kind" },
						},
					},
				},

				documentation = {
					auto_show = true,
					auto_show_delay_ms = 250,

					window = {
						border = "rounded",
						max_width = 72,
						max_height = 14,

						winhighlight = table.concat({
							"Normal:BlinkCmpDoc",
							"FloatBorder:BlinkCmpDocBorder",
							"EndOfBuffer:BlinkCmpDoc",
						}, ","),
					},
				},

				ghost_text = {
					enabled = true,
				},
			},

			signature = {
				enabled = true,

				window = {
					border = "rounded",
					max_width = 72,
					max_height = 12,

					winhighlight = table.concat({
						"Normal:BlinkCmpDoc",
						"FloatBorder:BlinkCmpDocBorder",
						"EndOfBuffer:BlinkCmpDoc",
					}, ","),
				},
			},
		},
	},
}
