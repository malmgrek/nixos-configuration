{ config, lib, pkgs, ... }:

{

  users.users.malmgrek.shell = pkgs.zsh;

  home-manager.users.malmgrek = {

    programs = {
      fzf = {
        enable = true;
        enableZshIntegration = true;
      };
      autojump = {
        enable = true;
        enableZshIntegration = true;
      };
      zsh = {
        enable = true;
        defaultKeymap = "viins";
        shellAliases = {
          zcp = "zmv -C";
          zln = "zmv -L";
          ls = "exa";
          ll = "exa -l";
          lla = "exa -la";
          llt = "exa -T";
          llfu = "exa -bghGliS --git";
        };
        history = {
          size = 10000;
          save = 10000;
        };
        initExtra = ''
          autoload zmv  # Better "mv"
        '';
        envExtra = ''
          export TERM=xterm-256color
          export LS_COLORS=""
          export KEYTIMEOUT=1
        '';
        enableCompletion = true;
        zplug = {
          enable = true;
          plugins = [
            { name = "zsh-users/zsh-autosuggestions"; }
            { name = "zsh-users/zsh-syntax-highlighting"; tags = [ defer:2 ]; }
            { name = "hlissner/zsh-autopair"; tags = [ defer:2 ]; }
            { name = "mafredri/zsh-async"; }  # Dependency of Pure
            { name = "sindresorhus/pure"; tags = [ use:pure.zsh as:theme ]; }
          ];
        };
      };
    };

    home.packages = with pkgs; [
      # autojump
      bat
      exa
      # fasd
      fd
      # nix-zsh-completions  # Automatically set with programs.zsh.enable ?
      tldr
      tree
    ];

  };

}
