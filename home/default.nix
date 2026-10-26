{ config, lib, pkgs, ... }:
let
  nixosConfig = config;
in
{

  imports = [
    ./agent-jail.nix
    ./alacritty.nix
    ./ai.nix
    ./docker.nix
    ./doom-emacs.nix
    ./dotfiles.nix
    ./neovim.nix
    ./tmux.nix
    # ./virtualbox.nix
    ./xsession.nix
    ./zsh.nix
  ];

  services.ollama.enable = true;

  # environment.sessionVariables (pam-environment) are set earlier in the login
  # process than environment.variables which are shell specific.
  environment.sessionVariables = {
    # These are the XDG defaults, declared because nothing else sets them now
    # that home-manager's xdg.enable is gone, and because pam_environment is
    # read before any shell file -- so an X-launched process sees them too.
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
    XDG_BIN_HOME = "$HOME/.local/bin";

    # Enables installing with `npm install -g` and the sources go to $HOME/.npm-global
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
  };

  users.users.${nixosConfig.customParams.userName}.packages =
    with pkgs;
    let
      tex = (
        texlive.combine {
          inherit (texlive)
            scheme-medium
            wrapfig
            ulem
            amsmath
            hyperref
            capt-of
            metafont
            beamer
            ;
        }
      );
    in
    [
      # AI tools
      unstable.copilot-language-server
      unstable.llm

      azure-cli # Azure CLI
      awscli2 # AWS CLI
      broot # Directory tree viewer
      chromium # MS Teams works better in chromium
      firefox # Second engine, for testing local services
      dbeaver-bin # Database client
      pass # Password store
      age  # Encryption tool
      spotify
      tex
      tor-browser # Tor browser
      # unstable.code-cursor      # AI powered code editor
      unstable.signal-desktop # Signal messaging app desktop client
    ];

  # Each type is named because xdg-open does not walk shared-mime-info's
  # subclass chain: text/x-python would not inherit text/plain's entry.
  # These land in /etc/xdg/mimeapps.list. A ~/.config/mimeapps.list overrides it
  # per MIME type, not wholesale, and any such file is one an application wrote
  # in place rather than a home-manager leftover -- so it may hold live
  # associations and is to be read, not deleted.
  xdg.mime.defaultApplications =
    lib.genAttrs [
      "application/json"
      "application/toml"
      "application/x-shellscript"
      "application/yaml"
      "text/css"
      "text/markdown"
      "text/plain"
      "text/x-csrc"
      "text/x-emacs-lisp"
      "text/x-lua"
      "text/x-python"
      "text/x-tex"
    ] (_: "gvim.desktop")
    // lib.genAttrs [
      "image/gif"
      "image/jpeg"
      "image/png"
    ] (_: "feh.desktop")
    // {
      "application/pdf" = "mupdf.desktop";
      "inode/directory" = "pcmanfm.desktop";
    };

  # Kept as a placeholder: these are home-manager option names and would need
  # rewriting for NixOS, or for a live dotfile, if vscode is ever enabled.
  # programs.vscode = {
  #   enable = true;
  #   profiles.default.extensions = with pkgs.unstable.vscode-extensions; [
  #     github.copilot
  #     github.copilot-chat
  #     ms-azuretools.vscode-containers
  #     enkia.tokyo-night
  #   ];
  #   profiles.default.userSettings = {
  #     "workbench.colorTheme" = "Tokyo Night Storm";
  #     "terminal.integrated.fontFamily" = "JetBrains Mono";
  #     "editor.fontFamily" = "JetBrains Mono";
  #     "chat.fontFamily" = "JetBrains Mono";
  #     "chat.customAgentInSubagent.enabled" = "true";
  #   };
  # };

}
