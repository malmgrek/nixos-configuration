# Graphics tools: Gimp, Inkscape, ...

{ config, options, lib, pkgs, ... }:
with lib;
{
  options.modules.desktop.apps.graphics =
    let mkBoolDefault = bool: mkOption {
          type = types.bool;
          default = bool;
        };
    in {
      enable = mkBoolDefault false;
      tools.enable = mkBoolDefault false;
      raster.enable = mkBoolDefault false;
      vector.enable = mkBoolDefault false;
      sprites.enable = mkBoolDefault false;
    };

  config = let gfx = config.modules.desktop.apps.graphics; in {
    my.packages = with pkgs;
      (if gfx.enable || gfx.tools.enable then [
        font-manager   # so many damned fonts...
        imagemagick    # for image manipulation from the shell
      ] else []) ++

      # replaces illustrator & indesign
      (if gfx.enable || gfx.vector.enable then [
        unstable.inkscape
      ] else []) ++

      # Replaces photoshop
      (if gfx.enable || gfx.raster.enable then [
        krita
        gimp
        gimpPlugins.resynthesizer2  # content-aware scaling in gimp
      ] else []) ++

      # Sprite sheets & animation
      (if gfx.enable || gfx.sprites.enable then [ aseprite-unfree ] else []);

    my.home.xdg.configFile = mkIf (gfx.enable || gfx.raster.enable) {
      "GIMP/2.10" = { source = <config/gimp>; recursive = true; };
    };
  };
}
