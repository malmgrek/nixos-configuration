{ config, lib, pkgs, ... }:

let
  dark = {
    primary = {
      background = "#282c34";
      foreground = "#abb2bf";
    };
    normal = {
      # NOTE: Use '#131613' for the `black` color if you'd like to see
      # black text on the background.
      black =   "#282c34";
      red =     "#ff6c6b";
      green =   "#98be65";
      yellow =  "#ecbe7b";
      blue =    "#51afef";
      magenta = "#c678dd";
      cyan =    "#46d9ff";
      white =   "#abb2bf";
    };
    bright = {
      black =   "#5c6370";
      red =     "#ff6655";
      green =   "#99bb66";
      yellow =  "#ecbe7b";
      blue =    "#51afef";
      magenta = "#c678dd";
      cyan =    "#46d9ff";
      white =   "#ffffff";
    };
  };
  light = {
    primary = {
      foreground = "#282c34";
      background = "#ffffff";
    };
    normal = {
      black =   "#282c34";
      red =     "#ff5f5f";
      green =   "#5fff87";
      yellow =  "#d7d700";
      blue =    "#4078f2";
      magenta = "#ff5faf";
      cyan =    "#5fd7ff";
      white =   "#abb2bf";
    };
    bright = {
      black =   "#5c6370";
      red =     "#ff5f5f";
      green =   "#5fff87";
      yellow =  "#d7d700";
      blue =    "#4078f2";
      magenta = "#ff5faf";
      cyan =    "#5fd7ff";
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
          colors = if config.lightMode.enable then light else dark;
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
