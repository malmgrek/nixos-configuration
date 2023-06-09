{ config, lib, pkgs, ... }:

with lib; {

  options = {
    hidpiHacks.enable = mkEnableOption "Hacking better HiDPI experience";
    lightMode.enable = mkEnableOption "Light colorscheme in old school tools";
    customParams = {
      userName = mkOption {
        type = types.str;
        default = "malmgrek";
        description = "username of the main user";
      };
      dpi = mkOption {
        type = types.nullOr types.int;
        default = 150;
      };
    };
  };

  config = mkIf config.hidpiHacks.enable {
    # Taken from deprecated module nixos/modules/hardware/video/hidpi.nix
    # Resolution of the console
    boot.loader.systemd-boot.consoleMode = mkDefault "1";
    console = {
      # Bigger tty fonts, TODO: Why this is needed?
      font = mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
      earlySetup = mkDefault true;
    };
    environment = {
      # The effect of the below environment variables shows e.g. in how
      # Firefox inflates the tab boxes vs. font size.
      variables = {
        # Scale UI elements by integer factor
        GDK_SCALE = mkDefault "2";
        # Undo scaling of text
        GDK_DPI_SCALE = mkDefault "0.5";
        # Scale Java elements, should be unnecessary since Java 9
        _JAVA_OPTIONS = mkDefault "-Dsun.java2d.uiScale=2";
      };
    };
    services = {
      xserver = {
        dpi = config.customParams.dpi;
        displayManager = {
          # Fix font size in XTerm
          sessionCommands = mkDefault ''
            ${pkgs.xorg.xrdb}/bin/xrdb -merge <<EOF
              XTerm*faceName: xft:Dejavu Sans Mono:size=12
            EOF
          '';
        };
      };
    };
  };

}
