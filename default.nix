{ pkgs, options, lib, config, ... }:
let
  # TODO/FIXME Parametrize these hard coded values
  device = "phoe";
  username = "malmgrek";
in {

  networking.hostName = lib.mkDefault device;
  my.username = username;

  imports = [
    ./modules
    "${./hosts}/${device}"
  ];

  # NixOS
  nix.autoOptimiseStore = true;
  nix.nixPath = options.nix.nixPath.default ++ [
    # So we can use absolute import paths
    "bin=/home/${username}/nixos-configuration/bin"
    "config=/home/${username}/nixos-configuration/config"
  ];

  # nixpkgs.overlays = import ./packages;
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    coreutils
    git
    killall
    unzip
    vim
    wget
    sshfs
    gnumake
  ];

  my.user = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "networkmanager" "video" ];
    shell = pkgs.zsh;
  };

  system.stateVersion = "20.03";  # Don't change!

}
