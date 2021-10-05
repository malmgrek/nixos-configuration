{ config, lib, pkgs, ... }:

{

  home-manager.users.malmgrek = {

    programs = {
      firefox = {
        enable = true;
        profiles."malmgrek.default" = {
          isDefault = true;
          name = "malmgrek.default";
          settings = {
            "browser.startup.homepage" = "https://nixos.org";
            "browser.uidensity" = 1;
          };
        };
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          https-everywhere
          privacy-badger
          vim-vixen
        ];
      };
    };

  };

}
