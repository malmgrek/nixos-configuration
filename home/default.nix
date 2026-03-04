{ config, pkgs, ... }:

{

  imports = [
    <home-manager/nixos>
    ./alacritty.nix
    ./docker.nix
    ./doom-emacs.nix
    ./copilot.nix
    ./ipython.nix
    ./neovim.nix
    ./opencode.nix
    ./tmux.nix
    ./vim.nix
    # ./virtualbox.nix
    ./xsession.nix
    ./zsh.nix
  ];

  services.ollama.enable = true;

  # environment.sessionVariables (pam-environment) are set earlier in the login
  # process than environment.variables which are shell specific.
  environment.sessionVariables = {
    # These are the defaults, and xdg.enable does set them, but due to load
    # order, they're not set before environment.variables are set, which could
    # cause race conditions.
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_BIN_HOME = "$HOME/.local/bin";
  };

  # By default, Home Manager uses a private pkgs instance that is configured via
  # the home-manager.users.<name>.nixpkgs options. To instead use the global pkgs
  # that is configured via the system level nixpkgs options, set

  home-manager.useGlobalPkgs = true;

  # Setting above to `true` saves an extra Nixpkgs evaluation, adds consistency,
  # and removes the dependency on NIX_PATH, which is otherwise used for
  # importing Nixpkgs.

  home-manager.users.${config.customParams.userName} = {
    xdg.enable = true;
    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    home.stateVersion = config.system.stateVersion;
    home.packages =
      with pkgs;
      let
        # azuredatastudio = callPackage ./azuredatastudio.nix { };
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
        unstable.aider-chat-with-playwright
        unstable.claude-code
        unstable.claude-code-acp

        azure-cli # Azure CLI
        awscli2 # AWS CLI
        broot # Directory tree viewer
        chromium # MS Teams works better in chromium
        dbeaver-bin # Database client
        pass # Password store
        spotify
        tex
        tor-browser # Tor browser
        # unstable.code-cursor      # AI powered code editor
        unstable.signal-desktop # Signal messaging app desktop client
      ];
    programs = {
      firefox = {
        enable = true;
        profiles."${config.customParams.userName}.default" = {
          isDefault = true;
          name = "${config.customParams.userName}.default";
          settings = {
            "browser.startup.homepage" = "https://nixos.org";
            "browser.uidensity" = 1;
          };
        };
      };
      # vscode = {
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
      #   };
      #     "chat.customAgentInSubagent.enabled" = "true";
      # };
    };
    # Nixpkgs config file, enables e.g. `allowUnfree` globally
    xdg.configFile."nixpkgs/config.nix" = {
      source = ../config/nixpkgs/config.nix;
    };
  };

}
