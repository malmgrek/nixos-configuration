# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
#
# TODO: Networking localhost, hostName
#

{ config, pkgs, lib, ... }:

{

  nixpkgs.overlays = import ./packages.nix;
  nixpkgs.config.allowUnfree = true;

  networking = {
    networkmanager.enable = true;
    # The global useDHCP flag is deprecated, therefore explicitly set to false
    # here. Per-interface useDHCP will be mandatory in the future, so this
    # generated config replicates the default behaviour.
    useDHCP = false;
    interfaces.enp0s31f6.useDHCP = true;
    # Firewall is enabled by default
    firewall.enable = true;
  };

  hardware = {
    # Replaces xbacklight
    acpilight = {
      enable = true;
    };
    bluetooth = {
      enable = lib.mkDefault true;
      package = lib.mkDefault pkgs.bluezFull;
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
    printing = {
      enable = true;
      webInterface = true;
      drivers = with pkgs; [ gutenprint ];
    };
    xserver = {
      enable = true;
      libinput = {
        enable = true;
        touchpad.tapping = false;
      };
      layout = "fi,us,gr";
      xkbOptions = "grp:alt_shift_toggle";
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
    broot       # Directory tree viewer
    coreutils
    git
    gnumake
    htop
    killall
    lm_sensors  # Read hardware sensor info
    pass        # Password store
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

