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
-- Filetypes
-- ---------------------------------------------------------------------------

vim.filetype.add({
	extension = {
		tf = "terraform",
		tfvars = "terraform-vars",
	},
})

-- ---------------------------------------------------------------------------
-- Diagnostics
-- ---------------------------------------------------------------------------

vim.diagnostic.config({
	virtual_text = {
		spacing = 4,
		source = "if_many",
		prefix = "●",
	},
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
		source = "if_many",
		header = "",
		prefix = "",
	},
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

vim.lsp.enable({
	"gopls",
	"basedpyright",
	"lua_ls",
	"terraformls",
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

		map("n", "<leader>q", vim.diagnostic.setloclist, opts("Diagnostics location list"))

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
