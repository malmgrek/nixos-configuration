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
  time.timeZone = "Europe/Helsinki";
  location = {
    latitude = 60.2;
    longitude = 24.9;
  };

  # Linux thermal daemon controls the system temperature using available
  # cooling methods
  services.thermald.enable = false;
  # TLP is a command line for saving laptop battery. TLP will take care of the
  # majority of settings that powertop would enable.
  services.tlp.enable = true;
  powerManagement.powertop.enable = true;

  # TODO: Use declarative style user management with immutable users
  users.users.malmgrek = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
    ];
  };

  # Automatic screen color management
  services.redshift = {
    enable = true;
    brightness = {
      day = "1";
      night = "1";
    };
    temperature = {
      day = 7500;
      night = 4500;
    };
  };

  home-manager.users.malmgrek = {
    xsession.pointerCursor = {
      name = "Vanilla-DMZ";
      package = pkgs.vanilla-dmz;
    };
    programs = {
      alacritty = {
        settings.font.size = 8.0;
      };
    };
  };

}
