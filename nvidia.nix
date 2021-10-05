#
# See also https://nixos.wiki/wiki/Nvidia for troubleshooting
#
# NOTE: Enabling this module seems to increase power consumption
# significantly. Perhaps the offloading is not working properly or
# some other power-saving feature is badly configured? There is
# a Nvidia module in Nixos/nixos-hardware that should be looked at.
#
# TODO: Test using through a Nix shell.
#
{ pkgs, ...  }:

let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
'';
in
{

  environment.systemPackages = [ nvidia-offload  ];

  services.xserver = {
    videoDrivers = [ "nvidia" ];
  };

  hardware = {
    nvidia = {
      prime = {
        offload.enable = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
      powerManagement.enable = true;
      # powerManagement.finegrained = true;
    };
    opengl.enable = true;
  };

}
