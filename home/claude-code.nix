{ config, pkgs, ... }:

let
  agents = [ "spar-and-plan" "build-orchestrator" "coder" "reviewer" ];
in
{
  home-manager.users.${config.customParams.userName} = {
    home.packages = with pkgs; [
      unstable.claude-code
      unstable.claude-agent-acp
    ];
    home.file = builtins.listToAttrs (map (agent: {
      name = ".claude/agents/${agent}.md";
      value.source = ../config/claude-code/agents/${agent}.md;
    }) agents);
  };
}
