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
        autojump
        bat
        exa
        fasd
        fd
        fzf
        nix-zsh-completions
        tldr
        tree
        zsh
      ];

      env.ZDOTDIR = "$XDG_CONFIG_HOME/zsh";
      env.ZSH_CACHE = "$XDG_CACHE_HOME/zsh";

      alias.exa = "exa --group-directories-first";
      alias.l = "exa -l";
      alias.ll = "exa -lg";
      alias.la = "LC_COLLATEC=C exa -la";
      alias.sc = "systemctl";
      alias.ssc = "sudo systemctl";

      # Write it recursively so other modules can write files to it
      home.xdg.configFile."zsh" = {
        source = <config/zsh>;
        recursive = true;
      };

      # Enable autojump in zsh
      zsh.rc = ''source ${pkgs.autojump}/share/autojump/autojump.zsh'';
    };

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      # TODO enableGlobalCompInit = false;
      promptInit = "";
    };

    system.userActivationScripts.cleanupZgen = "rm -fv $XDG_CACHE_HOME/zsh/*";

  };

}
