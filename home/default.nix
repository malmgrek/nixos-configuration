{ config, pkgs, ... }:
let
  home-manager = builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/release-21.05.tar.gz";
in {

  imports = [
    (import "${home-manager}/nixos")
    ./alacritty.nix
    ./direnv.nix
    ./docker.nix
    ./doom-emacs.nix
    ./firefox.nix
    ./ipython.nix
    ./jupyter.nix
    ./shells.nix
    ./vim.nix
    ./xsession.nix
    ./virtualbox.nix
  ];

  # environment.sessionVariables (pam-environment) are set earlier in the login
  # process than environment.variables which are shell specific.
  environment.sessionVariables = {
    # These are the defaults, and xdg.enable does set them, but due to load
    # order, they're not set before environment.variables are set, which could
    # cause race conditions.
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_BIN_HOME = "$HOME/.local/bin";
  };

  home-manager.users.${config.customParams.userName} = {
    xdg.enable = true;
    # Home Manager's system state. Has effect on some default settings such as
    # xdg. Let's use same value as that of the whole system.
    home.stateVersion = config.system.stateVersion;
    home.packages = with pkgs; [
      broot     # Directory tree viewer
      pass      # Password store
      chromium  # MS Teams works better in chromium
    ];
  };

}
