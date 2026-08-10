{ config, pkgs, ... }:

let
  # build-orchestrator and coder are retired (see config/copilot/agents/_deprecated/)
  # in favor of the plan-executor skill, which runs implementation directly in
  # the main session instead of relying on delegation that could be silently
  # skipped. reviewer stays a real agent for independent, isolated review.
  agents = [
    "spar-and-plan"
    "reviewer"
  ];

  skills = [
    "plan-executor"
    "grilling"
  ];
in
{
  home-manager.users.${config.customParams.userName} = {
    # GitHub Copilot CLI is installed via npm:
    #   npm install -g @github/copilot
    home.file = builtins.listToAttrs (
      (map (agent: {
        name = ".copilot/agents/${agent}.agent.md";
        value.source = ../config/copilot/agents/${agent}.agent.md;
      }) agents)
      ++ (map (skill: {
        name = ".copilot/skills/${skill}/SKILL.md";
        value.source = ../config/copilot/skills/${skill}/SKILL.md;
      }) skills)
    );
  };
}
