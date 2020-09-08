#!/usr/bin/env bash

function addNixOS() {
  nix-channel --add "https://nixos.org/channels/nixos-20.03" nixos
}

function addHomeManager() {
  nix-channel --add "https://github.com/rycee/home-manager/archive/release-20.03.tar.gz" home-manager
}

function addNixOSUnstable() {
  nix-channel --add "https://nixos.org/channels/nixpkgs-unstable" nixpkgs-unstable
}

function addAll() {
  addNixOS
  addHomeManager
  addNixOSUnstable
}
