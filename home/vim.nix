{ config, lib, pkgs, ... }:
let
  # Sourced from the working tree, not copied into the store, so editing the
  # vimrc takes effect at the next vim start rather than at the next rebuild.
  # A moved repository makes vim report the missing file instead of silently
  # dropping the configuration.
  inherit (config.customParams) repoPath;
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
      extraConfig = "source ${repoPath}/config/vim/extra.vimrc";
    };
  };
}
