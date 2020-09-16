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

  # Add custom packages & unstable channel, so they can be accessed via pkgs.*
  nixpkgs.overlays = import ./packages;
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Basic command line tools
    coreutils
    git
    killall
    unzip
    wget
    sshfs
    gnumake
    htop

    # VPN
    openvpn

    # Password hash generator
    mkpasswd
    openssl

    # Editors
    vim

    # Image processing
    imagemagick

    # Instant nix-shell scripts
    my.cached-nix-shell
  ];

  my.user = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "networkmanager" "video" ];
    shell = pkgs.zsh;
  };

  system.stateVersion = "20.03";  # Don't change!

}
