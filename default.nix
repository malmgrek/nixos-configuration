{ pkgs, options, lib, config, ... }:
let
  device = "phoe";
  username = "malmgrek";
in {

  networking.hostName = lib.mkDefault device;
  my.username = username;

  imports = [
    ./modules
    "${./hosts}/${device}"
  ];

  # nixpkgs.overlays = import ./packages;
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    coreutils
    git
    vim
    wget
    sshfs
    gnumake
  ];

  my.user = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  system.stateVersion = "20.03";  # Don't change!

}
