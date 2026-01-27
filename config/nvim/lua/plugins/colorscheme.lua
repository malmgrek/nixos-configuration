return {
	-- 	-- TokyoNight colorscheme with excellent semantic token support
	-- 	{
	-- 		 "folke/tokyonight.nvim",
	-- 		 opts = {
	-- 		 	style = "moon", -- Options: "storm", "moon", "night", "day"
	-- 		 },
	-- 		-- Semantic tokens are enabled by default
	-- 		-- Explicit Python semantic highlighting support:
	-- 		-- - @lsp.type.selfKeyword → @variable.builtin (distinct color for 'self')
	-- 		-- - @lsp.type.decorator → @attribute (distinct color for decorators)
	-- 		-- - @lsp.type.parameter → @variable.parameter (distinct color for params)
	-- 		config = function()
	-- 			require("tokyonight").setup({
	-- 				style = "moon",
	-- 				on_highlights = function(hl, c)
	-- 					-- Make docstrings the same color as comments
	-- 					hl["@string.documentation.python"] = { link = "String" } -- { fg = c.comment, italic = true }
	-- 				end,
	-- 			})
	-- 		end,
	-- 	},
	-- OneDarkPro colorscheme
	-- {
	-- 	"olimorris/onedarkpro.nvim",
	-- 	priority = 1000,
	-- },
	{
		"navarasu/onedark.nvim",
		priority = 1000, -- make sure to load this before all the other start plugins
	},
	{
		"LazyVim/LazyVim",
		opts = {
			-- colorscheme = "tokyonight",
			colorscheme = "onedark",
		},
	},
}
