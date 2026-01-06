return {
	-- TokyoNight colorscheme with excellent semantic token support
	{
		"folke/tokyonight.nvim",
		opts = {
			style = "moon", -- Options: "storm", "moon", "night", "day"
			-- Semantic tokens are enabled by default
			-- Explicit Python semantic highlighting support:
			-- - @lsp.type.selfKeyword → @variable.builtin (distinct color for 'self')
			-- - @lsp.type.decorator → @attribute (distinct color for decorators)
			-- - @lsp.type.parameter → @variable.parameter (distinct color for params)
		},
	},

	-- Alternative: OneDark (no semantic token support for Python)
	-- Uncomment to switch back:
	-- { "navarasu/onedark.nvim" },

	-- Configure LazyVim to load TokyoNight
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "tokyonight",
			-- To use OneDark instead, change to:
			-- colorscheme = "onedark",
		},
	},
}
