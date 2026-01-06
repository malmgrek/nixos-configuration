-- Extra configuration for Avante.nvim
return {
	"yetone/avante.nvim",
	opts = {
		behaviour = {
			auto_apply_diff_after_generation = false, -- Disables automatic editing
			auto_approve_tool_permissions = false, -- Requires user approval
		},
		prompt_logger = { -- logs prompts to disk (timestamped, for replay/debugging)
			enabled = true, -- toggle logging entirely
			log_dir = vim.fn.stdpath("cache") .. "/avante_prompts", -- directory where logs are saved
			fortune_cookie_on_success = false, -- shows a random fortune after each logged prompt (requires `fortune` installed)
			next_prompt = {
				normal = "<C-n>", -- load the next (newer) prompt log in normal mode
				insert = "<C-n>",
			},
			prev_prompt = {
				normal = "<C-p>", -- load the previous (older) prompt log in normal mode
				insert = "<C-p>",
			},
			input = {
				prefix = "> ",
				height = 16, -- Height of the input window in vertical layout
			},
		},
	},
}
