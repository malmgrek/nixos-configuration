{ config, options, lib, pkgs, ... }:
with lib;
{

  options.modules.editors.vim = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.editors.vim.enable {
    my = {
      packages = with pkgs; [
        editorconfig-core-c
        neovim
      ];
      home.xdg.configFile.".vim" = {
        source = <config/vim/.vim>;
        recursive = true;
      };
      home.xdg.configFile.".vimrc" = {
        source = <config/vim/.vimrc>;
        recursive = true;
	target = "../.vimrc";
      };
    };
  };

}
