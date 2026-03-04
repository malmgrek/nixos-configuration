{ config, pkgs, ... }:

{
  home-manager.users.${config.customParams.userName} = {
    home.packages = with pkgs; [
      unstable.opencode
    ];
    # OpenCode Configuration Management
    #
    # OpenCode uses multiple JSON files for configuration and state:
    #
    # Static Configuration (managed by Nix):
    #   ~/.config/opencode/opencode.json - Base config (theme, default model)
    #     → Read-only symlink to Nix store
    #     → Takes precedence over runtime state files
    #
    # Runtime State (writable, enables GUI changes):
    #   ~/.local/state/opencode/model.json - Recent/favorite models
    #   ~/.local/state/opencode/kv.json - Theme and other preferences
    #   ~/.local/state/opencode/prompt-history.jsonl - Conversation history
    #
    # Configuration Priority:
    #   opencode.json (Nix config) > kv.json/model.json (runtime state)
    #
    # Strategy:
    #   1. Manage opencode.json declaratively (read-only Nix symlink)
    #   2. Reset configuration state files (model.json, kv.json) on rebuild
    #   3. Preserve user data (prompt-history.jsonl)
    #   4. Allow runtime changes via GUI during sessions
    #   5. Enforce Nix-configured defaults after each rebuild
    #
    # This approach balances declarative infrastructure with runtime flexibility:
    # - You can change models/themes in GUI during a session
    # - Changes take effect immediately (state files are writable)
    # - After nixos-rebuild, settings revert to your Nix configuration
    # - Conversation history persists across rebuilds
    xdg.configFile."opencode/agents/build-orchestrator.md" = {
      source = ../config/opencode/agents/build-orchestrator.md;
    };
    xdg.configFile."opencode/agents/coder.md" = {
      source = ../config/opencode/agents/coder.md;
    };
    xdg.configFile."opencode/agents/reviewer.md" = {
      source = ../config/opencode/agents/reviewer.md;
    };
    xdg.configFile."opencode/agents/spar-and-plan.md" = {
      source = ../config/opencode/agents/spar-and-plan.md;
    };
    xdg.configFile."opencode/opencode.jsonc" = {
      source = ../config/opencode/opencode.jsonc;
    };
    # Reset configuration state on activation
    # This enforces Nix-configured defaults while preserving user data
    home.activation.resetOpenCodeState = ''
      $DRY_RUN_CMD rm -f $HOME/.local/state/opencode/model.json
      $DRY_RUN_CMD rm -f $HOME/.local/state/opencode/kv.json

      # Preserve user data (conversation history is intentionally kept)
      # $HOME/.local/state/opencode/prompt-history.jsonl
    '';
  };
}
