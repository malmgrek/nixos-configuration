# VirtualBox

{ config, options, lib, pkgs, ... }:
with lib;
{
  options.modules.desktop.apps.vm = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  # TODO Figure out macOS guest on libvirt/qemu instead
  config = mkIf config.modules.desktop.apps.vm.enable {
    virtualisation.virtualbox.host = {
      enable = true;
      # urg, takes so long to build, but needed for macOS guest
      enableExtensionPack = false;
    };

    my.user.extraGroups = [ "vboxusers" ];
  };
}
