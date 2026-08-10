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
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withNodeJs = true;
      withPython3 = true;
      withRuby = true;

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

    # LazyVim configuration directory
    xdg.configFile."nvim" = {
      recursive = true;
      source = ../config/nvim;
    };

    # Set EDITOR if not using Emacs
    home.sessionVariables = {
      EDITOR = lib.mkDefault "nvim"; # mkDefault allows Emacs to override
      LIGHT_MODE = if config.lightMode.enable then "1" else "0";
    };
  };
}
