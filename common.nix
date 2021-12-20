# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
#
# TODO: Networking localhost, hostName
#

{ config, pkgs, lib, ... }:

with lib; {

  imports = [
    # Introduces options that are assumed
    # available in all Nix modules
    ./options.nix
  ];

  nixpkgs.overlays = import ./packages.nix;
  nixpkgs.config.allowUnfree = true;

  networking = {
    networkmanager.enable = true;
    # The global useDHCP flag is deprecated, therefore explicitly set to false
    # here. Per-interface useDHCP will be mandatory in the future, so this
    # generated config replicates the default behaviour.
    useDHCP = false;
    interfaces.enp0s31f6.useDHCP = true;
    firewall.enable = true;
  };

  hardware = {
    # Replaces xbacklight
    acpilight = {
      enable = true;
    };
    bluetooth = {
      enable = mkDefault true;
      package = mkDefault pkgs.bluezFull;
    };
    pulseaudio = {
      enable = true;
    } // (
      # NixOS allows either a lightweight build (default) or full build of
      # PulseAudio to be installed. Only the full build has Bluetooth support,
      # so it must be selected if bluetooth is enabled.
      if config.hardware.bluetooth.enable
      then { package = pkgs.pulseaudioFull; }
      else { }
    );
  };

  services = {
    blueman.enable = true;
    openssh.enable = true;
    # CUPS is started automatically for printing. Printers can be configured
    # on web browser at http://localhost:631/admin
    printing = {
      enable = true;
      webInterface = true;
      drivers = with pkgs; [ gutenprint ];
    };
    avahi = {
      enable = true;
      nssmdns = true;
    };
    xserver = {
      enable = true;
      libinput = {
        enable = true;
        touchpad.tapping = false;
      };
      layout = "fi,us,gr";
      xkbOptions = "grp:alt_shift_toggle,caps:escape";
      autoRepeatDelay = 300;
      autoRepeatInterval = 12;
    };
  };

  programs = {
    # Some programs need SUID wrappers, can be configured further or are started
    # in user sessions.
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    light.enable = true;
  };

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  console = {
    # font = "Lat2-Terminus16";
    keyMap = "fi";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [

    # Terminal emulators
    alacritty
    rxvt-unicode  # urxvt
    xst

    # CLI programs
    acpi        # Battery status etc.
    binutils
    coreutils
    git
    gnumake
    htop
    killall
    lm_sensors  # Read hardware sensor info
    ranger
    ripgrep
    tmux
    unzip
    usbutils
    wget
    zip

    # Text editors
    vim
    kakoune
    xclip

    # Office suite
    evince
    feh
    gimp
    inkscape
    libreoffice
    luakit       # Vim-esque web browser
    mupdf
    okular

    # Media
    pavucontrol  # GUI for sound control
    vlc

    # VPN
    openvpn

    # Password hash generator
    mkpasswd
    openssl

    # Android
    jmtpfs

  ];

}

