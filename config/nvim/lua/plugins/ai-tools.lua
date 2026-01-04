return {
  -- Avante: Cursor-like agentic AI
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    opts = {
      provider = "copilot",  -- or "openai" if you have API key
      auto_suggestions_provider = "copilot",
    },
    build = "make",  -- Requires make, gcc (provided by Nix)
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
  },
  
  -- Enhanced Copilot configuration
  {
    "zbirenbaum/copilot.lua",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<M-l>",  -- Alt+l (like Doom's company accept)
          next = "<M-]>",
          prev = "<M-[>",
        },
      },
      panel = { enabled = true },
      filetypes = {
        markdown = true,
        yaml = true,
      },
    },
  },
}
