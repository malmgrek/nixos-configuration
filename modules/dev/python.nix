# modules/dev/python.nix --- https://godotengine.org/
#
# Python's ecosystem repulses me. The list of environment "managers" exhausts
# me. The Py2->3 transition make trainwrecks jealous. But SciPy, NumPy, iPython
# and Jupyter can have my babies. Every single one.

{ config, options, lib, pkgs, ... }:
with lib;
{
  options.modules.dev.python = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.dev.python.enable {
    my = {
      packages = with pkgs; [
        conda
        python37
        python37Packages.black
        python37Packages.ipython
        python37Packages.magic-wormhole
        python37Packages.pip
        python37Packages.poetry
        python37Packages.pylint
        python37Packages.setuptools
      ];

      env.IPYTHONDIR      = "$XDG_CONFIG_HOME/ipython";
      env.PIP_CONFIG_FILE = "$XDG_CONFIG_HOME/pip/pip.conf";
      env.PIP_LOG_FILE    = "$XDG_DATA_HOME/pip/log";
      env.PYLINTHOME      = "$XDG_DATA_HOME/pylint";
      env.PYLINTRC        = "$XDG_CONFIG_HOME/pylint/pylintrc";
      env.PYTHONSTARTUP   = "$XDG_CONFIG_HOME/python/pythonrc";
      env.PYTHON_EGG_CACHE = "$XDG_CACHE_HOME/python-eggs";
      env.JUPYTER_CONFIG_DIR = "$XDG_CONFIG_HOME/jupyter";
      env.JUPYTER_DATA_DIR = "$XDG_DATA_HOME/jupyter";

      alias.py  = "python";
      alias.py2 = "python2";
      alias.py3 = "python3";
      alias.po  = "poetry";
      alias.ipy = "ipython --no-banner";
      alias.ipylab = "ipython --pylab=qt5 --no-banner";

      home.xdg.configFile."ipython/profile_default/ipython_config.py" = {
        source = <config/ipython/profile_default/ipython_config.py>;
      };
      home.xdg.configFile."python/pythonrc" = {
        source = <config/python/pythonrc>;
      };
      # Enable the extension by:
      # jupyter nbextension enable vim_binding/vim_binding
      home.xdg.dataFile."jupyter/vim_binding" = {
        recursive = true;
        source = pkgs.fetchFromGitHub {
          owner = "lambdalisue";
          repo = "jupyter-vim-binding";
          rev = "v2.1.0";
          sha256 = "1951wnf0k91h07nfsz8rr0c9nw68dbyflkjvw5pbx9dmmzsa065j";
        };
      };
    };
  };
}
