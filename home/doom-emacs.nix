{ config, lib, pkgs, ... }:

{

  fonts.packages = [ pkgs.emacs-all-the-icons-fonts ];

  home-manager.users.${config.customParams.userName} = {

    home.file.".doom.d/config.el" = {
      source = pkgs.replaceVars ../config/doom-emacs/config.el {
        theme = if config.lightMode.enable then "doom-one-light"
                else "doom-vibrant";
        font = if config.hidpiHacks.enable
               then ''(font-spec :family "monospace" :size 12.0)''
               else ''(font-spec :family "monospace" :size 10.5)'';
      };
    };
    home.file.".doom.d/init.el" = {
      source = ../config/doom-emacs/init.el;
    };
    home.file.".doom.d/packages.el" = {
      source = ../config/doom-emacs/packages.el;
    };
    home.file.".doom.d/themes" = {
      source = ../config/doom-emacs/themes;
      recursive = true;
    };

    # Doom dependencies
    home.packages = with pkgs; [

      # Bleeding edge Emacs
      # emacsUnstable

      # Regular NixPkgs Emacs
      # emacs
      ((emacsPackagesFor emacs).emacsWithPackages (epkgs: [
        epkgs.vterm
      ]))

      (ripgrep.override {withPCRE2 = true;})  # Perl compatible regex
      gcc

      # NOTE: Fix error when launching Emacs from shell
      gnutls
      gtk3
      glib
      ######

      gsettings-desktop-schemas
      fd                                               # opt: Faster projectile indexing
      pinentry-emacs                                   # opt: Gnupg prompts in Emacs
      zstd                                             # opt: Undo-fu-session/undo-tree compression
      aspell
      aspellDicts.en
      aspellDicts.en-computers                         #
      aspellDicts.en-science
      languagetool
      editorconfig-core-c
      sqlite
      python312Packages.ruff                           # Python formatter
      nodePackages.prettier                            # JavaScript formatter
      metals                                           # Scala language server
      basedpyright
      pyright
      # ccls                                           # C/C++ language server
      # nodePackages.javascript-typescript-langserver  #
      # texlive.combined.scheme-medium
      # rustfmt
      # rls                                            # Rust language server

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
      # tree-sitter-grammars.tree-sitter-python
      #

    ];

  };

}


