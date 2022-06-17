{ config, lib, pkgs, ... }:

{
  # On HiDPI, the pointer cursor is ridiculously small by default. Configuring
  # cursors seems a bit tricky. For now, let's rely on Home Manager which wraps
  # the configs so we don't need to stab multiple config files.
  #
  # Some HiDPI hacks related to "more general" UX are currently
  # done with Home Manager, which is suboptimal.
  home-manager.users.${config.customParams.userName} = {
    home.pointerCursor = {
      name = "Vanilla-DMZ";
      package = pkgs.vanilla-dmz;
      size = lib.mkIf config.hidpiHacks.enable 128;
      x11.enable = true;
    };
  };
}
