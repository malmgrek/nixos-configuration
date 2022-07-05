{ config, lib, pkgs, ... }:

{

  home-manager.users.${config.customParams.userName} = {
    xdg.configFile."ptpython/config.py" = {
      source = ../config/ptpython/config.py;
    };
  };

}
