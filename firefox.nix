{ config, options, lib, pkgs, ... }:
with lib;
{
  config = {

    environment = {
      systemPackages = with pkgs; [
        firefox
      ];
    };

  };
}
