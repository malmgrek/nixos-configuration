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
      rofi = writeScriptBin "rofi" ''
        #!${stdenv.shell}
        exec ${rofi}/bin/rofi -terminal ${config.modules.desktop.term.default} -m -1 "$@"
      '';
      rofi_appmenu = writeScriptBin "rofi-appmenu" ''
        #!${stdenv.shell}
        rofi -show drun -modi drun,run -show-icons
      '';
      rofi_filemenu = writeScriptBin "rofi-filemenu" ''
        #!${stdenv.shell}
        cd $HOME
        DIR="$(fd -L -d 4 --type d . | rofi -dmenu -i -p "~/")"
        if [ -d "$DIR" ]; then
          cd "$DIR"
          ${config.modules.desktop.term.default}
        fi
      ''
      rofi_windowmenu = writeScriptBin "rofi-windowmenu" ''
        #!${stdenv.shell}
        rofi -show window -show-icons
      '';
      # TODO: Move to window manager module, and evaluate if
      # Rofi is enabled
      rofi_powermenu = writeScriptBin "rofi-powermenu" (
        import ./powermenu.nix {
          shell = stdenv.shell;
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
      rofi_bookmarkmenu = makeDesktopItem {
        name = "rofi-bookmarkmenu";
        desktopName = "Open Bookmark in Browser";
        icon = "bookmark-new-symbolic";
        exec = "${<bin/rofi/bookmarkmenu>}";
      };
      # FIXME
      rofi_filemenu_scratch = makeDesktopItem {
        name = "rofi-filemenu-scratch";
        desktopName = "Open Directory in Scratch Terminal";
        icon = "folder";
        exec = "${<bin/rofi/filemenu>} -x";
      };
    in {
      packages = with pkgs; [
        rofi
        rofi_appmenu
        rofi_powermenu
        rofi_windowmenu
        rofi_bookmarkmenu

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

      i3.cfg = ''
        bindsym $mod+space exec ${rofi_appmenu}
        bindsym $mod+Shift+space exec ${rofi_filemenu}
        bindsym $mod+Tab exec ${rofi_windowmenu}
        bindsym $mod+p exec ${rofi_powermenu}
      '';
    };
  };

}
