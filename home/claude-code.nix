{ config, pkgs, ... }:

let
  agents = [ "spar-and-plan" "build-orchestrator" "coder" "reviewer" ];
in
{
  home-manager.users.${config.customParams.userName} = {
    # GitHub Copilot CLI is installed via npm:
    #   npm install -g @anthropic-ai/claude-code
    home.file = builtins.listToAttrs (map (agent: {
      name = ".claude/agents/${agent}.md";
      value.source = ../config/claude-code/agents/${agent}.md;
    }) agents);
  };
}
