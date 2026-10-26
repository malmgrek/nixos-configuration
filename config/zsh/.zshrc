# Read after /etc/zshrc, which carries the plugins, the completion system and
# the direnv, fzf and autojump hooks. This file is live: editing it takes
# effect in the next shell, with no rebuild. Settings repeated from the system
# file are deliberate -- the later value wins, and these are the chosen ones.

# Use viins keymap as the default.
bindkey -v

autoload zmv # Better "mv"

# History. Not under $ZDOTDIR: that directory is a link into this repository,
# and shell history is neither a decision worth committing nor anything to
# publish.
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
mkdir -p "$(dirname "$HISTFILE")"

setopt HIST_FCNTL_LOCK HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY
setopt NO_APPEND_HISTORY NO_EXTENDED_HISTORY NO_HIST_EXPIRE_DUPS_FIRST
setopt NO_HIST_FIND_NO_DUPS NO_HIST_IGNORE_ALL_DUPS NO_HIST_SAVE_NO_DUPS

alias ls='eza'
alias ll='eza -l'
alias lla='eza -la'
alias llt='eza -T'
alias llfu='eza -bghGliS --git'
alias zcp='zmv -C'
alias zln='zmv -L'
