{ config, pkgs, ... }:

let

  userName = config.customParams.userName;

in

{

  home-manager.users.${userName} = {

    home.packages = with pkgs; [
      unstable.claude-code
      unstable.github-copilot-cli
      unstable.openspec
      unstable.playwright-mcp
      unstable.playwright-test
      unstable.rtk
    ];

    # The MCP server defaults to Playwright's `chrome` channel, which is probed
    # at /opt/google/chrome/chrome rather than on $PATH and so never resolves on
    # NixOS; naming an executable skips that lookup. Headless because a jailed
    # agent has no X server. Not PLAYWRIGHT_BROWSERS_PATH: the `playwright` CLI
    # wrapper supplies its own matching default, which exporting would override.
    home.sessionVariables = {
      PLAYWRIGHT_MCP_EXECUTABLE_PATH = "${pkgs.chromium}/bin/chromium";
      PLAYWRIGHT_MCP_HEADLESS = "true";
    };

  };

}
