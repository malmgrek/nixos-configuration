{ config, lib, pkgs, ... }:

let
  tokyonightMoon = {
    dark = {
      primary = {
        background = "#222436";
        foreground = "#c8d3f5";
      };
      normal = {
        black =   "#1b1d2b";
        red =     "#ff757f";
        green =   "#c3e88d";
        yellow =  "#ffc777";
        blue =    "#82aaff";
        magenta = "#c099ff";
        cyan =    "#86e1fc";
        white =   "#c8d3f5";
      };
      bright = {
        black =   "#444a73";
        red =     "#ff8d94";
        green =   "#c7fb6d";
        yellow =  "#ffd8ab";
        blue =    "#9ab8ff";
        magenta = "#caabff";
        cyan =    "#b2ebff";
        white =   "#c8d3f5";
      };
    };
    light = {
      primary = {
        foreground = "#3760bf";
        background = "#e1e2e7";
      };
      normal = {
        black =   "#b4b5b9";
        red =     "#f52a65";
        green =   "#587539";
        yellow =  "#8c6c3e";
        blue =    "#2e7de9";
        magenta = "#9854f1";
        cyan =    "#007197";
        white =   "#6172b0";
      };
      bright = {
        black =   "#a1a6c5";
        red =     "#ff4774";
        green =   "#5c8524";
        yellow =  "#a27629";
        blue =    "#358aff";
        magenta = "#a463ff";
        cyan =    "#007ea8";
        white =   "#3760bf";
      };
    };
  };
  doomOne = {
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
  };
in {
  home-manager.users.${config.customParams.userName} = {
    programs = {
      alacritty = {
        enable = true;
        settings = {
          colors = if config.lightMode.enable then doomOne.light else doomOne.dark;
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
