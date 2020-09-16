
{ config, options, lib, pkgs, ... }:
with lib;
{
  imports = [
    ./misc.nix
  ];

  options.modules.desktop.i3 = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.desktop.i3.enable {
    environment.systemPackages = with pkgs; [
      arandr         # GUI for xrandr
      dmenu
      dunst
      i3status
      i3status-rust
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
      home.xdg.configFile."i3/status.toml" = {
        source = <config/i3/status.toml>;
        recursive = true;
      };
      i3.cfg = ''
        bindsym $mod+Return exec ${config.modules.desktop.term.default}
        ${lib.readFile <config/i3/config>}
      '';
    };

  };
}
