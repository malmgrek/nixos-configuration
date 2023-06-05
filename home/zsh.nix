{ config, lib, pkgs, ... }:

{

  users.users.${config.customParams.userName}.shell = pkgs.zsh;

  home-manager.users.${config.customParams.userName} = {

    programs = {
      direnv = {
        enable = true;
        # Adds `eval "$(direnv hook zsh)"` into .zshrc
        enableZshIntegration = true;
      };
      fzf = {
        enable = true;
        enableZshIntegration = true;
      };
      autojump = {
        enable = true;
        enableZshIntegration = true;
      };
      zsh = {
        enable = true;  # TODO: Already set in common.nix, is this necessary?
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
          # . ~/.zshaliases
        '';
        envExtra = ''
          export TERM=xterm-256color
          export LS_COLORS=""
          export KEYTIMEOUT=1
        '';
        plugins = [
          {
            name = "zsh-autosuggestions";
            src = pkgs.fetchFromGitHub {
              owner = "zsh-users";
              repo = "zsh-autosuggestions";
              rev = "v0.7.0";
              sha256 = "sha256-KLUYpUu4DHRumQZ3w59m9aTW6TBKMCXl2UcKi4uMd7w=";
            };
          }
          {
            name = "zsh-autopair";
            src = pkgs.fetchFromGitHub {
              owner = "hlissner";
              repo = "zsh-autopair";
              rev = "v1.0";
              sha256 = "sha256-wd/6x2p5QOSFqWYgQ1BTYBUGNR06Pr2viGjV/JqoG8A=";
            };
          }
          {
            name = "zsh-completions";
            src = pkgs.fetchFromGitHub {
              owner = "zsh-users";
              repo = "zsh-completions";
              rev = "0.34.0";
              sha256 = "sha256-qSobM4PRXjfsvoXY6ENqJGI9NEAaFFzlij6MPeTfT0o=";
            };
          }
          {
            name = "zsh-syntax-highlighting";
            src = pkgs.fetchFromGitHub {
              owner = "zsh-users";
              repo = "zsh-syntax-highlighting";
              rev = "0.7.1";
              sha256 = "sha256-gOG0NLlaJfotJfs+SUhGgLTNOnGLjoqnUp54V9aFJg8=";
            };
          }
          {
            name = "pure";
            src = pkgs.fetchFromGitHub {
              owner = "sindresorhus";
              repo = "pure";
              rev = "v1.21.0";
              sha256 = "sha256-YfasTKCABvMtncrfoWR1Su9QxzCqPED18/BTXaJHttg=";
            };
          }
        ];
      };
    };

  };

}
