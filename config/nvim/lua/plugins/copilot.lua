-- Copilot never attaches on its own; <leader>aC opts the current buffer in.
local secret_patterns = {
	"/%.env", "authinfo", "netrc", "secret", "credential", "npmrc", "pypirc",
	"/%.ssh/", "/%.gnupg/", "/%.password%-store/", "/%.aws/", "/%.kube/", "/%.docker/", "/gh/hosts",
	"/id_rsa", "/id_ed25519", "/id_ecdsa", "/id_dsa",
	"%.gpg$", "%.age$", "%.pem$", "%.key$", "%.p12$", "%.pfx$", "%.kdbx$",
}

local function secret_path(bufnr)
	local path = vim.fn.resolve(vim.api.nvim_buf_get_name(bufnr or 0)):lower()
	for _, p in ipairs(secret_patterns) do
		if path:find(p) then
			return path
		end
	end
end

return {
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		-- init runs at startup without loading the plugin, so a secret file is
		-- refused before any Copilot code exists in the session.
		init = function()
			vim.keymap.set("n", "<leader>aC", function()
				local path = secret_path(0)
				if path then
					return vim.notify("Copilot refused: " .. path .. " looks like a secret file", vim.log.levels.ERROR)
				end
				-- Load explicitly: lazy's :Copilot stub drops the bang on first use.
				require("lazy").load({ plugins = { "copilot.lua" } })
				-- force bypasses should_attach below, for this buffer only.
				vim.cmd("Copilot! attach")
			end, { desc = "Copilot in this buffer" })
		end,
		config = function(_, opts)
			require("copilot").setup(opts)
			-- Guard the attach itself, so `:Copilot! attach` and every other route pass here.
			local client = require("copilot.client")
			local buf_attach = client.buf_attach
			client.buf_attach = function(force, bufnr)
				local path = secret_path(bufnr)
				if path then
					-- Unforced calls are the plugin's own attempt on every buffer open: refuse quietly.
					if force then
						vim.notify("Copilot refused: " .. path .. " looks like a secret file", vim.log.levels.ERROR)
					end
					return
				end
				return buf_attach(force, bufnr)
			end
		end,
		opts = {
			-- Attaching sends the whole buffer to the server, so it only happens by hand.
			should_attach = function()
				return false, "Copilot is opt-in per buffer: <leader>aC"
			end,
			suggestion = {
				enabled = true,
				auto_trigger = true,
				debounce = 75,
				keymap = {
					accept = "<M-l>", -- Alt+l to accept
					accept_word = "<M-w>", -- Alt+w to accept word
					accept_line = "<M-j>", -- Alt+j to accept line
					next = "<M-]>", -- Alt+] for next suggestion
					prev = "<M-[>", -- Alt+[ for previous suggestion
					dismiss = "<C-]>", -- Ctrl+] to dismiss
				},
			},
			panel = {
				enabled = true,
				auto_refresh = true,
				keymap = {
					jump_prev = "[[",
					jump_next = "]]",
					accept = "<CR>",
					refresh = "gr",
					open = "<M-CR>", -- Alt+Enter to open panel
				},
				layout = {
					position = "bottom", -- | top | left | right
					ratio = 0.4,
				},
			},
			copilot_node_command = "node", -- Node.js version must be > 18.x
			server_opts_overrides = {
				settings = {
					advanced = {
						listCount = 10, -- Number of suggestions to fetch
						inlineSuggestCount = 3, -- Number of inline suggestions
					},
				},
			},
		},
	},
}
