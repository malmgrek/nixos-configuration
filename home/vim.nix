{ config, lib, pkgs, ... }:

{

  home-manager.users.malmgrek = {

    programs.vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [
        auto-pairs
        vim-airline
        vim-airline-themes
        vim-fugitive
        vim-javascript
        vim-jsx-pretty
        vim-nix
        vim-one
      ];
      extraConfig = builtins.readFile ../config/vim/extra.vimrc;
    };

  };
  
}
