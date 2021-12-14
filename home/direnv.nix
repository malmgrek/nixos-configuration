{ config, lib, pkgs, ... }:

{
  home-manager.users.${config.customParams.userName} = {
    programs = {
      direnv = {
        enable = true;
        # Adds `eval "$(direnv hook zsh)"` into .zshrc
        enableZshIntegration = true;
      };
    };
  };
}
