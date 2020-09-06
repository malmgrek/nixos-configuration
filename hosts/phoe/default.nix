# Phoe -- my laptop

{ pkgs, ... }:
{

  imports = [
    ../common.nix
    ./hardware-configuration.nix
  ];

  modules = {
    desktop = {
      bspwm.enable = true;
      apps.rofi.enable = true;
      term.st.enable = true;
      browsers.default = "firefox";
      browsers.firefox.enable = true;
    };
    editors = {
      default = "vim";
      emacs.enable = true;
      vim.enable = true;
    };
    shell = {
      # direnv
      git.enable = true;
      gnupg.enable = true;
      pass.enable = true;
      tmux.enable = true;
      zsh.enable = true;
    };
  };

}
