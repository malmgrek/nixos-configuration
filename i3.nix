#
# Desktop environment based on i3-gaps
#

{ config, options, pkgs, lib, ...}:

let
  rofiCmd = "${pkgs.rofi}/bin/rofi -theme /etc/rofi/config.rasi -dpi ${(
    toString
      (if config.hidpiHacks.enable then config.customParams.dpi else 0)
  )}";
  # Shared by every lock mode, so the prompt a mode shows cannot drift from the
  # one the other modes show.
  xsecurelock-prompt = ''
    export XSECURELOCK_PASSWORD_PROMPT=asterisks
    export XSECURELOCK_FONT='JetBrains Mono'
    export XSECURELOCK_AUTH_BACKGROUND_COLOR='#1d2021'

    # When connected on dual monitor, a minor incompatibility issue between
    # Picom and xsecurelock may cause flickering error message on screen.
    # Hides the message.
    export XSECURELOCK_COMPOSITE_OBSCURER=0
  '';
  xsecurelock-xscreensaver = pkgs.writeScriptBin "xsecurelock-xscreensaver" (
    ''
      #!/bin/sh

      export XSECURELOCK_SAVER=saver_xscreensaver
      ${xsecurelock-prompt}
      exec ${pkgs.xsecurelock}/bin/xsecurelock
    ''
  );
  # Away mode's locker. The blank timeout and DPMS state are set explicitly
  # rather than inherited: drawing nothing is the point of the mode, so an
  # upstream default change must not be able to take it away silently.
  xsecurelock-blank = pkgs.writeScriptBin "xsecurelock-blank" (
    ''
      #!/bin/sh

      export XSECURELOCK_SAVER=saver_blank
      export XSECURELOCK_BLANK_TIMEOUT=0
      export XSECURELOCK_BLANK_DPMS_STATE=off
      ${xsecurelock-prompt}
      exec ${pkgs.xsecurelock}/bin/xsecurelock
    ''
  );
  # Wrap to script so we can use it in i3/config (xss-lock).
  # The dim time should match that of xset s.
  xsecurelock-dimmer = pkgs.writeScriptBin "xsecurelock-dimmer" (
    ''
      #!/bin/sh

      export XSECURELOCK_DIM_ALPHA=1.0
      export XSECURELOCK_DIM_TIME_MS=10000
      export XSECURELOCK_WAIT_TIME_MS=5000
      dimmer=${pkgs.xsecurelock}/libexec/xsecurelock/dimmer
      until_nonidle=${pkgs.xsecurelock}/libexec/xsecurelock/until_nonidle
      $until_nonidle $dimmer
    ''
  );
  away-mode = pkgs.writeScriptBin "away-mode" (
    ''
      #!/bin/sh

      # Anything `timeout` accepts can be typed instead of picking one of these.
      limit=$(
        printf '30m\n1h\n2h\n4h\n8h\nnever\n' |
          ${rofiCmd} -dmenu -p 'Stay awake for'
      )

      # Dismissing rofi selects nothing, which must leave the session unlocked.
      [ -n "$limit" ] || exit 0

      # `timeout 0` runs without a limit.
      [ "$limit" = never ] && limit=0

      # Checked before anything locks: timeout takes one number and one suffix,
      # so `1h30m` fails, and a refusal under a blank screen could not be seen.
      if ! ${pkgs.coreutils}/bin/timeout "$limit" true 2>/dev/null; then
        ${pkgs.libnotify}/bin/notify-send 'away mode' "Not a usable duration: $limit"
        exit 1
      fi

      # Otherwise the idle chain dims and draws its screensaver over the blank
      # lock. 300 10 is the value config/i3/config sets.
      ${pkgs.xset}/bin/xset s off
      trap '${pkgs.xset}/bin/xset s 300 10' EXIT INT TERM HUP

      ${xsecurelock-blank}/bin/xsecurelock-blank &
      locker=$!

      # The inhibitor is this process's, so the lid is live again the moment the
      # mode ends. Returns when the locker exits, or at the deadline.
      ${pkgs.systemd}/bin/systemd-inhibit --what=handle-lid-switch --why='away mode' \
        ${pkgs.coreutils}/bin/timeout "$limit" \
        ${pkgs.coreutils}/bin/tail --pid="$locker" -f /dev/null
      reached_deadline=$?

      # 124 means timeout killed the wait, so only the deadline suspends. Any
      # other failure leaves a plain lock rather than away mode.
      [ "$reached_deadline" -eq 124 ] && ${pkgs.systemd}/bin/systemctl suspend
    ''
  );
  rofi-power-menu = pkgs.writeScriptBin "rofi-power-menu" (
    import ./utils/rofi-power-menu.nix {
      cmds = {
        rofi = rofiCmd;
        away = "${away-mode}/bin/away-mode";
        hibernate = "systemctl hibernate";
        lock = "loginctl lock-session";
        logout = "i3-msg exit";
        poweroff = "systemctl poweroff";
        reboot = "systemctl reboot";
        suspend = "systemctl suspend";
      };
    }
  );
  rofi-app-menu = pkgs.writeScriptBin "rofi-app-menu" (
    ''
      #!/bin/sh

      ${rofiCmd} -show drun -modi drun,run -show-icons
    ''
  );
  rofi-dmenu = pkgs.writeScriptBin "rofi-dmenu" (
    ''
      #!/bin/sh

      ${rofiCmd} -show run -modi run
    ''
  );
  rofi-file-menu = pkgs.writeScriptBin "rofi-file-menu" (
    ''
      #!/bin/sh

      ${rofiCmd} -modi filebrowser,recursivebrowser -show filebrowser
    ''
  );
  rofi-pass-menu = pkgs.writeScriptBin "rofi-pass-menu" (
    ''
      #!/bin/sh

      store="''${PASSWORD_STORE_DIR:-$HOME/.password-store}"

      entry=$(
        find "$store" -type f -name '*.gpg' \
          | sed "s|^$store/||;s|\.gpg$||" \
          | ${rofiCmd} -dmenu -p pass
      )

      # Dismissing rofi selects nothing, and `pass -c` with no argument prints
      # the store tree rather than doing nothing.
      [ -n "$entry" ] || exit 0

      # i3 gives a spawned process nowhere to put stderr, so a failing `pass`
      # would be indistinguishable from a working one.
      ${pkgs.pass}/bin/pass -c "$entry" ||
        ${pkgs.libnotify}/bin/notify-send 'pass' "Could not copy $entry"
    ''
  );
  rofi-window-menu = pkgs.writeScriptBin "rofi-window-menu" (
    ''
      #!/bin/sh

      ${rofiCmd} -show window -show-icons
    ''
  );
