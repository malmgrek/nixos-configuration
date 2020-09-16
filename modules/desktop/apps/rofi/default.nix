{ config, options, lib, pkgs, ... }:

with lib;
{
  options.modules.desktop.apps.rofi = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.desktop.apps.rofi.enable {
    my = let
      # Write rofi-related scripts to derivation binaries. We could just include these
      # in this repo's "bin" (and PATH) but it is cleaner not globally installing them
      # unless Rofi is enabled.
      shell = pkgs.stdenv.shell;
      rofi = pkgs.writeScriptBin "rofi" ''
        #!${shell}
        exec ${pkgs.rofi}/bin/rofi \
          -terminal ${config.modules.desktop.term.default} -m -1 "$@"
      '';
      rofi_appmenu = pkgs.writeScriptBin "rofi-appmenu" ''
        #!${shell}
        rofi -show drun -modi drun,run -show-icons -theme theme/config.rasi
      '';
      rofi_filemenu = pkgs.writeScriptBin "rofi-filemenu" ''
        #!${shell}
        cd $HOME
        DIR="$(fd -L -d 4 --type d . | rofi -dmenu -i -p "~/" -theme theme/config.rasi)"
        if [ -d "$DIR" ]; then
          cd "$DIR"
          ${config.modules.desktop.term.default}
        fi
      '';
      rofi_windowmenu = pkgs.writeScriptBin "rofi-windowmenu" ''
        #!${shell}
        rofi -show window -show-icons -theme theme/config.rasi
      '';
      # TODO: Move to window manager module, and evaluate if (mkIf)
      # Rofi is enabled
      rofi_powermenu = pkgs.writeScriptBin "rofi-powermenu" (
        import ./powermenu.nix {
          shell = shell;
          cmds = {
            hibernate = "systemctl hibernate";
            lock = "i3lock";
            logout = "i3-msg exit";
            poweroff = "systemctl poweroff";
            reboot = "systemctl reboot";
            suspend = "i3-lock && systemctl suspend";
          };
        }
      );
      # FIXME
      # rofi_bookmarkmenu = writeScriptBin ...
      # + makeDesktopItem in packages list definition
      rofi_bookmarkmenu = pkgs.makeDesktopItem {
        name = "rofi-bookmarkmenu";
        desktopName = "Open Bookmark in Browser";
        icon = "bookmark-new-symbolic";
        exec = "${<bin/rofi/bookmarkmenu>}";
      };
      # FIXME
      rofi_filemenu_scratch = pkgs.makeDesktopItem {
        name = "rofi-filemenu-scratch";
        desktopName = "Open Directory in Scratch Terminal";
        icon = "folder";
        exec = "${<bin/rofi/filemenu>} -x";
      };
    in {
      packages = [
        rofi
        rofi_appmenu
        rofi_filemenu
        rofi_powermenu
        rofi_windowmenu
        # rofi_bookmarkmenu

        # For rapidly test changes to rofi's stylesheets
        # (writeScriptBin "rofi-test" ''
        #   #!${stdenv.shell}
        #   themefile=$1
        #   themename=${modules.theme.name}
        #   shift
        #   exec rofi \
        #        -theme ~/.dotfiles/modules/themes/$themename/rofi/$themefile \
        #        "$@"
        #   '')

      ];

      home.xdg.configFile."rofi/theme/config.rasi" = {
        text = ''
          /* -*- mode: css; -*- */
          configuration {
            icon-theme:       "Paper";
            cycle:            true;
            disable-history:  false;
            monitor:          "-4";

            /* Vim-esque C-j/C-k as up/down in rofi */
            kb-accept-entry: "Return,Control+m,KP_Enter";
            kb-row-down: "Down,Control+n,Control+j";
            kb-remove-to-eol: "";
            kb-row-up: "Up,Control+p,Control+k";
          }
        '';
        recursive = true;
      };

      i3.cfg = ''
        bindsym $mod+space exec rofi-appmenu
        bindsym $mod+Shift+space exec rofi-filemenu
        bindsym $mod+Tab exec rofi-windowmenu
        bindsym $mod+p exec rofi-powermenu
      '';
    };
  };

}
