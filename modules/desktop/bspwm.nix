{ config, options, lib, pkgs, ... }:
with lib;
{

  imports = [
    ./common.nix
  ];

  options.modules.desktop.bspwm = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.desktop.bspwm.enable {
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
      # redshift.enable = true;
      xserver = {
        enable = true;

        # Eventually one can remove this but
        # its here for now to stabilize bspwm configs
        autorun = false;
        layout = "fi";  # TODO A better place for this definition?

        displayManager.defaultSession = "none+bspwm";
        displayManager.lightdm.enable = true;
        # FIXME When enabled, won't accept my password
        displayManager.lightdm.greeters.mini.enable = true;
        windowManager.bspwm.enable = true;
      };
    };
  };

}
