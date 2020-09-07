{ config, options, lib, pkgs, ... }:

with lib;
{
  options.modules.desktop.apps.rofi = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  # TODO Add config
  config = {
    my = {
      packages = with pkgs; [
        (writeScriptBin "rofi" ''
          #!${stdenv.shell}
          exec ${rofi}/bin/rofi -terminal xst -m -1 "$@"
          '')
      ];
    };
  };

}
