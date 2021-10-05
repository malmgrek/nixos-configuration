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
        brightnessctl  # FIXME: Replace with actkbd
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
        windowManager.i3.enable = true;
        # TODO: Move to machine specific module
        dpi = 160;  # Larger fonts in X on HiDPI
      };
    };

  };
}
