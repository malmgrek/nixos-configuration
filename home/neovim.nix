{
  config,
  lib,
  pkgs,
  ...
}:

{
  home-manager.users.${config.customParams.userName} = {

    programs.neovim = {
      enable = true;
      # No aliases: neovim is `nvim` only, so `vi`, `vim` and `vimdiff` stay
      # vim's own symlinks and the live vimrc in vim.nix is actually read.
      # Neovim's diff mode is `nvim -d`, which is all vimdiffAlias wrapped.
      withNodeJs = true;
      withPython3 = true;
      withRuby = true;

      # The provider paths reach neovim as a wrapper `--cmd` argument instead of
      # being written to ~/.config/nvim/init.lua, which is this repository's own
      # file reached through the live link in dotfiles.nix. Without this,
      # home-manager's activation refuses to clobber it and fails.
      sideloadInitLua = true;

      extraPackages = with pkgs; [
        # Core build tools
        gcc
        gnumake
        tree-sitter
        cargo # For some Tree-sitter grammars

        # Search tools (Telescope)
        ripgrep
        fd
        fzf

        # Language servers
        lua-language-server
        nixd # Superior to nil for Nix
        typescript-language-server
        pyright
        basedpyright
        ruff
        yaml-language-server
        vscode-langservers-extracted # HTML/CSS/JSON
        marksman # Markdown
        statix # Nix linter
        dockerfile-language-server  # Dockerfiles
        hadolint  # Dockerfile linter

        # Formatters
        stylua
        nixfmt
        prettier
        python312Packages.ruff # You already have this for Emacs

        # Linters
        shellcheck
        markdownlint-cli2

        # Git integration
        lazygit

        # AI tools dependencies
        nodejs

        # Clipboard (you're using X11 based on your i3 config)
        xclip

        # Tree-sitter grammars (install via Nix for reliability)
        tree-sitter-grammars.tree-sitter-dockerfile
        tree-sitter-grammars.tree-sitter-nix
        tree-sitter-grammars.tree-sitter-lua
        tree-sitter-grammars.tree-sitter-python
        tree-sitter-grammars.tree-sitter-typescript
        tree-sitter-grammars.tree-sitter-tsx
        tree-sitter-grammars.tree-sitter-javascript
        tree-sitter-grammars.tree-sitter-json
        tree-sitter-grammars.tree-sitter-bash
        tree-sitter-grammars.tree-sitter-html
        tree-sitter-grammars.tree-sitter-css

        # GUI
        neovide

      ];
    };

    # Set EDITOR if not using Emacs
    home.sessionVariables = {
      EDITOR = lib.mkDefault "nvim"; # mkDefault allows Emacs to override
    };
  };
}
