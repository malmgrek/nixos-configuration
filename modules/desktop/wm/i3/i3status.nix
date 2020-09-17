{ config, options, lib, pkgs }:
with lib;
{

  options.modules.desktop.wm.i3.i3status = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.desktop.wm.i3.i3status.enable {
    environment.systemPackages = with pkgs; [
      i3status
    ];
    my = {
      i3.cfg = ''
        # Enable the bare bones i3status status bar

        bar {
                status_command i3status
        }

      '';
    };
  };

}
