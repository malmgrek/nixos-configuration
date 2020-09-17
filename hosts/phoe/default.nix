# Phoe -- my laptop

{ pkgs, ... }:
{

  imports = [
    ../common.nix
    ./hardware-configuration.nix
  ];

  modules = {
    desktop = {
      wm.i3.enable = true;
      wm.i3.i3status-rust = true;
      apps.rofi.enable = true;
      term.alacritty.enable = true;
      term.st.enable = false;
      term.default = "alacritty";
      browsers.firefox.enable = true;
      browsers.default = "firefox";
    };
    editors = {
      default = "vi";
      emacs.enable = true;
      vim.enable = true;
    };
    dev = {
      clojure.enable = true;
      node.enable = true;
      python.enable = true;
    };
    services = {
      docker.enable = false;
      nginx.enable = false;
      sshd.enable = false;
    };
    shell = {
      direnv.enable = false;
      git.enable = true;
      gnupg.enable = true;
      pass.enable = true;
      ranger.enable = true;
      tmux.enable = true;
      weechat.enable = false;
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
