{ config, pkgs, ... }:

let
  agents = [
    "spar-and-plan"
    "build-orchestrator"
    "coder"
    "reviewer"
  ];
  github-copilot-cli = pkgs.unstable.github-copilot-cli.overrideAttrs (
    finalAttrs: old: {
      version = "1.0.48";
      src = pkgs.fetchurl {
        url = "https://github.com/github/copilot-cli/releases/download/v${finalAttrs.version}/${old.src.name}";
        hash = "sha256-8qEnjDwv4iy8vlHA0u4lH3Yh0uoiEf4cezZoqzs2P/0=";
      };
      # postInstall = ''
      #   # Current postInstall is broken, so we override it with a no-op.
      # '';
    }
  );
in
{
  home-manager.users.${config.customParams.userName} = {
    home.packages = [ github-copilot-cli ];
    home.file = builtins.listToAttrs (
      map (agent: {
        name = ".copilot/agents/${agent}.agent.md";
        value.source = ../config/copilot/agents/${agent}.agent.md;
      }) agents
    );
  };
}
