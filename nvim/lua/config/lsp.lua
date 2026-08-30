-- lua/config/lsp.lua
--
-- Native Neovim LSP setup.
--
-- No nvim-lspconfig dependency:
-- - vim.lsp.config() defines a server config
-- - vim.lsp.enable() enables it for matching buffers
--
-- This file should run after mason.nvim has initialized at least once,
-- so Mason's bin directory is available on Neovim's PATH.

-- ---------------------------------------------------------------------------
-- Diagnostics
-- ---------------------------------------------------------------------------

vim.diagnostic.config({
	-- Keep inline diagnostics off by default.
	-- Long Terraform/module errors are unreadable as virtual text.
	virtual_text = false,

	-- Keep virtual lines off unless manually enabled.
	virtual_lines = false,

	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "E",
			[vim.diagnostic.severity.WARN] = "W",
			[vim.diagnostic.severity.INFO] = "I",
			[vim.diagnostic.severity.HINT] = "H",
		},
	},

	underline = true,
	update_in_insert = false,
	severity_sort = true,

	float = {
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
		focusable = true,
		max_width = 100,
		wrap = true,
	},
})

vim.keymap.set("n", "<leader>e", function()
	vim.diagnostic.open_float(nil, {
		scope = "line",
		border = "rounded",
		source = "always",
		focusable = true,
		max_width = 100,
		wrap = true,
	})
end, {
	desc = "Show line diagnostic",
})
-- ---------------------------------------------------------------------------
-- LSP server configs
-- ---------------------------------------------------------------------------

vim.lsp.config("gopls", {
	cmd = { "gopls" },
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	root_markers = { "go.mod", "go.work", ".git" },
	settings = {
		gopls = {
			gofumpt = true,
			staticcheck = true,
			analyses = {
				unusedparams = true,
				unreachable = true,
				nilness = true,
				unusedwrite = true,
			},
		},
	},
})

vim.lsp.config("basedpyright", {
	cmd = { "basedpyright-langserver", "--stdio" },
	filetypes = { "python" },
	root_markers = {
		"pyproject.toml",
		"setup.py",
		"setup.cfg",
		"requirements.txt",
		".git",
	},
	settings = {
		basedpyright = {
			analysis = {
				typeCheckingMode = "standard",
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
			},
		},
	},
})

vim.lsp.config("lua_ls", {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = {
		".luarc.json",
		".luarc.jsonc",
		".git",
	},
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME,
					vim.fn.stdpath("config"),
				},
			},
			telemetry = {
				enable = false,
			},
		},
	},
})

vim.lsp.config("terraformls", {
	cmd = { "terraform-ls", "serve" },
	filetypes = { "terraform", "terraform-vars" },
	root_markers = {
		".terraform",
		".terraform.lock.hcl",
		"main.tf",
		"versions.tf",
		"providers.tf",
	},
})

vim.lsp.config("ts_ls", {
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
	},
	root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
})

vim.lsp.config("svelte", {
	cmd = { "svelteserver", "--stdio" },
	filetypes = { "svelte" },
	root_markers = { "package.json", ".git" },
})

vim.lsp.config("cssls", {
	cmd = { "vscode-css-language-server", "--stdio" },
	filetypes = { "css", "scss", "less" },
	root_markers = { "package.json", ".git" },
	settings = {
		css = { validate = true },
		scss = { validate = true },
		less = { validate = true },
	},
})

vim.lsp.config("html", {
	cmd = { "vscode-html-language-server", "--stdio" },
	filetypes = { "html" },
	root_markers = { "package.json", ".git" },
})

