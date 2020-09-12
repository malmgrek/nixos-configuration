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
      (makeDesktopItem {
        name = "firefox-private";
        desktopName = "Firefox (Private)";
        genericName = "Open a private Firefox window";
        icon = "firefox";
        exec = "${firefox-bin}/bin/firefox --private-window";
        categories = "Network";
      })
    ];

    my.home.programs.firefox =
      let cfg = config.modules.desktop.browsers.firefox; in
      {
        enable = true;
        profiles."${cfg.profileName}.default" = {
          isDefault = true;
          name = "${cfg.profileName}.default";
          settings = {
            "browser.startup.homepage" = "https://nixos.org";
          };
        };
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          https-everywhere
          privacy-badger
          vimium-ff
        ];
      };

  };
}
