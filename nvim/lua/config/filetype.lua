vim.filetype.add({
	extension = {
		tf = "terraform",
		tfvars = "terraform-vars",
	},

	pattern = {
		-- Neovim's builtin table maps *.tmpl -> "template", which has no
		-- treesitter parser and no LSP. Go-templated YAML (Helm charts,
		-- config generators) is far more useful as yaml, with the {{ }}
		-- regions injected as gotmpl.
		-- See after/queries/yaml/injections.scm.
		[".*%.ya?ml%.tmpl"] = "yaml",
	},
})
