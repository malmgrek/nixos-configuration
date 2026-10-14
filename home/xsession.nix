{ config, pkgs, ... }:

{
  # Home Manager wraps the several files cursor theming touches, so it is set
  # here rather than in options.nix.
  home-manager.users.${config.customParams.userName} = {
    home.packages = with pkgs; [
      xhost
    ];
    home.pointerCursor = {
      name = "Vanilla-DMZ";
      package = pkgs.vanilla-dmz;
      x11.enable = true;
    };
  };
}
