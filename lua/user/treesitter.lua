local configs = require("nvim-treesitter.configs")

configs.setup({
	ensure_installed = {
	-- "angular",
		"bash",
		"c",
		"css",
		"dockerfile",
		"git_config",
		"gitignore",
		"graphql",
		"html",
		"javascript",
		"json",
		"lua",
		"make",
		"python",
		"sql",
		"svelte",
		"typescript",
		"yaml",
		"vim",
	}, -- put the language you want in this array
	-- ensure_installed = "all", -- one of "all" or a list of languages
	sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)

	highlight = {
		enable = true, -- false will disable the whole extension
	},
})
