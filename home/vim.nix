{ config, lib, pkgs, ... }:
let
in {
  home-manager.users.${config.customParams.userName} = {
    programs.vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [
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
      extraConfig = builtins.readFile (pkgs.replaceVars ../config/vim/extra.vimrc {
        background = if config.lightMode.enable then "light"
                     else "dark";
      });
    };
  };
}
