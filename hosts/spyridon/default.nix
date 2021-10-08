{ config, lib, pkgs, ... }:

{

  imports = [
    ./hardware-configuration.nix
    ../../common.nix
    ../../home
    ../../i3.nix
    # ../../nvidia.nix
  ];


  ######## Don't edit! #########
  system.stateVersion = "21.05";
  ##############################


  # Use the systemd-boot EFI boot loader
  # TODO: Try grub
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      grub.useOSProber = true;
    };
  };

  networking.hostName = "spyridon";

  # Linux thermal daemon controls the system temperature using available cooling
  # methods
  services.thermald.enable = true;
  # TLP is a command line for saving laptop battery. TLP will take care of the
  # majority of settings that powertop would enable.
  services.tlp.enable = true;

  # TODO: Use declarative style user management with immutable users
  users.users.malmgrek = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
    ];
  };

  #
  # Hacking a better UI experience on HiDPI
  #

  services.xserver.dpi = 150;

  # On HiDPI, the pointer cursor is ridiculously small by default. Configuring
  # cursors seems a bit tricky. For now, let's rely on Home Manager which wraps
  # the configs so we don't need to stab multiple config files.
  home-manager.users.malmgrek = {
    xsession.pointerCursor = {
      name = "Vanilla-DMZ";
      package = pkgs.vanilla-dmz;
      size = 128;
    };
  };

  # Bigger tty fonts
  # TODO: Try the effect of this
  console.font = "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";

  # The effect of the below environment variables shows e.g. in how Firefox
  # inflates the tab boxes vs. font size.
  environment.variables = {
    # Scale UI elements by integer factor
    GDK_SCALE = "2";
    # Undo scaling of text
    GDK_DPI_SCALE = "0.5";
    # Scale Java elements, should be unnecessary since Java 9
    _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2";
  };

}
