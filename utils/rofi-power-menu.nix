{ cmds }:

''
  #!/bin/sh

  rofi_cmd='${cmds.rofi}'

  trim ()
  {
    # Replace a tab with a space
    echo ''${1//\\t/ }
  }

  # Options
  away="\tAway"
  hibernate="\tHibernate"
  lock="\tLock"
  logout="\tLogout"
  poweroff="\tShutdown"
  reboot="\tReboot"
  suspend="\tSuspend"
  options="$poweroff\n$reboot\n$lock\n$away\n$hibernate\n$suspend\n$logout"

  # HACK: Cut out messed up whitespaces using xargs
  # TODO: A faster version which doesn't use xargs
  case "$(echo -e "$options" | $rofi_cmd -dmenu -selected-row 2 | xargs)" in
      # HACK: Trim original menu items so that they have only one space
      $(trim $away))
          ${cmds.away}
          ;;
      $(trim $hibernate))
          ${cmds.hibernate}
          ;;
      $(trim $lock))
          ${cmds.lock}
          ;;
      $(trim $logout))
          ${cmds.logout}
          ;;
      $(trim $poweroff))
          ${cmds.poweroff}
          ;;
      $(trim $reboot))
          ${cmds.reboot}
          ;;
      $(trim $suspend))
          ${cmds.suspend}
          ;;
  esac
''
