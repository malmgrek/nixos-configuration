#
# See also https://nixos.wiki/wiki/Nvidia for troubleshooting
#
# Enabling this module increases power consumption (decreases battery life)
# significantly. Perhaps the offloading is not working properly or some other
# power-saving feature is badly configured? There is a Nvidia module in
# Nixos/nixos-hardware that should be looked at. A nice option would be the
# ability to turn on/off Nvidia GPU completely while still having it available.
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
        #
        # NOTE: The bus ids are system specific!
        #
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
      powerManagement.enable = true;
      #
      # This is an experimental power savings module for newer (Turing) Nvidia
      # GPUs
      #
      # powerManagement.finegrained = true;
    };
    opengl.enable = true;
  };

}
