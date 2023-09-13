local lsp = require("lsp-zero")
local util = require("lspconfig.util")

lsp.preset("recommended")
lsp.configure("angularls", {
	root_dir = util.root_pattern("angular.json", "project.json"),
})

lsp.ensure_installed({
	"angularls",
	"cssls",
	"html",
	"jsonls",
	"pyright",
	"sqlls",
	"tsserver",
	"rust_analyzer",
	"yamlls",
	"pyright",
	"dockerls",
	"eslint",
	"graphql",
	"svelte",
	"tailwindcss",
	"lua_ls",
})

-- Fix Undefined global 'vim'
lsp.nvim_workspace()

local cmp = require("cmp")
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
	["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
	["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
	["<C-y>"] = cmp.mapping.confirm({ select = true }),
	["<C-Space>"] = cmp.mapping.complete(),
})

cmp_mappings["<Tab>"] = nil
cmp_mappings["<S-Tab>"] = nil

lsp.setup_nvim_cmp({
	mapping = cmp_mappings,
})

lsp.set_preferences({
	suggest_lsp_servers = false,
	sign_icons = {
		error = "E",
		warn = "W",
		hint = "H",
		info = "I",
	},
})

lsp.on_attach(function(client, bufnr)
	client.server_capabilities.documentFormattingProvider = false
	client.server_capabilities.documentRangeFormattingProvider = false

	local opts = { buffer = bufnr, remap = false }

	vim.keymap.set("n", "gd", function()
		vim.lsp.buf.definition()
	end, opts)
	vim.keymap.set("n", "K", function()
		vim.lsp.buf.hover()
	end, opts)
	vim.keymap.set("n", "<leader>vws", function()
		vim.lsp.buf.workspace_symbol()
	end, opts)
	vim.keymap.set("n", "<leader>vd", function()
		vim.diagnostic.open_float()
	end, opts)
	vim.keymap.set("n", "[d", function()
		vim.diagnostic.goto_next()
	end, opts)
	vim.keymap.set("n", "]d", function()
		vim.diagnostic.goto_prev()
	end, opts)
	vim.keymap.set("n", "<leader>vca", function()
		vim.lsp.buf.code_action()
	end, opts)
	vim.keymap.set("n", "<leader>vrr", function()
		vim.lsp.buf.references()
	end, opts)
	vim.keymap.set("n", "<leader>vrn", function()
		vim.lsp.buf.rename()
	end, opts)
	vim.keymap.set("i", "<C-h>", function()
		vim.lsp.buf.signature_help()
	end, opts)
	vim.keymap.set("n", "gD", function()
		vim.lsp.buf.declaration()
	end, opts)
	vim.keymap.set("n", "gI", function()
		vim.lsp.buf.implementation()
	end, opts)
	vim.keymap.set("n", "gr", function()
		vim.lsp.buf.references()
	end, opts)
	vim.keymap("n", "gl", function()
		vim.diagnostic.open_float()
	end, opts)
	vim.keymap("n", "<leader>lf", function()
		vim.lsp.buf.format({ async = true })
	end, opts)
	vim.keymap("n", "<leader>li", ":LspInfo", opts)
	vim.keymap("n", "<leader>la", function()
		vim.lsp.buf.code_action()
	end, opts)
	vim.keymap("n", "<leader>lj", function()
		vim.diagnostic.goto_next({ buffer = 0 })
	end, opts)
	vim.keymap("n", "<leader>lk", function()
		vim.diagnostic.goto_prev({ buffer = 0 })
	end, opts)
	vim.keymap("n", "<leader>lr", function()
		vim.lsp.buf.rename()
	end, opts)
	vim.keymap("n", "<leader>ls", function()
		vim.lsp.buf.signature_help()
	end, opts)
	vim.keymap("n", "<leader>lq", function()
		vim.diagnostic.setloclist()
	end, opts)
end)

lsp.setup()

local null_ls = require("null-ls")

require("mason-null-ls").setup({
	ensure_installed = {
		"prettier",
		"prettierd",
		"eslint_d",
		"firefox-debug-adapter",
		"gitlint",
		"black",
		"stylua",
		"nxls",
		"rustywind",
	},
})

local formatting = null_ls.builtins.formatting
local code_actions = null_ls.builtins.code_actions
local async_formatting = function(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()

	vim.lsp.buf_request(
		bufnr,
		"textDocument/formatting",
		vim.lsp.util.make_formatting_params({}),
		function(err, res, ctx)
			if err then
				local err_msg = type(err) == "string" and err or err.message
				-- you can modify the log message / level (or ignore it completely)
				vim.notify("formatting: " .. err_msg, vim.log.levels.WARN)
				return
			end

			-- don't apply results if buffer is unloaded or has been modified
			if not vim.api.nvim_buf_is_loaded(bufnr) or vim.api.nvim_buf_get_option(bufnr, "modified") then
				return
			end

			if res then
				local client = vim.lsp.get_client_by_id(ctx.client_id)
				vim.lsp.util.apply_text_edits(res, bufnr, client and client.offset_encoding or "utf-16")
				vim.api.nvim_buf_call(bufnr, function()
					vim.cmd("silent noautocmd update")
				end)
			end
		end
	)
end
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

null_ls.setup({
	sources = {
		formatting.prettier,
		formatting.black,
		formatting.stylua,
		code_actions.refactoring,
	},
	debug = false,
	on_attach = function(client, bufnr)
		if client.supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePost", {
				group = augroup,
				buffer = bufnr,
				callback = function()
					async_formatting(bufnr)
				end,
			})
		end
	end,
})

vim.diagnostic.config({
	virtual_text = true,
})
