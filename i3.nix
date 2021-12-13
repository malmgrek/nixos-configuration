#
# Desktop environment based on i3
#

{ config, options, pkgs, lib, ...}:

let
  # Wrap as script for clarity, used in i3/config
  xsecurelock-xscreensaver = pkgs.writeScriptBin "xsecurelock-xscreensaver" (
    ''
      #!/bin/sh

      export XSECURELOCK_SAVER=saver_xscreensaver
      export XSECURELOCK_PASSWORD_PROMPT=emoticon
      export XSECURELOCK_FONT='JetBrains Mono'
      export XSECURELOCK_AUTH_BACKGROUND_COLOR='#1d2021'
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
      shell = pkgs.stdenv.shell;
      cmds = {
        rofi = "${pkgs.rofi}/bin/rofi -theme /etc/rofi/config.rasi";
        hibernate = "systemctl hibernate";
        # Custom session locker is defined in i3/config by xss-lock
        lock = "loginctl lock-session";
        logout = "i3-msg exit";
        poweroff = "systemctl poweroff";
        reboot = "systemctl reboot";
        suspend = "systemctl suspend";
      };
    }
  );
  rofi-app-menu = pkgs.writeScriptBin "rofi-app-menu" (
    import ./utils/rofi-app-menu.nix {
      shell = pkgs.stdenv.shell;
      cmds = {
        rofi = "${pkgs.rofi}/bin/rofi -theme /etc/rofi/config.rasi";
      };
    }
  );
  rofi-dmenu = pkgs.writeScriptBin "rofi-dmenu" (
    import ./utils/rofi-dmenu.nix {
      shell = pkgs.stdenv.shell;
      cmds = {
        rofi = "${pkgs.rofi}/bin/rofi -theme /etc/rofi/config.rasi";
      };
    }
  );
  rofi-window-menu = pkgs.writeScriptBin "rofi-window-menu" (
    import ./utils/rofi-window-menu.nix {
      shell = pkgs.stdenv.shell;
      cmds = {
        rofi = "${pkgs.rofi}/bin/rofi -theme /etc/rofi/config.rasi";
      };
    }
  );
in {
  config = {

    environment = {

      systemPackages = with pkgs; [
        # i3blocks
        arandr
        dmenu
        dunst
        # i3lock
        i3status
        i3status-rust
        libnotify  # Enables notify-send
        lightdm
        networkmanagerapplet
        rofi
        rofi-app-menu
        rofi-dmenu
        rofi-power-menu
        rofi-window-menu
        simplescreenrecorder
        spectacle  # Screenshooting
        udiskie  # Removable media daemon
        xscreensaver
        xsecurelock-dimmer
        xsecurelock-xscreensaver
        xss-lock
      ];

      # Configuration file for i3status-rust status bar.
      # The daemon is started in i3 config.
      etc."i3status-rs/config.toml" = {
        source = ./config/i3status-rs/config.toml;
      };

      # Configuration file for dunst.
      # The daemon is started in i3 config.
      etc."dunstrc" = {
        source = ./config/dunst/dunstrc;
      };

      etc."rofi/config.rasi" = {
        source = ./config/rofi/config.rasi;
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
