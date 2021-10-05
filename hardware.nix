# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "usb_storage"
    "sd_mod"
    "rtsx_pci_sdmmc"
  ];
  boot.initrd.kernelModules = [
    "dm-snapshot"
    "acpi_call"    # Makes tlp work for newer thinkpads
  ];
  boot.kernelParams = [ "acpi_backlight=native" ];
  boot.kernelModules = [ "kvm-intel" ];

  # In Lenovo P14s gen 2 (Intel CPU) the network driver AX210 does not work
  # with Linux Kernel 5.10 which is the default in Nixos 21.05. Adding latest
  # kernel version helped getting WiFi to work.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/06453e21-c4bc-4bec-bfaf-54e77e6a8d53";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/F4FB-9887";
      fsType = "vfat";
    };

  boot.initrd.luks.devices = {
    "nixos" = {
      device = "/dev/disk/by-uuid/fe1d5131-3d59-4f8a-96b0-9c85d0bee0d9";
      preLVM = true;
    };
  };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/c13767db-2f81-462d-807b-99025e64dbf8"; }
    ];

  # I have tried my best looking for power management hacks. The fan of
  # my Lenovo P14s keeps quite loud noise when running on NixOS. However,
  # the battery life estimate is better than in Windows (power saving mode).
  #
  # Some reading:
  # - https://discourse.nixos.org/t/thinkpad-t470s-power-management/8141
  # - https://discourse.nixos.org/t/fan-keeps-spinning-with-a-base-installation-of-nixos/1394
  #
  powerManagement = {
    cpuFreqGovernor = lib.mkDefault "powersave";
    powertop.enable = lib.mkDefault true;
  };

  # TODO: Move to device specific module
  services.thermald.enable = true;
  services.tlp.enable = true;

  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;
}
