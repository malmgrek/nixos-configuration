{ config, lib, pkgs, ... }:

{

  fonts.fonts = [ pkgs.emacs-all-the-icons-fonts ];

  home-manager.users.${config.customParams.userName} = {

    # TODO: Configure font size in host specific directory.
    home.file.".doom.d/config.el" = {
      source = pkgs.substituteAll {
        src = ../config/doom-emacs/config.el;
        theme = if config.lightMode.enable then "doom-one-light"
                else "doom-one";
      };
    };
    home.file.".doom.d/init.el" = {
      source = ../config/doom-emacs/init.el;
    };
    home.file.".doom.d/packages.el" = {
      source = ../config/doom-emacs/packages.el;
    };

    # Doom dependencies
    home.packages = with pkgs; [

      # Bleeding edge Emacs
      emacsUnstable

      (ripgrep.override {withPCRE2 = true;})  # Perl compatible regex
      gcc
      gnutls
      fd              # opt: Faster projectile indexing
      pinentry_emacs  # opt: Gnupg prompts in Emacs
      zstd            # opt: Undo-fu-session/undo-tree compression
      aspell
      aspellDicts.en
      aspellDicts.en-computers
      aspellDicts.en-science
      languagetool
      editorconfig-core-c
      sqlite
      python3
      # ccls  # C/C++ language server
      # nodePackages.javascript-typescript-langserver
      # texlive.combined.scheme-medium
      # rustfmt
      # rls  # Rust language server

      # mu4e -- Emacs as email client
      # mu
      # isync

    ];

  };

}
