# Read after /etc/zshenv, which exports ZDOTDIR and points zsh here. This file
# is live: editing it takes effect in the next shell, with no rebuild.

export TERM=xterm-256color
export LS_COLORS=""
export KEYTIMEOUT=1

# In .zshenv rather than .zshrc so non-interactive shells get them too, which
# is what home-manager's session file did. Nothing in /etc declares these
# arrays unique, and this file runs for every zsh, so a nested shell would
# otherwise accumulate duplicates.
typeset -U path cdpath fpath manpath

# Prepended, not appended: the point of an npm prefix is that what it installs
# wins over the same name from a profile. home-manager's session file prepended
# too.
path=(
  "$HOME/.npm-global/bin"
  "${XDG_CONFIG_HOME:-$HOME/.config}/emacs/bin"
  $path
)
