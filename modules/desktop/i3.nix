
{ config, options, lib, pkgs, ... }:
with lib;
{
  imports = [
    ./common.nix
  ];

  options.modules.desktop.bspwm = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.desktop.bspwm.enable {
    environment.systemPackages = with pkgs; [
      lightdm
      dmenu
      i3status
      i3lock
      i3blocks
    ];

    services = {
      picom.enable = true;
      xserver = {
        enable = true;
        displayManager.defaultSession = "none+i3";
        displayManager.lightdm.enable = true;
        displayManager.lightdm.greeters.mini.enable = true;
        windowManager.i3.enable = true;
      };
    };

  };
}
