{ shell, cmds }:

''
  #!${shell}

  ${cmds.rofi} -show drun -modi drun,run -show-icons
''
