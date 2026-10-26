{ config, pkgs, ... }:

{

  users.users.${config.customParams.userName} = {
    shell = pkgs.zsh;
    # On fpath through NIX_PROFILES, which /etc/zshenv walks: zsh-completions
    # ships only site-functions, and pure ships prompt_pure_setup there.
    packages = with pkgs; [
      zsh-completions
      pure-prompt
    ];
  };

  # Each adds its own hook to /etc/zshrc, so there is no integration flag to
  # set: the system file is read before the user's own.
  programs = {
    direnv.enable = true;
    # No `enable` on this one; either option pulls in the package. Both, to
    # match the completion and keybindings home-manager's integration gave.
    fzf.keybindings = true;
    fzf.fuzzyCompletion = true;
    autojump.enable = true;
    # starship.enable = true;

    zsh = {
      # /etc/zshenv is read before zsh looks for any user file, which is what
      # lets the user's own files live under XDG with nothing in $HOME to point
      # at them. Home-manager used a one-line ~/.zshenv bootstrap instead.
      shellInit = ''
        export ZDOTDIR="$HOME/.config/zsh"
      '';

      # These two have NixOS modules of their own. The syntax-highlighting one
      # appends to interactiveShellInit with mkAfter, so it orders itself last
      # without being asked, which is where it has to be.
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;

      # Autopair is a plain source, so it goes here. The store path lives in
      # /etc/zshrc and the live .zshrc names none of them.
      interactiveShellInit = ''
        source ${pkgs.zsh-autopair}/share/zsh/zsh-autopair/autopair.zsh
      '';

      # The prompt must go through promptInit, not interactiveShellInit: the
      # module renders promptInit later in /etc/zshrc, and its default is
      # `prompt suse`, which would otherwise replace pure while leaving pure's
      # precmd hooks installed -- a hybrid prompt rather than either theme.
      promptInit = "autoload -U promptinit && promptinit && prompt pure";
    };
  };

}