in {
  config = {

    environment = {

      systemPackages = with pkgs; [
        arandr
        dmenu
        dunst
        flameshot  # Screen shoot
        i3status
        i3status-rust
        libnotify  # Enables notify-send
        lightdm
        networkmanagerapplet
        peek  # Screen rec
        dconf  # Required by peek
        rofi
        kdePackages.spectacle  # Screen shoot
        udiskie  # Removable media daemon
        xscreensaver
        xss-lock

        # Custom wrappers
        away-mode
        rofi-app-menu
        rofi-dmenu
        rofi-file-menu
        rofi-pass-menu
        rofi-power-menu
        rofi-window-menu
        xsecurelock-blank
        xsecurelock-dimmer
        xsecurelock-xscreensaver
      ];

      # Write global config files
      etc = {
        # The i3status-rust daemon is started in i3 config.
        "i3status-rs/config.toml" = {
          source = ./config/i3status-rs/config.toml;
        };
        "dunstrc" = {
          text = (
            builtins.replaceStrings
              [ "# GEOMETRY" ]
              [ "geometry = \"${
                if config.hidpiHacks.enable then "600x10-30+40"
                else "300x5-30+24"
              }\"" ]
              (builtins.readFile ./config/dunst/dunstrc)
          );
        };
       "rofi/config.rasi" = {
          source = ./config/rofi/config.rasi;
        };
      };

    };

    fonts = {

      fontDir.enable = true;
      enableGhostscriptFonts = true;
      packages = with pkgs; [
        dejavu_fonts
        fira-code
        fira-code-symbols
        font-awesome
        jetbrains-mono
        nerd-fonts.fira-code
        nerd-fonts.hack
        # NOTE: nerd-fonts.jetbrains-mono also exists, should use instead?
        nerd-fonts.sauce-code-pro
        nerd-fonts.symbols-only
        nerd-fonts.ubuntu-mono
        noto-fonts
        noto-fonts-color-emoji
        ubuntu-classic
        powerline-fonts
      ];

      fontconfig.defaultFonts = {
        sansSerif = [ "Ubuntu" ];
        monospace = [ "Deja Vu Sans Mono" ];
        emoji = [ "Noto Color Emoji" ];
      };

    };

    services = {
      actkbd = {
        enable = true;
        bindings = let
          brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
          step = "1%";
        in [
          {
            keys = [ 224 ];
            events = [ "key" ];
            command = "${brightnessctl} set ${step}- --min-value=1";
          }
          {
            keys = [ 225 ];
            events = [ "key" ];
            command = "${brightnessctl} set ${step}+";
          }
        ];
      };
      picom = {
        enable = true;
        # Apps, such as Firefox may flicker without v-sync and GLX backend
        vSync = true;
        backend = lib.mkDefault "glx";
        activeOpacity = 1.0;
        inactiveOpacity = 0.8;
        shadow = true;
        # fade = true;
        # fadeDelta = 5;
      };
      # Automatic screen color management
      redshift = {
        enable = true;
        brightness = {
          day = "1";
          night = "1";
        };
        temperature = {
          day = 7500;
          night = 4500;
        };
      };
      displayManager = {
        defaultSession = "none+i3";
      };
      xserver = {
        desktopManager.xterm.enable = false;
        displayManager = {
          lightdm = {
            enable = true;
            greeters.gtk = {
              enable = true;
            };
          };
        };
        windowManager = {
          i3 = {
            enable = true;
            configFile = ./config/i3/config;
            package = pkgs.i3;
          };
        };
      };
      # USB mounting
      gvfs = { enable = true; };
      udisks2 = { enable = true; };
    };

  };
}
