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
    hidpiHacks.enable = false;
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
    # (users.mutableUsers = false)
    users.users.${customParams.userName} = {
      isNormalUser = true;
      extraGroups = [
        "adbusers"  # Android debug bridge
        "wheel"
        "networkmanager"
        "video"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCkQ4vGxBCtjpv49y3ICjum5VW7BJU82lUOH8PC7Ka9Vlvg20VAmbx6VdaKHIRlmIbLTVYYVJk/bRAUATrgajgpdTR6kSPReqAYlugazzvcIwGId92HxY2SkpKMQntHMxyAdcHAnR3Mk4FbvNyMxXJTsPBj3uOt76tb3ceOjfjOVtp3oK2ExBCPUO3IKG4yJZVGcMlD3ZdY1tP/SPsLWUx9K/D+BgCBHFGwyVhyuIHC0qZP333Ey0gLpIokm9Zq13oDh/Y1H90lC4ebs9f01yWdS20QxhxyxPpU1J8GQX/44gmyIwQSz3XwtYuuf/YTm5fI4hsXw8rllupiuaQ6gMetPEWuHZieapDG9ZBXRO01ntXxVDcx+YpC4R9ZG1wW3v6l+BFrH9mn9dEGkj4PyhFQT4AVB6F15bzmdi92pEoQl3qiulFuU2UvMP3ThP6LHmBa3mKXpMvKMBmIAtLNKHl3++fqXekJIYZjzHRFSCn7+xnvEX4lBCOKz2k5JLxj49Co84oXBDLVWIPmKUKbxfW+mg/5wbY57J7nMR0v6SSLI17vQMvF4rshKzW9Zsgp/+c2i52cm+wnRgvfW5jHGqLt1/7XcHvAjhQUP1qxkZ4Ds/RAwIK07LDZkKtbLP97XvQM1Z3+m2U2SQZ/yn5RS37MFo0PzfANqE3ZhxrfAM45qQ== malmgrek@spyridon"
      ];
    };

    services.printing.drivers = [ pkgs.cups-toshiba-estudio ];

  };

}
