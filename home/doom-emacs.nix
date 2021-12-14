{ config, lib, pkgs, ... }:

{

  fonts.fonts = [ pkgs.emacs-all-the-icons-fonts ];

  home-manager.users.${config.customParams.userName} = {

    # TODO: Configure font size in host specific directory.
    home.file.".doom.d" = {
      source = ../config/doom-emacs;
      recursive = true;
    };

    # Doom dependencies
    home.packages = with pkgs; [
      emacsUnstable
      (ripgrep.override {withPCRE2 = true;})  # Perl compatible regex
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
      # ccls  # C/C++ language server
      # nodePackages.javascript-typescript-langserver
      # texlive.combined.scheme-medium
      # rustfmt
      # rls  # Rust language server
    ];

  };

}
