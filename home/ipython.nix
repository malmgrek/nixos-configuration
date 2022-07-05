{ config, lib, pkgs, ... }:

{
  environment.variables = {
    IPYTHONDIR = "$XDG_CONFIG_HOME/ipython";
  };
  home-manager.users.${config.customParams.userName} = {
    xdg.configFile."ipython/profile_default/ipython_config.py".text = ''
      c.TerminalInteractiveShell.editing_mode = "vi"
      c.TerminalInteractiveShell.emacs_bindings_in_vi_insert_mode = False
    '';
  };
}
