{ config, options, lib, pkgs, ... }:
with lib;
{

  options.modules.editors.emacs = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    pkg = mkOption {
      type = types.package;
      default = pkgs.emacsUnstable;
    };
  };

  config = mkIf config.modules.editors.emacs.enable {
    my = {
      packages = with pkgs; [

        # Doom dependencies
        config.modules.editors.emacs.pkg
        git
        (ripgrep.override {withPCRE2 = true;})
        gnutls  # for TLS connectivity

        # Optional dependencies
        fd  # Faster projectile indexing
        (lib.mkIf (config.programs.gnupg.agent.enable)
         pinentry_emacs)  # in-emacs gnupg prompts
        zstd  # for undo-fu-session/undo-tree compression

        # Module dependencies
        # :checkers spell
        aspell
        aspellDicts.en
        aspellDicts.en-computers
        aspellDicts.en-science
        # :checkers grammar
        languagetool
        # :tools editorconfig
        editorconfig-core-c  # per-project style coding
        # :tools lookup & :lang org +roam
        sqlite
        # :lang cc
        # ccls  # c/c++/obj-c language server
        # :lang javascript
        nodePackages.javascript-typescript-langserver
        # :lang latex & :lang org (latex previews)
        # texlive.combined.scheme-medium
        # :lang rust
        # rustfmt  # tool for formatting rust code
        # rls      # rust language server
      ];

      env.PATH = [ "$XDG_CONFIG_HOME/emacs/bin" ];
      # zsh.rc = lib.readfile <config/emacs/aliases.zsh>;
      home.home.file.".doom.d" = {
        source = <config/emacs>;
        recursive = true;
      };

    };

    fonts.fonts = [
      pkgs.emacs-all-the-icons-fonts
    ];

  };

}
