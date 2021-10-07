{ config, options, pkgs, lib, ...}:
{
  config = {

    environment = {

      systemPackages = with pkgs; [
        arandr
        dmenu
        dunst
        i3lock
        # i3blocks
        i3status-rust
        i3status
        libnotify      # Enables notify-send
        lightdm
      ];


      # Hacking better HiDPI appearance. The effect shows e.g. in
      # how Firefox scales the tab boxes vs. font size.
      # TODO: Move to machine specific module
      variables = {
        # Scale UI elements by integer factor
        GDK_SCALE = "2";
        # Undo scaling of text
        GDK_DPI_SCALE = "0.5";
        # Scale Java elements, should be unnecessary since Java 9
        _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2";
      };

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

    # Bigger tty fonts
    # TODO: Move to machine specific module
    console.font = "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";

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
        # Apps, such as Firefox, flicker without
        # v-sync and GLX backend
        vSync = true;
        backend = lib.mkDefault "glx";
      };
      xserver = {
        desktopManager.xterm.enable = false;
        displayManager = {
          defaultSession = "none+i3";
          lightdm.enable = true;
          sessionCommands = ''
            ${pkgs.xorg.xrdb}/bin/xrdb -merge <<EOF
              XTerm*faceName: xft:Dejavu Sans Mono:size=12
            EOF
          '';
        };
        windowManager = {
          i3 = {
            enable = true;
            configFile = ./config/i3/config;
          };
        };
        # TODO: Move to machine specific module
        dpi = 160;  # Larger fonts in X on HiDPI
      };
    };

  };
}