vim.lsp.config("yamlls", {
	cmd = { "yaml-language-server", "--stdio" },
	filetypes = { "yaml" },

	-- *.yaml.tmpl buffers are filetype=yaml (see config/filetype.lua) so
	-- treesitter highlights them, but they are not valid YAML -- every
	-- `{{- if ... }}` control line would be a parse error. Skipping the
	-- on_dir callback keeps yamlls from attaching to those buffers.
	root_dir = function(bufnr, on_dir)
		local name = vim.api.nvim_buf_get_name(bufnr)
		if name:match("%.tmpl$") then
			return
		end
		on_dir(vim.fs.root(bufnr, { ".git" }) or vim.fn.getcwd())
	end,

	settings = {
		yaml = {
			-- No schema auto-detection: schema store lookups produce a lot
			-- of false positives on templated / non-standard YAML.
			schemaStore = { enable = false, url = "" },
			schemas = {},
			validate = true,
			keyOrdering = false,
		},
	},
})

vim.lsp.enable({
	"gopls",
	"basedpyright",
	"lua_ls",
	"terraformls",
	"ts_ls",
	"svelte",
	"cssls",
	"html",
	"yamlls",
})

-- ---------------------------------------------------------------------------
-- LSP keymaps
-- ---------------------------------------------------------------------------

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
	callback = function(args)
		local buf = args.buf
		local map = vim.keymap.set

		local function opts(desc)
			return {
				buffer = buf,
				silent = true,
				desc = desc,
			}
		end

		-- Hover docs.
		map("n", "K", function()
			vim.lsp.buf.hover({
				border = "rounded",
				max_width = 80,
				max_height = 20,
			})
		end, opts("LSP hover"))

		-- Code navigation.
		map("n", "gd", vim.lsp.buf.definition, opts("Go to definition"))
		map("n", "gD", vim.lsp.buf.declaration, opts("Go to declaration"))
		map("n", "gi", vim.lsp.buf.implementation, opts("Go to implementation"))
		map("n", "gr", vim.lsp.buf.references, opts("Find references"))
		map("n", "gt", vim.lsp.buf.type_definition, opts("Go to type definition"))

		-- Workspace/symbol tools.
		map("n", "<leader>rn", vim.lsp.buf.rename, opts("Rename symbol"))
		map("n", "<leader>ca", vim.lsp.buf.code_action, opts("Code action"))
		map("n", "<leader>oi", function()
			vim.lsp.buf.code_action({
				context = {
					only = { "source.organizeImports" },
					diagnostics = {},
				},
				apply = true,
			})
		end, opts("Organize imports"))
		map("n", "<leader>ds", vim.lsp.buf.document_symbol, opts("Document symbols"))
		map("n", "<leader>ws", vim.lsp.buf.workspace_symbol, opts("Workspace symbols"))

		-- Diagnostics.
		map("n", "<leader>e", function()
			vim.diagnostic.open_float({
				border = "rounded",
				source = "if_many",
			})
		end, opts("Line diagnostic"))

		map("n", "[d", function()
			vim.diagnostic.jump({
				count = -1,
				float = true,
			})
		end, opts("Previous diagnostic"))

		map("n", "]d", function()
			vim.diagnostic.jump({
				count = 1,
				float = true,
			})
		end, opts("Next diagnostic"))

		map("n", "[e", function()
			vim.diagnostic.jump({
				count = -1,
				severity = vim.diagnostic.severity.ERROR,
				float = true,
			})
		end, opts("Previous error"))

		map("n", "]e", function()
			vim.diagnostic.jump({
				count = 1,
				severity = vim.diagnostic.severity.ERROR,
				float = true,
			})
		end, opts("Next error"))

		map("n", "<leader>xq", vim.diagnostic.setloclist, opts("Diagnostics location list"))

		-- Toggle inlay hints if supported by the server.
		if vim.lsp.inlay_hint then
			map("n", "<leader>ih", function()
				local enabled = vim.lsp.inlay_hint.is_enabled({
					bufnr = buf,
				})

				vim.lsp.inlay_hint.enable(not enabled, {
					bufnr = buf,
				})
			end, opts("Toggle inlay hints"))
		end
	end,
})
