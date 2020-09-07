{ config, options, lib, pkgs, ... }:
with lib;
{

  # TODO Unify style: options = {...}
  options.modules.desktop.browsers.firefox = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    profileName = mkOption {
      type = types.str;
      default = config.my.username;
    };
  };

  config = mkIf config.modules.desktop.browsers.firefox.enable {
    my.packages = with pkgs; [
      firefox-bin
      # TODO makeDesktopItem
    ];
    # TODO XDG / home-manager stuff starts here
  }

}
