{ config, lib, pkgs, ... }:

{

  imports = [
    ./bspwm.nix
    ./i3.nix
    ./apps
    ./term
    ./browsers
  ];

}
