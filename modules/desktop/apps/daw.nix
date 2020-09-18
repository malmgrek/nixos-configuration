# Digital audio workstation
#
# LMMS is the heavy, and Sunvox the light solution, respectively.
#

{ config, options, lib, pkgs, ... }:
with lib;
{
  options.modules.desktop.apps.daw = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.desktop.apps.daw.enable {
    my.packages = with pkgs; [
      # lmms on stable is broken due to 'Could not find the Qt platform plugin
      # "xcb" in ""' error: https://github.com/NixOS/nixpkgs/issues/76074
      unstable.lmms   # for making music
      audacity   # for recording and remastering audio
      sunvox     # for making music (where LMMS is overkill)
    ];
  };
}
