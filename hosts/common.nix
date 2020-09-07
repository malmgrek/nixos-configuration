{ config, lib, pkgs, ... }:
{

  # Support for more filesystems
  environment.systemPackages = with pkgs; [
    exfat
    ntfs3g
    hfsprogs
  ];

  # Nothing in /tmp shall survive a reboot
  boot.tmpOnTmpfs = true;

  # This assumes a Legacy Boot mode which certainly
  # isn't a common assumption for all systems.
  boot.loader = {
    grub = {
      enable = true;
      version = 2;
      device = "/dev/sda";
    };
  };

  networking.firewall.enable = true;
  networking.hosts = {
    "192.168.1.10" = [ "phoe" ];
  };

}
