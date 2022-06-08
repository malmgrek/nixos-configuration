{ config, lib, pkgs, ... }:
let
  ps = pkgs.python3Packages;
  vimBinding = pkgs.fetchFromGitHub {
    owner = "lambdalisue";
    repo = "jupyter-vim-binding";
    rev = "v2.1.0";
    sha256 = "1951wnf0k91h07nfsz8rr0c9nw68dbyflkjvw5pbx9dmmzsa065j";
  };
  rise = ps.buildPythonPackage rec {
    pname = "rise";
    version = "5.7.1";
    src = ps.fetchPypi {
      pname = pname;
      version = version;
      sha256 = "19l9a84vf3lh5gjl4rclkbx16f11zpbrhc05vkkgaywhrdvvf7b4";
    };
    propagatedBuildInputs = with ps; [ notebook ];
    doCheck = true;
  };
  notebookJSON = builtins.toJSON {
    load_extensions = {
      "vim_binding/vim_binding" = true;
      "rise/main" = true;
    };
  };
in
{
  environment.variables = {
    JUPYTER_CONFIG_DIR = "$XDG_CONFIG_HOME/jupyter";
    JUPYTER_DATA_DIR = "$XDG_DATA_HOME/jupyter";
  };
  home-manager.users.${config.customParams.userName} = {
    xdg.dataFile = {
      "jupyter/nbextensions/vim_binding" = {
        source = vimBinding;
      };
      "jupyter/nbextensions/rise" = {
        source = "${rise}/${ps.python.sitePackages}/rise/static";
      };
    };
    xdg.configFile."jupyter/nbconfig/notebook.json" = {
      text = notebookJSON;
    };
  };
}
