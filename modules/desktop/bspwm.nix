{ config, options, lib, pkgs, ... }:
with lib;
{

  imports = [
    ./common.nix
  ];

  options.module.desktop.bspwm = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIF config.modules.desktop.bspwm.enable {
    environment.systemPackages = with pkgs; [
      lightdm
      dunst
      libnotify
      (polybar.override {
        pulseSupport = true;
        nlSupport = true;
      })
    ];
    services = {
      picom.enable = true;
      # redshift.enable = true
      xserver = {
        enable = true;
        displayManager.defaultSession = "none+bspwm";
        displayManager.lightdm.enable = true;
        displayManager.lightdm.greeters.mini.enable = true;
        windowManager.bspwm.enable = true;
      };
    };
  };

}
