{ shell, cmds }:

''
  #!${shell}

  rofi_cmd='${cmds.rofi}'

  trim ()
  {
    # Replace a tab with a space
    echo ''${1//\\t/ }
  }

  # Options
  hibernate="❄\tHibernate"
  lock="\tLock"
  logout="出\tLogout"
  poweroff="\tShutdown"
  reboot="⭮\tReboot"
  suspend="⏾\tSuspend"
  # Variable passed to rofi
  options="$poweroff\n$reboot\n$lock\n$hibernate\n$suspend\n$logout"

  # Through Rofi, user selects a string value. If the string contains a tab, the
  # string comparisons in cases don't match. Piping the selected string through
  # xargs formats whitespaces as single spaces. Moreover, the case strings are
  # trimmed similarly.
  case "$(echo -e "$options" | $rofi_cmd -dmenu -selected-row 2 | xargs)" in
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
