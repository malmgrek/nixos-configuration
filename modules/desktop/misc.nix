{ config, lib, pkgs, ... }:

{

  my.packages = with pkgs; [
    evince
    feh
    mpv
    xclip    # system clipboard support for vim
    xdotool
    xev      # find a keyboard button name
  ];

  ## Sound
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      dejavu_fonts
      fira-code
      fira-code-symbols
      font-awesome
      jetbrains-mono
      noto-fonts
      ubuntu_font_family
      # (nerdfonts.override {withFont="Iosevka";})
    ];
    fontconfig.defaultFonts = {
      sansSerif = ["Ubuntu"];
      monospace = ["JetBrains Mono"];
    };
  };

  services.xserver = {
    displayManager.lightdm.greeters.mini.user = config.my.username;
    layout = "fi";
  };

  services.picom = {
    backend = "glx";
    vSync = false;  # XXX: false fixes picom error in VirtualBox
    opacityRules = [
      # "100:class_g = 'Firefox'"
      # "100:class_g = 'Vivaldi-stable'"
      "100:class_g = 'VirtualBox Machine'"
      # Art/image programs where we need fidelity
      "100:class_g = 'Gimp'"
      "100:class_g = 'Inkscape'"
      "100:class_g = 'aseprite'"
      "100:class_g = 'krita'"
      "100:class_g = 'feh'"
      "100:class_g = 'mpv'"
      "100:class_g = 'Rofi'"
      "100:class_g = 'Peek'"
      "99:_NET_WM_STATE@:32a = '_NET_WM_STATE_FULLSCREEN'"
    ];
    shadowExclude = [
      # Put shadows on notifications, the scratch popup and rofi only
      "! name~='(rofi|scratch|Dunst)$'"
    ];
    settings.blur-background-exclude = [
      "window_type = 'dock'"
      "window_type = 'desktop'"
      "class_g = 'Rofi'"
      "_GTK_FRAME_EXTENTS@:c"
    ];
  };

  # Try really hard to get QT to respect my GTK theme.
  my.env.GTK_DATA_PREFIX = [ "${config.system.path}" ];
  my.env.QT_QPA_PLATFORMTHEME = "gtk2";
  qt5 = { style = "gtk2"; platformTheme = "gtk2"; };
  services.xserver.displayManager.sessionCommands = ''
    export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
    source "$XDG_CONFIG_HOME"/xsession/*.sh
    xrdb -merge "$XDG_CONFIG_HOME"/xtheme/*
  '';

}
