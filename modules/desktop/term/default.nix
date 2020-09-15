{ config, options, lib, pkgs, ... }:
with lib;
{

  imports = [
    ./alacritty.nix
    ./st.nix
    # ./urxvt.nix
  ];

  options.modules.desktop.term = {
    default = mkOption {
      type = types.str;
      default = "xterm";
    };
  };

  config = {
    services.xserver.desktopManager.xterm.enable = true;
    my.env.TERMINAL = config.modules.editors.default;
  };

}
