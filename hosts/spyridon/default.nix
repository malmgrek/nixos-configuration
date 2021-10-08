{ config, lib, pkgs, ... }:

{

  imports = [
    ./hardware-configuration.nix
    ../../common.nix
    ../../home
    ../../i3.nix
    # ../../nvidia.nix
  ];

  # Use the systemd-boot EFI boot loader
  # TODO: Try grub
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      grub.useOSProber = true;
    };
  };

  # Hacking better HiDPI appearance. The effect shows e.g. in
  # how Firefox scales the tab boxes vs. font size.
  environment.variables = {
    # Scale UI elements by integer factor
    GDK_SCALE = "2";
    # Undo scaling of text
    GDK_DPI_SCALE = "0.5";
    # Scale Java elements, should be unnecessary since Java 9
    _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2";
  };

  networking.hostName = "spyridon";

  # Bigger tty fonts
  # TODO: Try the effect of this
  console.font = "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";

  services = {
    thermald.enable = true;
    # TLP is a command line for saving laptop battery. TLP will take care of the
    # majority of settings that powertop would enable.
    tlp.enable = true;
    xserver.dpi = 150;  # Attempts better scales on HiDPI
  };

  # TODO: Use declarative style user management with immutable users
  users.users.malmgrek = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
    ];
  };

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

  system.stateVersion = "21.05";  # Don't edit!
}
