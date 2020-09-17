
{ config, options, lib, pkgs, ... }:
with lib;
{
  imports = [
    ./i3status.nix
    ./i3status-rust.nix
    ../misc.nix
  ];

  options.modules.desktop.wm.i3 = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.desktop.wm.i3.enable {
    # These will be available for all users which makes sense
    environment.systemPackages = with pkgs; [
      arandr         # GUI for xrandr
      dmenu
      dunst
      i3lock
      i3blocks
      libnotify      # Enables notify-send
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

    my = {
      i3.cfg = ''
        # Launch default terminal emulator
        bindsym $mod+Return exec ${config.modules.desktop.term.default}
        ${lib.readFile <config/i3/config>}

      '';
    };

  };
}
