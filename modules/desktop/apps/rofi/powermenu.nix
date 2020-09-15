{ shell, cmds }:
''
  #!${shell}

  rofi_command='rofi -theme theme/config.rasi'

  # Options
  hibernate="Hibernate"
  lock="Lock"
  logout="Logout"
  poweroff="Shutdown"
  reboot="Reboot"
  suspend="Sleep"
  # Variable passed to rofi
  OPTS="$poweroff\n$reboot\n$lock\n$hibernate\n$suspend\n$logout"
  LOCK=i3lock

  case "$(echo -e "$OPTS" | $rofi_command -dmenu -selected-row 2)" in
      $hibernate)
          ${cmds.hibernate}
          ;;
      $lock)
          ${cmds.lock}
          ;;
      $logout)
          ${cmds.logout}
          ;;
      $poweroff)
          ${cmds.poweroff}
          ;;
      $reboot)
          ${cmds.reboot}
          ;;
      $suspend)
          ${cmds.suspend}
          ;;
  esac
''
