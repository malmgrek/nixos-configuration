{ shell, cmds }:

''
  #!/usr/bin/env sh

  ${cmds.rofi} -show drun -modi drun,run -show-icons
''
