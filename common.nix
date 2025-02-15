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

  nixpkgs.overlays = import ./overlays.nix;
  nixpkgs.config.allowUnfree = true;

  environment.sessionVariables = {
    EDITOR = "vi";
  };

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
      package = mkDefault pkgs.bluez;
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
    # When upgrading 24.05 –> 24.11 PipeWire became default audio server.
    # Without explicitly disabling it causes a nixos-rebuild error.
    # TODO: Change from pulseaudio to pipewire.
    pipewire.enable = false;
    blueman.enable = true;
    openssh = {
      enable = true;
      settings = {
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
    # CUPS is started automatically for printing. Printers can be configured
    # on web browser at http://localhost:631/admin
    printing = {
      enable = true;
      webInterface = true;
      drivers = with pkgs; [ gutenprint ];
    };
    avahi = {
      enable = true;
      nssmdns4 = true;
    };
    libinput = {
      enable = true;
      touchpad.tapping = false;
    };
    xserver = {
      enable = true;
      xkb = {
        layout = "fi,us,gr";
        options = "grp:alt_shift_toggle,caps:escape";
      };
      autoRepeatDelay = 300;
      autoRepeatInterval = 12;
    };
    # Openvpn3 requires systemd-resolved this after NixOS 24.11
    resolved = {
      enable = true;
      # Are there some other important settings?
    };
  };

  programs = {
    # Android debug bridge
    adb.enable = true;
    # Some programs need SUID wrappers, can be configured further or are started
    # in user sessions.
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    light.enable = true;
    mtr.enable = true;
    openvpn3.enable = true;
    zsh.enable = true;
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
    acpi         # Battery status etc.
    bat          # Better cat
    binutils
    coreutils
    dig          # DNS lookup utility
    eza          # Better ls
    # fasd
    fd           # Better find
    git
    gnumake
    killall
    lm_sensors   # Read hardware sensor info
    pandoc       # Document format conversion
    pciutils     # PCI utils, e.g., lspci
    ranger
    ripgrep
    ripgrep-all
    tldr         # Man for dummies
    tree
    tmux
    unzip
    usbutils
    wget
    zip

    # System monitoring
    btop
    htop
    gtop

    # Backup
    borgbackup

    # Programming
    gcc
    cmake
    nodejs
    python3

    # Text editors
    kakoune
    neovim
    vim
    xclip

    # Office suite
    evince       # Gnome default PDF viewer
    feh          # Simplest image viewer
    gimp         # Open source Photoshop
    graphviz     # Graph visualization
    pkgs.unstable.inkscape     # Open source Illustrator
    libreoffice  # Open source Office
    luakit       # Vim-esque web browser
    nyxt         # Another vim-esque web browser
    mupdf        # Vim-esque lightweight PDF reader
    okular       # Fancy PDF reader with annotations tools
    xournal      # Add images over PDF

    # Email
    thunderbird

    # Torrent
    transmission_4-gtk

    # Multimedia tools
    ffmpeg
    imagemagick
    ghostscript

    # Media
    audacity
    pavucontrol  # GUI for sound control
    vlc

    # VPN
    openvpn
    openvpn3  # Client with web-SAML capability

    # Password hash generator
    mkpasswd
    openssl

    # File system
    pcmanfm       # File browser with GUI
    jmtpfs        # Mount Android
    gparted       # Disk formatter (run as sudo)
    ntfs3g        # Enable mounting NTFS (windows) filesystems
    syncthing     # Continuous file synchronization
    # Another disk formatter, useful GUI for creating
    # LUKS encrypted ext4 partitions
    gnome-disk-utility

  ];

}

