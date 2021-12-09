{ shell, cmds }:

''
  #!/usr/bin/env sh

  ${cmds.rofi} -show window -show-icons
''
