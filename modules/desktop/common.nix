{ config, lib, pkgs, ... }:

{

  my.packages = with pkgs; [
    evince
    feh
    xclip
  ];

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      dejavu_fonts
      ubuntu_font_family
      fira-code
    ];
    fontconfig.defaultFonts = {
      sansSerif = ["Ubuntu"];
      monospace = ["Fira Code"];
    };
  };

  services.xserver = {
    displayManager.lightdm.greeters.mini.user = config.my.username;
  };

  services.picom = {
    backend = "glx";
    vSync = true;
    # opacityRules = [
    #   "100:class_g = 'VirtualBox Machine'"
    #   "100:class_g = 'Gimp'"
    #   "100:class_g = 'Inkscape'"
    #   "100:class_g = 'feh'"
    #   "100:class_g = 'Rofi'"
    #   "99:_NET_WM_STATE@:32a = '_NET_WM_STATE_FULLSCREEN'"
    # ];
    # shadowExclude = [
    #   "! name~='(rofi)'"
    # ];
    # settings.blur-background-exclude = [
    #   "window_type = 'dock'"
    #   "window_type = 'desktop'"
    #   "class_g = 'Rofi'"
    #   "_GTK_FRAME_EXTENTS@:c"
    # ];
  };

  # my.env.GTK_DATA_PREFIX = [ "${config.system.path}" ];
  # my.env.QT_QPA_PLATFORMTHEME = "gtk2";
  # qt5 = { style = "gtk2"; platformTheme = "gtk2"; };
  # services.xserver.displayManager.sessionCommands = ''
  #     export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
  #     source "$XDG_CONFIG_HOME"/xsession/*.sh
  #     xrdb -merge "$XDG_CONFIG_HOME"/xtheme/*
  # '';

}
