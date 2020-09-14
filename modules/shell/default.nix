{ config, lib, pkgs, ... }:

{
  imports = [
    ./direnv.nix
    ./git.nix
    ./gnupg.nix
    ./pass.nix
    ./ranger.nix
    ./tmux.nix
    ./zsh.nix
    ./weechat.nix
  ];
}
