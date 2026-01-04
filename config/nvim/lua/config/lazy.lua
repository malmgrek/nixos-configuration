require("lazy").setup({
  spec = {
    -- Import LazyVim base
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    
    -- Doom-like discoverability
    { import = "lazyvim.plugins.extras.ui.edgy" },
    { import = "lazyvim.plugins.extras.editor.telescope" },
    { import = "lazyvim.plugins.extras.editor.aerial" },
    { import = "lazyvim.plugins.extras.util.project" },
    
    -- AI tools (the reason for switching!)
    { import = "lazyvim.plugins.extras.coding.copilot" },
    { import = "lazyvim.plugins.extras.coding.copilot-chat" },
    { import = "lazyvim.plugins.extras.ai.codeium" },  -- Alternative to Copilot
    { import = "lazyvim.plugins.extras.coding.blink" },
    
    -- Language support (based on your packages)
    { import = "lazyvim.plugins.extras.lang.nix" },
    { import = "lazyvim.plugins.extras.lang.python" },
    { import = "lazyvim.plugins.extras.lang.typescript" },
    { import = "lazyvim.plugins.extras.lang.markdown" },
    { import = "lazyvim.plugins.extras.lang.docker" },
    { import = "lazyvim.plugins.extras.lang.yaml" },
    
    -- Custom plugins
    { import = "plugins" },
  },
  
  defaults = {
    lazy = true,
  },
  
  checker = {
    enabled = true,
    notify = false,  -- Don't spam on startup
  },
  
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
