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
      default = pkgs.emacs;
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
        imagemagick  # For image-dired
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
        ccls
        # :lang javascript
        nodePackages.javascript-typescript-langserver
        # :lang latex & :lang org (latex previews)
        # NOTE: Include LaTeX later. Downloading a myriad packages
        # is annoying.
        # texlive.combined.scheme-medium
        # :lang rust
        rustfmt
        rls

      ];
      # TODO env.PATH = ...
      # zsh.rc = lib.readfile <config/emacs/aliases.zsh>;
    };

    fonts.fonts = [
      pkgs.emacs-all-the-icons-fonts
    ];

  };

}
