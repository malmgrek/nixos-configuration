{ config, pkgs, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-21.05.tar.gz";
in {

  imports = [
    (import "${home-manager}/nixos")
  ];

  environment.variables = {
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_BIN_HOME = "$HOME/.local/bin";
  };

  home-manager.users.malmgrek = {

    xdg.configFile."alacritty/alacritty.yml".source = ./cfgs/alacritty/alacritty.yml;
    xdg.configFile."i3/config".source = ./cfgs/i3/config;
    xdg.configFile."i3/status.toml".source = ./cfgs/i3/status.toml;
    xdg.configFile.".vimrc" = {
      # The first time Vim is opened, something will break due to missing plugins.
      # Just launch the editor, and the config will force loading of missing packages.
      source = ./cfgs/vim/vimrc;
      target = "../.vimrc";
    };
    # xdg.configFile.".zshrc" = {
    #   source = ./cfgs/zsh/zshrc;
    #   target = "../.zshrc";
    # };

  };

}
