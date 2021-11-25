#
# Desktop environment based on i3
#

{ config, options, pkgs, lib, ...}:
{
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
        libnotify      # Enables notify-send
        lightdm
        rofi
        simplescreenrecorder
        spectacle
      ];

      # Configuration file for i3status-rust status bar
      etc."i3status-rs/config.toml" = {
        source = ./config/i3status-rs/config.toml;
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
