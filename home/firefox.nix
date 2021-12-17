{ config, lib, pkgs, ... }:

{

  home-manager.users.${config.customParams.userName} = {

    programs = {
      firefox = {
        enable = true;
        profiles."${config.customParams.userName}.default" = {
          isDefault = true;
          name = "${config.customParams.userName}.default";
          settings = {
            "browser.startup.homepage" = "https://nixos.org";
            "browser.uidensity" = 1;
          };
        };
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          bypass-paywalls-clean
          https-everywhere
          privacy-badger
          ublock-origin
          vimium
        ];
      };
    };

  };

}
