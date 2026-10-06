## 1. The check

- [x] 1.1 Add `tests/trusted-users.nix`, a Nix expression whose every attribute
  must be true. Each attribute evaluates this configuration with one extra
  module injected and asks whether the trust assertion is the single failure,
  so a case cannot pass because something else broke. Keep each module to the
  one setting or membership it grants, so a false attribute names the route.
  Resolve the host directory relative to the file so it works in a clone.
  Failure surfaces as a `false` attribute rather than an exit status, since the
  evaluator exits zero either way; the documented invocation greps for it.
  Validation: `cd ~/NixOS && ! (nix-instantiate --eval --strict tests/trusted-users.nix | grep -q false) && echo CHECK-PASSES`

- [x] 1.2 Cover every grant route the assertion reads, as cases that must be
  caught: the user named in `trusted-users`; the user's primary group; a group
  joined through its own `extraGroups`; a group joined from that group's
  `members` list; and the appending setting, both as a list and as a
  whitespace-separated string naming more than one user. The last is the route
  that was open until recently, so it is the regression case this file exists
  for. Derive the user and the primary group from the configuration rather than
  naming them.
  Validation: `cd ~/NixOS && test "$(grep -c 'caught {' tests/trusted-users.nix)" = 6 && echo SIX-ROUTES`

- [x] 1.3 Cover the two controls that must grant nothing: an unrelated trusted
  user, and a group membership whose group is not trusted. Without these the
  file cannot tell the scoped assertion from a blanket one, and would report
  success for a predicate that rejects everything.
  Validation: `cd ~/NixOS && test "$(grep -c 'clean {' tests/trusted-users.nix)" = 2 && echo TWO-CONTROLS`

- [x] 1.4 Verify the check discriminates, by temporarily weakening the
  predicate in `home/agent-jail.nix` -- drop the whitespace splitting -- and
  confirming exactly one attribute turns false, the whitespace-string one, and
  that the documented invocation then exits non-zero. Restore the predicate
  afterwards. A check that has never gone red proves only that it evaluates.
  Do not assert that the module matches `HEAD`: task 2.1 adds a comment to the
  same file, so a clean-diff check can never pass once both are done.
  Validation: `cd ~/NixOS && ! grep -q 'TEMPORARILY WEAKENED' home/agent-jail.nix && grep -q 'builtins.split' home/agent-jail.nix && echo RESTORED`

## 2. Make it findable

- [x] 2.1 Point at the check from where a reader will already be looking: one
  comment in `home/agent-jail.nix` beside the assertion, and one sentence in
  `AGENTS.md` beside the existing guidance about verifying the jail against
  bait, so the two verification stories sit together without being conflated.
  Say what the check does rather than describing its cases -- the file is the
  record -- and do not call it a build failure, since nothing is built.
  Validation: `cd ~/NixOS && grep -q 'tests/trusted-users' home/agent-jail.nix AGENTS.md && nix-instantiate '<nixpkgs/nixos>' -A system -I nixos-config=./hosts/spyridon >/dev/null && echo POINTERS-OK`


## Unreconciled
