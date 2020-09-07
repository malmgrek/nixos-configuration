{ config, options, pkgs, lib, ... }:
with lib;
{

  options.modules.shell.zsh = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.shell.zsh.enable {
    my = {
      packages = with pkgs; [
        zsh
        nix-zsh-completions
        bat
        exa
        fasd
        fd
        fzf
        htop
        tldr
        tree
      ]
      # env.ZDOTDIR = ...
      # env.ZSH_CACHE = ...
      alias.exa = "exa --group-directories-first";
      alias.l = "exa -l";
      alias.ll = "exa -lg";
      alias.la = "LC_COLLATEC=C exa -la";
      alias.sc = "systemctl";
      alias.ssc = "sudo systemctl";
      # TODO home.xdg.configFile."zsh" = {};
    };
  };

  program.zsh = {
    enable = true;
    enableCompletion = true;
    # TODO enableGlobalCompInit = false;
    promptInit = "";
  };

  # TODO system.userActivationScripts.cleanupZgen = ...;

}
