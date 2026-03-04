{
  config,
  lib,
  pkgs,
  ...
}:

# NOTE: After migrating the config directory from .emacs.d to .config/emacs,
# there is the issue that Emacs auto-generates .emacs.d/ with vanilla config.
# A potential solution is to define environment variable EMACS_USER_DIRECTORY
# and running `doom env` which puts the environment variable into the doom env
# file.

{

  fonts.packages = [ pkgs.emacs-all-the-icons-fonts ];

  home-manager.users.${config.customParams.userName} = {

    xdg.configFile."doom/config.el" = {
      source = pkgs.replaceVars ../config/doom/config.el {
        theme = if config.lightMode.enable then "doom-one-light" else "doom-vibrant";
        font =
          if config.hidpiHacks.enable then
            ''(font-spec :family "monospace" :size 12.0)''
          else
            ''(font-spec :family "monospace" :size 10.5)'';
      };
    };
    xdg.configFile."doom/init.el" = {
      source = ../config/doom/init.el;
    };
    xdg.configFile."doom/packages.el" = {
      source = ../config/doom/packages.el;
    };
    xdg.configFile."doom/my" = {
      source = ../config/doom/my;
      recursive = true;
    };

    home.sessionPath = [ "$XDG_CONFIG_HOME/emacs/bin" ];

    # Doom dependencies
    home.packages = with pkgs; [

      # emacsUnstable  # bleeding edge
      # emacs  # default
      ((emacsPackagesFor emacs).emacsWithPackages (epkgs: [
        epkgs.vterm
        # epkgs.lsp-bridge  # Fast LSP client but not much faster than emacs-lsp-booster
      ]))

      (ripgrep.override { withPCRE2 = true; }) # Perl compatible regex
      gcc

      # NOTE: Fix error when launching Emacs from shell
      gnutls
      gtk3
      glib
      ######

      gsettings-desktop-schemas
      fd # opt: Faster projectile indexing
      pinentry-emacs # opt: Gnupg prompts in Emacs
      zstd # opt: Undo-fu-session/undo-tree compression
      aspell
      aspellDicts.en
      aspellDicts.en-computers
      aspellDicts.en-science
      languagetool
      editorconfig-core-c
      sqlite
      python312Packages.ruff # Python formatter
      nodePackages.prettier # JavaScript formatter

      # Language servers
      emacs-lsp-booster
      metals # Scala language server
      ty
      pyright
      basedpyright
      typescript-language-server # TypeScript/JavaScript language server
      nixd

      # ccls                                           # C/C++ language server
      # rls                                            # Rust language server

      # texlive.combined.scheme-medium
      # rustfmt

      # mu4e                                           # Emacs as email client
      # mu
      # isync

      #
      # NOTE: Grammars for tree-sitter can be installed directly in Emacs with
      # - "treesit-install-grammar...". –> At least select tsx and typescript from the list.
      # - Also Python can be installed, type "python" and install from sources.
      # - Installs under ~/.emacs.d/.local
      #
      # See also: https://github.com/doomemacs/doomemacs/tree/master/modules/tools/tree-sitter
      #
      # These are not recognized by Doom Emacs when installed :(
      #
      # tree-sitter-grammars.tree-sitter-typescript
      # tree-sitter-grammars.tree-sitter-tsx
      tree-sitter-grammars.tree-sitter-python
      #
      # NOTE: Good linting is available through LSP servers
      # Install: lsp-install-server -> select from list
      #

    ];

  };

}
