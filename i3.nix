{ config, options, pkgs, ...}:
{
  config = {

    environment = {

      # TODO: Add more system packages
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
        pavucontrol    # GUI for sound control
        acpilight      # Replaces xorg.xbacklight
        brightnessctl  # Replaces xorg.xbacklight
      ];


      # # For larger HIDPI fonts
      # # TODO: Move to machine specific module
      # variables = {
      #   # Scale UI elements by integer factor
      #   GDK_SCALE = "2";
      #   # Undo scaling of text
      #   GDK_DPI_SCALE = "0.5";
      #   # Scale Java elements, should be unnecessary since Java 9
      #   _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2";
      # };

    };

    # Sound
    sound.enable = true;
    hardware.pulseaudio.enable = true;

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
      ];

      fontconfig.defaultFonts = {
        sansSerif = [ "Ubuntu" ];
        monospace = [ "JetBrains Mono" ];
      };

    };

    # Bigger tty fonts
    # TODO: Move to machine specific module
    console.font = "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";

    services = {
      picom.enable = true;
      xserver = {
        enable = true;
        desktopManager.xterm.enable = false;
        displayManager = {
          defaultSession = "none+i3";
          lightdm = {
            enable = true;
            greeters.gtk = {
              enable = true;
              cursorTheme = {
                name = "Vanilla-DMZ";
                package = pkgs.vanilla-dmz;
                size = 64;
              };
              # user = "malmgrek";  # Required by mini
            };
          };
        };
        layout = "fi";
        windowManager.i3.enable = true;
        # TODO: Move to machine specific module
        dpi = 160;  # Larger fonts in X on HiDPI
      };
    };

  };
}
