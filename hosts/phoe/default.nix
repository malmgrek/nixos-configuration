# Phoe -- my laptop

{ pkgs, ... }:
{

  imports = [
    ../common.nix
    ./hardware-configuration.nix
  ];

  modules = {
    desktop = {
      i3.enable = true;
      apps.rofi.enable = true;
      term.alacritty.enable = true;
      # term.st.enable = true;
      browsers.default = "firefox";
      browsers.firefox.enable = true;
    };
    editors = {
      default = "vim";
      emacs.enable = true;
      vim.enable = true;
    };
    # dev = {
    #   python.enable = true;
    # };
    shell = {
      # direnv.enable = true;
      git.enable = true;
      gnupg.enable = true;
      pass.enable = true;
      ranger.enable = true;
      tmux.enable = true;
      zsh.enable = true;
    };
  };

  programs.ssh.startAgent = true;

  # NOTE: With this option:
  #
  #     networking.wireless.enable = true;
  #
  # the build fails
  # but enabling networkmanager solves it.
  networking.networkmanager.enable = true;

  hardware.opengl.enable = true;

  time.timeZone = "Europe/Helsinki";

  # Optimize power usage
  environment.systemPackages = [ pkgs.acpi ];
  powerManagement.powertop.enable = true;

  # Backlight control
  programs.light.enable = true;

}
