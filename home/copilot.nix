{ config, pkgs, ... }:

let
  agents = [
    "spar-and-plan"
    "build-orchestrator"
    "coder"
    "reviewer"
  ];
in
{
  home-manager.users.${config.customParams.userName} = {
    # GitHub Copilot CLI is installed via npm:
    #   npm install -g @github/copilot
    home.file = builtins.listToAttrs (
      map (agent: {
        name = ".copilot/agents/${agent}.agent.md";
        value.source = ../config/copilot/agents/${agent}.agent.md;
      }) agents
    );
  };
}
