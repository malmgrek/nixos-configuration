#
# Desktop environment based on i3
#

{ config, options, pkgs, lib, ...}:

let
  rofi-power-menu = pkgs.writeScriptBin "rofi-power-menu" (
    import ./utils/rofi-power-menu.nix {
      shell = pkgs.stdenv.shell;
      cmds = {
        rofi = "${pkgs.rofi}/bin/rofi -theme /etc/rofi/config.rasi -dpi 150";
        hibernate = "systemctl hibernate";
        lock = "i3lock";
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
        rofi = "${pkgs.rofi}/bin/rofi -theme /etc/rofi/config.rasi -dpi 150";
      };
    }
  );
  rofi-dmenu = pkgs.writeScriptBin "rofi-dmenu" (
    import ./utils/rofi-dmenu.nix {
      shell = pkgs.stdenv.shell;
      cmds = {
        rofi = "${pkgs.rofi}/bin/rofi -theme /etc/rofi/config.rasi -dpi 150";
      };
    }
  );
  rofi-window-menu = pkgs.writeScriptBin "rofi-window-menu" (
    import ./utils/rofi-window-menu.nix {
      shell = pkgs.stdenv.shell;
      cmds = {
        rofi = "${pkgs.rofi}/bin/rofi -theme /etc/rofi/config.rasi -dpi 150";
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
        i3lock
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
        udiskie
        xss-lock  # Listens for screenlock requests
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
        ubuntu_font_family
        powerline-fonts
      ];

      fontconfig.defaultFonts = {
        sansSerif = [ "Ubuntu" ];
        monospace = [ "Deja Vu Sans Mono" ];
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
          };
        };
      };
    };

  };
}
