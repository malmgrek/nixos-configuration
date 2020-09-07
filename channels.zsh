#!/usr/bin/env bash

function add_channels() {
  nix-channel --add "https://nixos.org/channels/nixos-20.03" nixos
  nix-channel --add "https://github.com/rycee/home-manager/archive/release-20.03.tar.gz" home-manager
  nix-channel --add "https://nixos.org/channels/nixpkgs-unstable" nixpkgs-unstable
}
