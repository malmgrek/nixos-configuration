{ config, lib, pkgs, ... }:

{

  virtualisation = {
    docker = {
      enable = true;
      autoPrune.enable = true;
      enableOnBoot = false;
    };
  };

  home-manager.users.${config.customParams.userName} = {
    home.packages = with pkgs; [
      docker
      docker-compose
    ];
  };

  users.users.${config.customParams.userName}.extraGroups = [ "docker" ];

}
