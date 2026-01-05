-- Enhanced Copilot configuration for multi-line suggestions
return {
	-- Configure copilot.lua for better multi-line suggestions
	{
		"zbirenbaum/copilot.lua",
		opts = {
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
			filetypes = {
				yaml = true,
				markdown = true,
				help = false,
				gitcommit = true,
				gitrebase = false,
				hgcommit = false,
				svn = false,
				cvs = false,
				["."] = false,
			},
			copilot_node_command = "node", -- Node.js version must be > 18.x
			server_opts_overrides = {
				trace = "verbose",
				settings = {
					advanced = {
						listCount = 10, -- Number of suggestions to fetch
						inlineSuggestCount = 3, -- Number of inline suggestions
					},
				},
			},
		},
	},

	-- Ensure copilot-cmp is properly configured if using completion engine
	{
		"zbirenbaum/copilot-cmp",
		optional = true,
		opts = {},
		config = function(_, opts)
			local copilot_cmp = require("copilot_cmp")
			copilot_cmp.setup(opts)
		end,
	},
}
