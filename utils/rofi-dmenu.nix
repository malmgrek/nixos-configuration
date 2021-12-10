{ shell, cmds }:

''
  #!/usr/bin/env sh

  ${cmds.rofi} -show run -modi run
''
