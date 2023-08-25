local M = {}
function M.config()
	local configs = require("nvim-treesitter.configs")

	configs.setup({
		ensure_installed = {
			"bash",
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
		}, -- put the language you want in this array
		-- ensure_installed = "all", -- one of "all" or a list of languages
		sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)

		highlight = {
			enable = true, -- false will disable the whole extension
		},
	})
end

return M
