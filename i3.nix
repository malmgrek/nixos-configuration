#
# Desktop environment based on i3-gaps
#

{ config, options, pkgs, lib, ...}:

let
  dpi = config.customParams.dpi;
  rofiCmd = "${pkgs.rofi}/bin/rofi -theme /etc/rofi/config.rasi -dpi ${(
    toString
      (if config.hidpiHacks.enable then (if isNull dpi then 150 else dpi) else 0)
  )}";
  xsecurelock-xscreensaver = pkgs.writeScriptBin "xsecurelock-xscreensaver" (
    ''
      #!/bin/sh

      export XSECURELOCK_SAVER=saver_xscreensaver
      export XSECURELOCK_PASSWORD_PROMPT=emoticon
      export XSECURELOCK_FONT='JetBrains Mono'
      export XSECURELOCK_AUTH_BACKGROUND_COLOR='#1d2021'

      # When connected on dual monitor, a minor incompatibility issue between
      # Picom and xsecurelock may cause flickering error message on screen.
      # Hides the message.
      # export XSECURELOCK_COMPOSITE_OBSCURER=0

      exec ${pkgs.xsecurelock}/bin/xsecurelock
    ''
  );
  # Wrap to script so we can use it in i3/config (xss-lock)
  xsecurelock-dimmer = pkgs.writeScriptBin "xsecurelock-dimmer" (
    ''
      #!/bin/sh

      export XSECURELOCK_DIM_ALPHA=1.0
      export XSECURELOCK_DIM_TIME_MS=10000
      export XSECURELOCK_WAIT_TIME_MS=5000
      dimmer=${pkgs.xsecurelock}/libexec/xsecurelock/dimmer
      until_nonidle=${pkgs.xsecurelock}/libexec/xsecurelock/until_nonidle
      $until_nonidle $dimmer
    ''
  );
  rofi-power-menu = pkgs.writeScriptBin "rofi-power-menu" (
    import ./utils/rofi-power-menu.nix {
      cmds = {
        rofi = rofiCmd;
        hibernate = "systemctl hibernate";
        lock = "loginctl lock-session";
        logout = "i3-msg exit";
        poweroff = "systemctl poweroff";
        reboot = "systemctl reboot";
        suspend = "systemctl suspend";
      };
    }
  );
  rofi-app-menu = pkgs.writeScriptBin "rofi-app-menu" (
    ''
      #!/bin/sh

      ${rofiCmd} -show drun -modi drun,run -show-icons
    ''
  );
  rofi-dmenu = pkgs.writeScriptBin "rofi-dmenu" (
    ''
      #!/bin/sh

      ${rofiCmd} -show run -modi run
    ''
  );
  rofi-window-menu = pkgs.writeScriptBin "rofi-window-menu" (
    ''
      !/bin/sh

      ${rofiCmd} -show window -show-icons
    ''
  );
in {
  config = {

    environment = {

      systemPackages = with pkgs; [
        arandr
        dmenu
        dunst
        i3status
        i3status-rust
        libnotify  # Enables notify-send
        lightdm
        networkmanagerapplet
        rofi
        simplescreenrecorder
        spectacle  # Screenshooting
        udiskie  # Removable media daemon
        xscreensaver
        xss-lock

        # Custom wrappers
        rofi-app-menu
        rofi-dmenu
        rofi-power-menu
        rofi-window-menu
        xsecurelock-dimmer
        xsecurelock-xscreensaver
      ];

      # Write global config files
      etc = {
        # The i3status-rust daemon is started in i3 config.
        "i3status-rs/config.toml" = {
          source = ./config/i3status-rs/config.toml;
        };
        "dunstrc" = {
          text = (
            builtins.replaceStrings
              [ "# GEOMETRY" ]
              [ "geometry = \"${
                if config.hidpiHacks.enable then "600x10-30+40"
                else "300x5-30+24"
              }\"" ]
              (builtins.readFile ./config/dunst/dunstrc)
          );
        };
       "rofi/config.rasi" = {
          source = ./config/rofi/config.rasi;
        };
      };

    };

    fonts = {

      fontDir.enable = true;
      enableGhostscriptFonts = true;
      fonts = with pkgs; [
        dejavu_fonts
        fira-code
        fira-code-symbols
        font-awesome
        jetbrains-mono
        noto-fonts
        noto-fonts-emoji
        ubuntu_font_family
        powerline-fonts
      ];

      fontconfig.defaultFonts = {
        sansSerif = [ "Ubuntu" ];
        monospace = [ "Deja Vu Sans Mono" ];
        emoji = [ "Noto Color Emoji" ];
      };

    };

    services = {
      actkbd = {
        enable = true;
        bindings = let
          light = "${pkgs.light}/bin/light";
          step = "1";
        in [
          {
            keys = [ 224 ];
            events = [ "key" ];
            # Use minimum brightness 0.2 so the display won't go totally black.
            command = "${light} -N 0.2 && ${light} -U ${step}";
          }
          {
            keys = [ 225 ];
            events = [ "key" ];
            command = "${light} -A ${step}";
          }
        ];
      };
      picom = {
        enable = true;
        # Apps, such as Firefox may flicker without v-sync and GLX backend
        vSync = true;
        backend = lib.mkDefault "glx";
        activeOpacity = 1.0;
        inactiveOpacity = 0.8;
        shadow = true;
        # fade = true;
        # fadeDelta = 5;
      };
      # Automatic screen color management
      redshift = {
        enable = true;
        brightness = {
          day = "1";
          night = "1";
        };
        temperature = {
          day = 7500;
          night = 4500;
        };
      };
      xserver = {
        desktopManager.xterm.enable = false;
        displayManager = {
          defaultSession = "none+i3";
          lightdm.enable = true;
        };
        windowManager = {
          i3 = {
            enable = true;
            configFile = ./config/i3/config;
            package = pkgs.i3-gaps;
          };
        };
      };
    };

  };
}
