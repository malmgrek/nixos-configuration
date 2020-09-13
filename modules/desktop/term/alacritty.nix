{ config, lib, pkgs, ... }:

with lib; {
  options.modules.desktop.term.alacritty = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.desktop.term.alacritty.enable {
    my.zsh.rc = ''export TERM=xterm-256color'';
    my = {
      packages = with pkgs; [
        unstable.alacritty
      ];
      home.xdg.configFile."alacritty" = {
        source = <config/alacritty>;
        recursive = true;
      };
    };
  };
}
