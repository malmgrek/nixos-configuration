{ config, lib, pkgs, ... }:
let
  # Override broken package
  customVimPlugins = {
    vim-fugitive = pkgs.vimUtils.buildVimPluginFrom2Nix {
      name = "vim-fugitive";
      src = pkgs.fetchFromGitHub {
        owner = "tpope";
        repo = "vim-fugitive";
        rev = "365231384cf9edc32b2fc34f6c3e1b31eeabfedf";
        sha256 = "1mibf943kpvg7b8rzir1wa7pn1akgnjbwysbyw2sqcy92ib6ls7b";
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
      extraConfig = builtins.readFile ../config/vim/extra.vimrc;
    };
  };
}
