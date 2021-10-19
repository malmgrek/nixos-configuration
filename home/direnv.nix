{ config, lib, pkgs, ... }:

{
  home-manager.users.malmgrek = {
    programs = {
      direnv = {
        enable = true;
        # Adds `eval "$(direnv hook zsh)"` into .zshrc
        enableZshIntegration = true;
      };
    };
  };
}
