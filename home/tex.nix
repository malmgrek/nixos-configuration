{ config, lib, pkgs, ... }:

let
  tex = (pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-basic
      wrapfig ulem amsmath hyperref capt-of metafont;
  });
in {
  home-manager.users.${config.customParams.userName} = {
    home.packages = with pkgs; [
      tex
    ];
  };
}
