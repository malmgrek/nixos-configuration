{ config, lib, pkgs, ... }:

let userName = config.customParams.userName;
in {

  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
    enableOnBoot = false;
  };

  home-manager.users.${userName} = {
    home.packages = with pkgs; [
      docker
      docker-compose
    ];
  };


  users.users.${userName}.extraGroups = [ "docker" ];

}
