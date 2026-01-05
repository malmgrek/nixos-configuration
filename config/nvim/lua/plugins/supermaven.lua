-- Supermaven: Alternative AI completion with excellent multi-line suggestions
-- Uncomment to use instead of or alongside Copilot
return {
  {
    "supermaven-inc/supermaven-nvim",
    enabled = false, -- Set to true to enable, false to disable
    event = "InsertEnter",
    opts = {
      keymaps = {
        accept_suggestion = "<Tab>",
        clear_suggestion = "<C-]>",
        accept_word = "<C-j>",
      },
      ignore_filetypes = { cpp = true },
      color = {
        suggestion_color = "#808080",
        cterm = 244,
      },
      log_level = "info", -- set to "off" to disable logging completely
      disable_inline_completion = false, -- disables inline completion for use with cmp
      disable_keymaps = false, -- disables built in keymaps for more manual control
    },
    config = function(_, opts)
      require("supermaven-nvim").setup(opts)
    end,
  },
}

