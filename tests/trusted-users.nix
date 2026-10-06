# Checks the trusted-user assertion in home/agent-jail.nix.
#
# The jail binds the Nix daemon socket, which is only safe while the jailed
# user is not a trusted user of the daemon. An assertion enforces that. Each
# case below evaluates the real configuration with one extra module granting
# the trust by one route, and asks whether that assertion is the one and only
# failure. The two controls at the end must grant nothing, so a predicate that
# rejected everything would not read as correct.
#
#   ! (nix-instantiate --eval --strict tests/trusted-users.nix | grep -q false)
#
# Every attribute must be true. Pure evaluation: nothing is written to the
# store.
let
  host = ../hosts/spyridon;

  config = module: (import <nixpkgs/nixos> {
    configuration = { imports = [ host module ]; };
  }).config;

  failing = module:
    builtins.filter (a: !a.assertion) (config module).assertions;

  # The trust was caught: exactly one assertion fails, and it is ours.
  caught = module:
    let f = failing module; in
    builtins.length f == 1
    && builtins.match ".*is a trusted user of the Nix daemon.*"
         (builtins.replaceStrings [ "\n" ] [ " " ] (builtins.head f).message)
       != null;

  # Nothing was granted.
  clean = module: failing module == [ ];

  userName = (config { }).customParams.userName;
  primaryGroup = (config { }).users.users.${userName}.group;
in
{
  namedDirectly = caught { nix.settings.trusted-users = [ userName ]; };
  primaryGroupTrusted = caught {
    nix.settings.trusted-users = [ "@${primaryGroup}" ];
  };
  viaExtraGroups = caught {
    users.users.${userName}.extraGroups = [ "nixtrusted" ];
    nix.settings.trusted-users = [ "@nixtrusted" ];
  };
  viaGroupMembers = caught {
    users.groups.nixtrusted.members = [ userName ];
    nix.settings.trusted-users = [ "@nixtrusted" ];
  };
  appendingList = caught { nix.settings.extra-trusted-users = [ userName ]; };
  appendingWhitespaceString = caught {
    nix.settings.extra-trusted-users = "alice ${userName}";
  };

  # Controls: these must change nothing.
  unrelatedTrustedUser = clean {
    nix.settings.trusted-users = [ "remote-builder" ];
  };
  untrustedGroupMembership = clean {
    users.groups.nixtrusted.members = [ userName ];
  };
}
