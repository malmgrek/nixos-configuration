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
  home-manager.users.${config.customParams.userName} = {
    programs = {
      alacritty = {
        enable = true;
        settings = {
          colors = if config.lightMode.enable then onelight else onedark;
          font = {
            normal = {
              family = "monospace";
              style = "Regular";
            };
            size = if config.hidpiHacks.enable then 6.0 else 9.0;
          };
          window = {
            padding = {
              x = 4;
              y = 4;
            };
          };
        };
      };
    };
  };
}
