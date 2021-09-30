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
        # lightdm
        pavucontrol    # GUI for sound control
        acpilight      # Replaces xorg.xbacklight
        brightnessctl  # Replaces xorg.xbacklight
      ];


      # TODO: For HIDPI larger fonts -- is there a better way?
      variables = {
        GDK_SCALE = "2";
        GDK_DPI_SCALE = "0.5";
        _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2";
      };

      # TODO: I put this because of i3 status -- is it needed anymore?
      pathsToLink = [ "/libexec" ];

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

    # TODO: For HIDPI larger fonts -- is there a better way?
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
            greeters.mini.enable = true;
          };
        };
        # displayManager.lightdm.enable = true;
        # displayManager.lightdm.greeters.mini.enable = true;
        layout = "fi";
        dpi = 180;
        windowManager.i3.enable = true;
      };
    };

  };
}
