{ config, lib, pkgs, ... }:

with lib; {

  options = {
    lightMode.enable = mkEnableOption "Light colorscheme in old school tools";
    customParams = {
      userName = mkOption {
        type = types.str;
        default = "malmgrek";
        description = "username of the main user";
      };
      dpi = mkOption {
        type = types.nullOr types.int;
        default = null;
        description = ''
          Display density to pin for the whole X session. Left unset, GTK and
          Firefox fall back to 96 while Alacritty and Emacs derive theirs from
          the current mode, so the two drift apart when the resolution changes.

          X11 has one global dpi and no per-output override, so a value above 96
          is wrong for any connected monitor that is not the dense one.
        '';
      };
    };
  };

  # Nothing here about the tty or boot menu: those follow the panel's pixel
  # count, not anything X reports.
  config = mkIf (config.customParams.dpi != null) {

    services.xserver = {
      # Two separate reads: the server's value (Emacs, the JDK) and the Xft.dpi
      # resource below (GTK, Qt, Firefox, Alacritty).
      dpi = config.customParams.dpi;
      # Merged after ~/.Xresources, so this value wins.
      displayManager.sessionCommands = ''
        ${pkgs.xrdb}/bin/xrdb -merge <<EOF
          Xft.dpi: ${toString config.customParams.dpi}
        EOF
      '';
    };

  };

}
