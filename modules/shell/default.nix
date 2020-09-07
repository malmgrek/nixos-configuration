{ config, lib, pkgs, ... }:

{
  imports = [
    ./git.nix
    # ./gnupg.nix
    # ./pass.nix
    # ./tmux.nix
    ./zsh.nix
  ]
}
