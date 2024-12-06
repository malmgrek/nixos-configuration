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
      # starship = {
      #   enable = true;
      #   enableZshIntegration = true;
      # };
      zsh = {
        enable = true;  # TODO: Already set in common.nix, is this necessary?
        defaultKeymap = "viins";
        shellAliases = {
          zcp = "zmv -C";
          zln = "zmv -L";
          ls = "eza";
          ll = "eza -l";
          lla = "eza -la";
          llt = "eza -T";
          llfu = "eza -bghGliS --git";
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
        #
        # Zplug: Results in a much slower shell startup
        #
        # zplug = {
        #   enable = true;
        #   plugins = [
        #     { name = "zsh-users/zsh-autosuggestions"; }
        #     { name = "hlissner/zsh-autopair"; tags = [ "defer:2" ]; }
        #     { name = "zsh-users/zsh-completions"; }
        #     { name = "zsh-users/zsh-syntax-highlighting"; }
        #     # Pure theme requires the two below plugins
        #     # { name = "mafredri/zsh-async"; tags = [ "from:github" ]; }
        #     # { name = "sindresorhus/pure"; tags = [ "use:pure.zsh" "from:github" "as:theme" ]; }
        #     # Powerlevel10k
        #     # { name = "romkatv/powerlevel10k"; tags = [ "as:theme" "depth:1" ]; }
        #   ];
        # };
        plugins = with pkgs; [
          {
            name = "zsh-autosuggestions";
            src = fetchFromGitHub {
              owner = "zsh-users";
              repo = "zsh-autosuggestions";
              rev = "v0.7.1";
              sha256 = "sha256-vpTyYq9ZgfgdDsWzjxVAE7FZH4MALMNZIFyEOBLm5Qo=";
            };
          }
          {
            name = "zsh-autopair";
            src = fetchFromGitHub {
              owner = "hlissner";
              repo = "zsh-autopair";
              rev = "v1.0";
              sha256 = "sha256-wd/6x2p5QOSFqWYgQ1BTYBUGNR06Pr2viGjV/JqoG8A=";
            };
          }
          {
            name = "zsh-completions";
            src = fetchFromGitHub {
              owner = "zsh-users";
              repo = "zsh-completions";
              rev = "0.35.0";
              sha256 = "sha256-GFHlZjIHUWwyeVoCpszgn4AmLPSSE8UVNfRmisnhkpg=";
            };
          }
          {
            name = "zsh-syntax-highlighting";
            src = fetchFromGitHub {
              owner = "zsh-users";
              repo = "zsh-syntax-highlighting";
              rev = "0.8.0";
              sha256 = "sha256-iJdWopZwHpSyYl5/FQXEW7gl/SrKaYDEtTH9cGP7iPo=";
            };
          }
          {
            name = "pure";
            src = fetchFromGitHub {
              owner = "sindresorhus";
              repo = "pure";
              rev = "v1.23.0";
              sha256 = "sha256-BmQO4xqd/3QnpLUitD2obVxL0UulpboT8jGNEh4ri8k=";
              # NOTE: Use this as template to get the specified/got message
              # sha256 = "0gj89pj0zlm90ix3m1qpzzda8ih24iqhpjm7mh9004a6ga8ih82l"
            };
          }
        ];
      };
    };

  };

}
