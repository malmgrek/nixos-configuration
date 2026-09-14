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

  home-manager.users.${userName} = {
    home.packages = with pkgs; [
      docker
      docker-compose
    ];
  };
}
