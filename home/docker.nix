{ config, lib, pkgs, ... }:

let userName = config.customParams.userName;
in {

  virtualisation.docker = {
    enable = false;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  users.users.${userName}.packages = with pkgs; [
    docker
    docker-compose
  ];
}
