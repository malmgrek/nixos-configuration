{ config, pkgs, ... }:

{
  home-manager.users.${config.customParams.userName}.home.packages = with pkgs; [
    unstable.claude-code
    unstable.github-copilot-cli
    unstable.openspec
    unstable.playwright
    unstable.playwright-driver.browsers
    unstable.playwright-mcp
    unstable.playwright-test
    unstable.rtk
  ];
}
