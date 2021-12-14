{ config, lib, pkgs, ... }:
let
  vimBinding = pkgs.fetchFromGitHub {
    owner = "lambdalisue";
    repo = "jupyter-vim-binding";
    rev = "v2.1.0";
    sha256 = "1951wnf0k91h07nfsz8rr0c9nw68dbyflkjvw5pbx9dmmzsa065j";
  };
  notebookJSON = builtins.toJSON {
    load_extensions = {
      "vim_binding/vim_binding" = true;
    };
  };
in
{
  environment.variables = {
    JUPYTER_CONFIG_DIR = "$XDG_CONFIG_HOME/jupyter";
    JUPYTER_DATA_DIR = "$XDG_DATA_HOME/jupyter";
  };
  home-manager.users.${config.customParams.userName} = {
    xdg.dataFile."jupyter/nbextensions/vim_binding" = {
      source = vimBinding;
    };
    xdg.configFile."jupyter/nbconfig/notebook.json" = {
      text = notebookJSON;
    };
  };
}
