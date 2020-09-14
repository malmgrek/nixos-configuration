
{ config, options, lib, pkgs, ... }:
with lib;
{
  imports = [
    ./common.nix
  ];

  options.modules.desktop.i3 = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.desktop.i3.enable {
    environment.systemPackages = with pkgs; [
      arandr         # GUI for xrandr
      dmenu
      i3status
      i3status-rust
      i3lock
      i3blocks
      lightdm
      pavucontrol    # GUI for sound control
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

    # link recursively so other modules can link files in their folders
    my.home.xdg.configFile."i3" = {
      source = <config/i3>;
      recursive = true;
    };

  };
}
