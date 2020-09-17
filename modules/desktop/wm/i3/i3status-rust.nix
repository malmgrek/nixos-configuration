{ config, options, lib, pkgs }:
with lib;
{

  options.modules.desktop.wm.i3.i3status-rust = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.desktop.wm.i3.i3status-rust.enable {
    environment.systemPackages = with pkgs; [
      i3status-rust
    ];
    my = {
      home.xdg.configFile."i3/status.toml" = {
        source = <config/i3/status.toml>;
        recursive = true;
      };
      i3.cfg = ''
        # i3status-rust configuration
        bar {
            font pango:DejaVu Sans Mono, FontAwesome 12
            position top
            status_command i3status-rs ~/.config/i3/status.toml
            colors {
                separator #666666
                background #222222
                statusline #dddddd
                focused_workspace #0088CC #0088CC #ffffff
                active_workspace #333333 #333333 #ffffff
                inactive_workspace #333333 #333333 #888888
                urgent_workspace #2f343a #900000 #ffffff
            }
        }

      '';
    };
  };

}
