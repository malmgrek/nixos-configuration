{ config, pkgs, ... }:

let
  # build-orchestrator and coder are retired (see config/claude-code/agents/_deprecated/)
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
    # Claude Code CLI is installed via npm:
    #   npm install -g @anthropic-ai/claude-code
    home.file = builtins.listToAttrs (
      (map (agent: {
        name = ".claude/agents/${agent}.md";
        value.source = ../config/claude-code/agents/${agent}.md;
      }) agents)
      ++ (map (skill: {
        name = ".claude/skills/${skill}/SKILL.md";
        value.source = ../config/claude-code/skills/${skill}/SKILL.md;
      }) skills)
    );
  };
}
