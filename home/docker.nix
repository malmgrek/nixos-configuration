{ config, lib, pkgs, ... }:

{

  virtualisation = {
    docker = {
      enable = true;
      autoPrune.enable = true;
      enableOnBoot = false;
    };
  };

  home-manager.users.malmgrek = {
    home.packages = with pkgs; [
      docker
      docker-compose
    ];
  };

  users.users.malmgrek.extraGroups = [ "docker" ];

}
