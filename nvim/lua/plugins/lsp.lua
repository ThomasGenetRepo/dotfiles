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
		lazy = false,
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
				"typescript-language-server",
				"svelte-language-server",
				"css-lsp",
				"html-lsp",
				"yaml-language-server",

				-- formatters
				"goimports",
				"stylua",
				"shfmt",
				"prettier",
				"jq",

				-- linters
				"eslint_d",
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
			local ts = require("nvim-treesitter")

			ts.setup({
				install_dir = vim.fn.stdpath("data") .. "/site",
			})

			-- The main branch has no `ensure_installed` option, so install
			-- explicitly. Already-installed parsers are a no-op, and the
			-- call is async -- it won't block startup.
			local parsers = {
				"bash",
				"css",
				"diff",
				"dockerfile",
				"gitcommit",
				"gitignore",
				"go",
				"gomod",
				"gosum",
				"gotmpl",
				"gowork",
				"graphql",
				"hcl",
				"html",
				"javascript",
				"json",
				"lua",
				"make",
				"markdown",
				"markdown_inline",
				"nginx",
				"proto",
				"python",
				"query",
				"regex",
				"scss",
				"sql",
				"ssh_config",
				"svelte",
				"terraform",
				"toml",
				"tsx",
				"typescript",
				"vim",
				"vimdoc",
				"yaml",
			}

			local installed = {}
			for _, lang in ipairs(ts.get_installed()) do
				installed[lang] = true
			end

			local missing = vim.tbl_filter(function(lang)
				return not installed[lang]
			end, parsers)

			if #missing > 0 then
				ts.install(missing, { summary = true })
			end

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
				["<Tab>"] = { "accept", "fallback" },
			},

			appearance = {
				nerd_font_variant = "mono",
			},

			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},

			cmdline = {
				sources = function()
					local type = vim.fn.getcmdtype()
					if type == "/" or type == "?" then
						return { "buffer" }
					end
					if type == ":" or type == "@" then
						return { "cmdline", "path" }
					end
					return {}
				end,

				completion = {
					menu = { auto_show = true },
				},
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
						-- Icon + label + description only -- the spelled-out "kind"
						-- column (Function/Class/...) duplicated the icon, so it's
						-- dropped in favor of giving the description more room.
						columns = {
							{ "kind_icon", "label", "label_description", gap = 1 },
						},

						components = {
							-- Tint the label with the same color as its kind icon
							-- (blue for functions, purple for classes, ...) instead
							-- of a flat color, so kind is scannable at a glance
							-- without reading the icon glyph. Copied from blink's
							-- default `label` component with only the base
							-- highlight group swapped for `ctx.kind_hl`.
							label = {
								highlight = function(ctx)
									local label = ctx.label
									local highlights = {
										{ 0, #label, group = ctx.deprecated and "BlinkCmpLabelDeprecated" or ctx.kind_hl },
									}
									if ctx.label_detail then
										table.insert(
											highlights,
											{ #label, #label + #ctx.label_detail, group = "BlinkCmpLabelDetail" }
										)
									end

									if vim.list_contains(ctx.self.treesitter, ctx.source_id) and not ctx.deprecated then
										vim.list_extend(
											highlights,
											require("blink.cmp.completion.windows.render.treesitter").highlight(ctx)
										)
									end

									for _, idx in ipairs(ctx.label_matched_indices) do
										table.insert(highlights, { idx, idx + 1, group = "BlinkCmpLabelMatch" })
									end

									return highlights
								end,
							},
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

	-- nvim-lint: linter diagnostics separate from the LSP servers above.
	-- (e.g. eslint_d catches things ts_ls won't, and runs even when a
	-- project has no LSP-visible tsconfig.)
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local lint = require("lint")

			lint.linters_by_ft = {
				javascript = { "eslint_d" },
				javascriptreact = { "eslint_d" },
				typescript = { "eslint_d" },
				typescriptreact = { "eslint_d" },
				svelte = { "eslint_d" },
				python = { "ruff" },
			}

			-- Run ruff through `uv` (see conform's ruff_format override in
			-- tools.lua for why) instead of the mason-installed binary.
			lint.linters.ruff = vim.tbl_deep_extend("force", lint.linters.ruff, {
				cmd = "uv",
				args = vim.list_extend({ "run", "--", "ruff" }, lint.linters.ruff.args),
			})

			local group = vim.api.nvim_create_augroup("UserLint", { clear = true })

			vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
				group = group,
				callback = function()
					lint.try_lint()
				end,
			})
		end,
	},
}
