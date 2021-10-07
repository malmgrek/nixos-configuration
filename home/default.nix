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
    ./vim.nix
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
    # TODO: Resolve without Home Manager
    xsession.pointerCursor = {
      name = "Vanilla-DMZ";
      package = pkgs.vanilla-dmz;
      size = 128;
    };

    home.packages = with pkgs; [
      okular
      pass
      gimp
      inkscape
    ];


  };

}
