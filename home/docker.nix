{ config, lib, pkgs, ... }:

{

  virtualization = {
    docker = {
      enable = true;
      autoPrune.enable = true;
      enableOnBoot = false;
    };
  };

  home-manager.users.malmgrek = {
    packages = with pkgs; [
      docker
      docker-compose
    ];
  };

  users.users.malmgrek.extraGroups = [ "docker" ];

}
