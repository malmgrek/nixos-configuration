{ config, pkgs, ... }:

let
  agents = [ "spar-and-plan" "build-orchestrator" "coder" "reviewer" ];
in
{
  home-manager.users.${config.customParams.userName} = {
    home.packages = with pkgs; [
      unstable.github-copilot-cli
    ];
    xdg.configFile = builtins.listToAttrs (map (agent: {
      name = ".copilot/agents/${agent}.agent.md";
      value.source = ../config/copilot/agents/${agent}.agent.md;
    }) agents);
  };
}
