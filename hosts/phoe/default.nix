# Phoe -- my laptop

{ pkgs, ... }:
{

  imports = [
    ../common.nix
    ./hardware-configuration.nix
  ];

  # modules = {
  #   desktop = {
  #     bspwm.enable = true;
  #   };
  # };

}
