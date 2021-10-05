{ config, pkgs, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-21.05.tar.gz";
in {

  imports = [
    (import "${home-manager}/nixos")
  ];

  fonts.fonts = [ pkgs.emacs-all-the-icons-fonts ];

  environment.variables = {
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_BIN_HOME = "$HOME/.local/bin";
  };

  home-manager.users.malmgrek = {

    # Xserver
    xsession.pointerCursor = {
      name = "Vanilla-DMZ";
      package = pkgs.vanilla-dmz;
      size = 128;
    };

    # Alacritty config files
    xdg.configFile."alacritty/alacritty.yml".source = ./config/alacritty/alacritty.yml;

    # i3 config files
    xdg.configFile."i3/config".source = ./config/i3/config;
    xdg.configFile."i3/status.toml".source = ./config/i3/status.toml;

    # Vim config files
    # FIXME: xdg.configFile -> home.file
    xdg.configFile.".vimrc" = {
      # The first time Vim is opened, something will break due to missing plugins.
      # Just launch the editor, and the config will force loading of missing packages.
      source = ./config/vim/vimrc;
      target = "../.vimrc";
    };

    # Emacs config files
    home.file.".doom.d" = {
      source = ./config/emacs;
      recursive = true;
    };

    home.packages = with pkgs; [

      # Terminal emulators
      alacritty

      # Doom Emacs dependencies
      emacsUnstable
      (ripgrep.override {withPCRE2 = true;})  # Perl compatible
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
      nodePackages.javascript-typescript-langserver
      # texlive.combined.scheme-medium
      # rustfmt
      # rls  # Rust language server

    ];

    programs = {
      firefox = {
        enable = true;
        profiles."malmgrek.default" = {
          isDefault = true;
          name = "malmgrek.default";
          settings = {
            "browser.startup.homepage" = "https://nixos.org";
            "browser.uidensity" = 1;
          };
        };
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          https-everywhere
          privacy-badger
          vim-vixen
        ];
      };
    };

  };

}
