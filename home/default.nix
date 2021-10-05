{ config, pkgs, ... }:
let
  home-manager = builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/release-21.05.tar.gz";
in {

  imports = [
    (import "${home-manager}/nixos")
    ./alacritty.nix
    ./doom-emacs.nix
    ./firefox.nix
    ./zsh.nix
  ];

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

    # i3 config files
    xdg.configFile."i3/config".source = ../config/i3/config;
    xdg.configFile."i3/status.toml".source = ../config/i3/status.toml;

    # Vim config files
    home.file.".vimrc" = {
      # The first time Vim is opened, something will break due to missing plugins.
      # Just launch the editor, and the config will force loading of missing packages.
      source = ../config/vim/vimrc;
    };

    home.packages = with pkgs; [
      libreoffice
      okular
    ];


  };

}
