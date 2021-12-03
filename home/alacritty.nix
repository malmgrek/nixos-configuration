{ config, lib, pkgs, ... }:

let
  onedark = {
    primary = {
      background = "#282c34";
      foreground = "#abb2bf";
    };
    normal = {
      # NOTE: Use '#131613' for the `black` color if you'd like to see
      # black text on the background.
      black =   "#282c34";
      red =     "#e06c75";
      green =   "#98c379";
      yellow =  "#d19a66";
      blue =    "#61afef";
      magenta = "#c678dd";
      cyan =    "#56b6c2";
      white =   "#abb2bf";
    };
    bright = {
      black =   "#5c6370";
      red =     "#e06c75";
      green =   "#98c379";
      yellow =  "#d19a66";
      blue =    "#61afef";
      magenta = "#c678dd";
      cyan =    "#56b6c2";
      white =   "#ffffff";
    };
  };
  onelight = {
    primary = {
      foreground = "#282c34";
      background = "#ffffff";
    };
    normal = {
      black =   "#282c34";
      red =     "#e06c75";
      green =   "#98c379";
      yellow =  "#d19a66";
      blue =    "#61afef";
      magenta = "#c678dd";
      cyan =    "#56b6c2";
      white =   "#abb2bf";
    };
    bright = {
      black =   "#5c6370";
      red =     "#e06c75";
      green =   "#98c379";
      yellow =  "#d19a66";
      blue =    "#61afef";
      magenta = "#c678dd";
      cyan =    "#56b6c2";
      white =   "#ffffff";
    };
  };
in
{

  home-manager.users.malmgrek = {

    programs = {
      alacritty = {
        enable = true;
        settings = {
          font = {
            normal = {
              family = "monospace";
              style = "Regular";
            };
          };
          colors = onedark;
        };
      };
    };

    # Alacritty config files
    # xdg.configFile."alacritty/alacritty.yml".source = ../config/alacritty/alacritty.yml;

  };

}
