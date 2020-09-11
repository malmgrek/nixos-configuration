# modules/browser/firefox.nix --- https://www.mozilla.org/en-US/firefox
#
# Oh firefox, gateway to the interwebs, devourer of ram. Give onto me your
# infinite knowledge and shelter me from ads.

{ config, options, lib, pkgs, ... }:
with lib;
{
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
      nur
      (makeDesktopItem {
        name = "firefox-private";
        desktopName = "Firefox (Private)";
        genericName = "Open a private Firefox window";
        icon = "firefox";
        exec = "${firefox-bin}/bin/firefox --private-window";
        categories = "Network";
      })
    ];

    # my.env.XDG_DESKTOP_DIR = "$HOME"; # (try to) prevent ~/Desktop

    # # Use a stable profile name so we can target it in themes
    # my.home.home.file =
    #   let cfg = config.modules.desktop.browsers.firefox; in
    #   {
    #     ".mozilla/firefox/profiles.ini".text = ''
    #       [Profile0]
    #       Name=default
    #       IsRelative=1
    #       Path=${cfg.profileName}.default
    #       Default=1

    #       [General]
    #       StartWithLastProfile=1
    #       Version=2
    #     '';
    #   };

    my.home.programs.firefox.profiles."${cfg.profileName}" = {
      isDefault = true;
      name = "${cfg.profileName}";
      settings = {
        browser.startup.homepage = "https://nixos.org";
      };
    }

    # TODO Extensions. Requires installing NUR
    # my.home.programs.firefox.extensions = with pkgs.nur.repos.rycee.firefox-addons; [
    #   https-everywhere
    #   privacy-badger
    # ];

  };
}
