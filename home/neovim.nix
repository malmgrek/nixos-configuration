{ config, pkgs, ... }:

{

  # The NixOS module writes nothing into the home directory, so no
  # sideloadInitLua equivalent is needed: `config/nvim` stays live and the
  # provider paths reach neovim through its wrapper.
  #
  # viAlias and vimAlias default to false here and stay off: `vi`, `vim` and
  # `vimdiff` are vim's own symlinks, and neovim's diff mode is `nvim -d`.
  programs.neovim = {
    enable = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = true;
  };

  users.users.${config.customParams.userName}.packages = with pkgs; [
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

}
