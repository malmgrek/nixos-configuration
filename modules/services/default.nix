{ config, lib, pkgs, ... }:

{
  imports = [
    ./docker.nix
    ./nginx.nix
    ./sshd.nix
  ];
}
