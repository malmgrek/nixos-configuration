{ config, lib, pkgs, ... }:
let
  # Override broken package
  customVimPlugins = {
    vim-fugitive = pkgs.vimUtils.buildVimPlugin {
      name = "vim-fugitive";
      src = pkgs.fetchFromGitHub {
        owner = "tpope";
        repo = "vim-fugitive";
        rev = "d74a7cff4cfcf84f83cc7eccfa365488f3bbabc2";
        sha256 = "sha256-dsIuUz5o9Q44vrXz3U50d4inASoug8pR7zGXkBL5+t8=";
      };
    };
  };
in {
  home-manager.users.${config.customParams.userName} = {
    programs.vim = {
      enable = true;
      plugins = with pkgs.vimPlugins // customVimPlugins; [
        auto-pairs
        nerdtree
        vim-airline
        vim-airline-themes
        vim-fugitive
        vim-javascript
        vim-jsx-pretty
        vim-nix
        vim-one
        vim-orgmode
        vim-speeddating  # Used by vim-orgmode
      ];
      extraConfig = builtins.readFile (pkgs.substituteAll {
        src = ../config/vim/extra.vimrc;
        background = if config.lightMode.enable then "light"
                     else "dark";
      });
    };
  };
}
