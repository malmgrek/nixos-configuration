{ config, lib, pkgs, ... }:

let userName = config.customParams.userName;
in {

  virtualisation.virtualbox = {
    host = {
      enable = true;
      enableExtensionPack = true;
      # package = pkgs.unstable.virtualbox;
    };
    # guest.enable = true;
  };

  users = {
    extraGroups.vboxusers.members = [ userName ];
  };

}
