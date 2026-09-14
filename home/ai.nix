{ config, pkgs, ... }:

{
  home-manager.users.${config.customParams.userName}.home.packages = with pkgs; [
    unstable.claude-code
    unstable.github-copilot-cli
  ];
}
