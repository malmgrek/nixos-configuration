#
# See also https://nixos.wiki/wiki/Nvidia for troubleshooting
#
# Enabling this module increases power consumption (decreases battery life)
# significantly. Perhaps the offloading is not working properly or some other
# power-saving feature is badly configured? There is a Nvidia module in
# Nixos/nixos-hardware that should be looked at. A nice option would be the
# ability to turn on/off Nvidia GPU completely while still having it available.
#
{ config, lib, pkgs, ...  }:

let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
'';
in
{

  environment.systemPackages = with pkgs; [ nvidia-offload cudaPackages.cudatoolkit ];

  services.ollama.acceleration = "cuda";

  services.xserver = {
    videoDrivers = [ "nvidia" ];
  };

  hardware = {

    # Enable OpenGL
    graphics.enable = true;

    nvidia = {

      # Modesetting is required.
      modesetting.enable = true;

      # Enable the Nvidia settings menu,
	    # accessible via `nvidia-settings`.
      nvidiaSettings = true;

      # Use the NVidia open source kernel module (not to be confused with the
      # independent third-party "nouveau" open source driver).
      # Support is limited to the Turing and later architectures. Full list of
      # supported GPUs is at:
      # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
      # Only available from driver 515.43.04+
      open = false;

      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      # Enable this if you have graphical corruption issues or application crashes after waking
      # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
      # of just the bare essentials.
      powerManagement.enable = true;

      # Fine-grained power management. Turns off GPU when not in use.
      # Experimental and only works on modern Nvidia GPUs (Turing or newer).
      powerManagement.finegrained = false;

      prime = {
        offload.enable = true;
        offload.enableOffloadCmd = true;
        #
        # NOTE: The bus ids are system specific!
        # sudo lshw -c display
        #
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };

    };
    # opengl.enable = true;
  };

}
