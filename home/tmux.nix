{ config, lib, pkgs, ... }:

let
  # Snazzy Theme (ivnxvd/tmux-snazzy)
  lightTheme = ''
    # default statusbar colors
    set-option -g status-style bg=colour15,fg=colour205

    # default window title colors
    set-window-option -g window-status-style fg=colour123,bg=default,dim

    # active window title colors
    set-window-option -g window-status-current-style fg=colour84,bg=default,bright

    # pane border
    set-option -g pane-border-style fg=colour81
    set-option -g pane-active-border-style fg=colour84

    # message text
    set-option -g message-style bg=colour81,fg=colour17

    # pane number display
    set-option -g display-panes-active-colour colour203
    set-option -g display-panes-colour colour84

    # clock
    set-window-option -g clock-mode-colour colour205
  '';
  darkTheme = ''
    # default statusbar colors
    set-option -g status-style bg=colour0,fg=colour213

    # default window title colors
    set-window-option -g window-status-style fg=colour123,bg=default,dim

    # active window title colors
    set-window-option -g window-status-current-style fg=colour149,bg=default,bright

    # pane border
    set-option -g pane-border-style fg=colour81
    set-option -g pane-active-border-style fg=colour149

    # message text
    set-option -g message-style bg=colour81,fg=colour17

    # pane number display
    set-option -g display-panes-active-colour colour203
    set-option -g display-panes-colour colour149

    # clock
    set-window-option -g clock-mode-colour colour213
  '';
in {
  home-manager.users.${config.customParams.userName} = {
    programs.tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
      mouse = true;
      prefix = "C-a";
      terminal = "screen-256color";
      plugins = with pkgs.tmuxPlugins; [
        pain-control
        # onedark-theme
        resurrect
        # {
        #   plugin = dracula;
        #   extraConfig = ''
        #     set -g @dracula-show-powerline true
        #     set -g @dracula-fixed-location "Helsinki"
        #     set -g @dracula-plugins "weather"
        #     set -g @dracula-show-flags true
        #     set -g @dracula-show-left-icon session
        #   '';
        # }
      ];
      extraConfig = ''
        # Enable true colors in tmux
        set -ga terminal-overrides ",*256col*:Tc"

        # Set status bar to top
        # set -g status-position top

        # Theme
        ${if config.lightMode.enable then lightTheme else darkTheme}

      '';
    };
  };
}
