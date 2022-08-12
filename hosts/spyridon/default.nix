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
    lightMode.enable = true;

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
    services.tlp = {
      enable = true;
      settings = {
        # Fixes the problem of overheating and slowing down when on AC.
        # The `RUNTIME_OM_ON_AC` PCI(e) setting seemed to solely do the trick
        # but why not save a bit extra energy.
        AHCI_RUNTIME_PM_ON_AC = "auto";
        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_power";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        RUNTIME_PM_ON_AC = "auto";
        SCHED_POWERSAVE_ON_AC = "1";
      };
    };
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

    services.printing.drivers = [ pkgs.cups-toshiba-estudio ];

  };

}
