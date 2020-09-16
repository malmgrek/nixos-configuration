{ config, lib, pkgs, ... }:

{

  imports = [
    ./i3.nix
    ./apps
    ./term
    ./browsers
  ];

}
