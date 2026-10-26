{ pkgs, ... }:

{

  # Only the plugins live here: their paths exist once the system is built, so
  # they stay in /etc/tmux.conf, which tmux reads before the live
  # config/tmux/tmux.conf linked by dotfiles.nix. Everything else is in that
  # file, including the theme until 021 makes the colour mode a runtime choice.
  programs.tmux = {
    enable = true;
    # Default true, and the only setgid-utmp wrapper this system would carry;
    # its one effect is that `who` and `w` list tmux panes.
    withUtempter = false;
    plugins = with pkgs.tmuxPlugins; [
      pain-control
      # onedark-theme
      # dracula  -- its settings are commented beside the theme in tmux.conf
      resurrect
    ];
  };

}
