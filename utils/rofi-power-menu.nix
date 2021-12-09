{ shell, cmds }:

''
  #!/usr/bin/env sh

  rofi_cmd='${cmds.rofi}'

  # Options
  hibernate=" Hibernate"
  lock=" Lock"
  logout=" Logout"
  poweroff=" Shutdown"
  reboot=" Reboot"
  suspend=" Suspend"
  options="$poweroff\n$reboot\n$lock\n$hibernate\n$suspend\n$logout"

  case "$(echo -e "$options" | $rofi_cmd -dmenu -selected-row 2)" in
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
