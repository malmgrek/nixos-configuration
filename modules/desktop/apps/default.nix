{ config, lib, pkgs, ... }:

{

  imports = [
    ./daw.nix
    ./graphics.nix
    ./rofi
    ./vm.nix
  ];

}
