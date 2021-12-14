{ config, lib, pkgs, ... }:

{

  imports = [

    # Mandatory imports
    ./hardware-configuration.nix
    ../../common.nix

    # Optional
    ../../home
    ../../i3.nix
    # ../../nvidia.nix

  ];

  config = rec {

    ######## Don't edit! #########
    system.stateVersion = "21.05";
    ##############################


    # Custom declarations
    customParams = {
      dpi = 150;
      userName = "malmgrek";
    };
    hidpiHacks.enable = true;

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
    users.users.${customParams.userName} = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
        "video"
      ];
    };

  };

}
