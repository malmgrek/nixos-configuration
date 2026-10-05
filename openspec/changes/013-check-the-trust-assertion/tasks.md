## 1. The check

- [ ] 1.1 Add `tests/trusted-users.sh`, which evaluates this configuration once
  per case with an extra module injected, and compares the evaluation's exit
  status against the expected one. Take the host directory as the only input so
  the script works in a clone, and make it report every case and exit non-zero
  if any disagrees -- a check that stops at the first failure hides how many
  routes are open. Keep each case's module to the one setting or membership it
  is granting, so a failure names the route rather than a combination.
  Validation: `cd ~/NixOS && ./tests/trusted-users.sh && echo CHECK-PASSES`

- [ ] 1.2 Cover the four grant routes as failing cases: the user named in
  `trusted-users`; a group the user joins through its own `extraGroups`; a group
  joined from that group's `members` list; and the appending setting, both as a
  list and as a whitespace-separated string naming more than one user. The last
  is the route that was open until recently, so it is the regression case this
  script exists for.
  Validation: `cd ~/NixOS && ./tests/trusted-users.sh | grep -c FAIL-EXPECTED`

- [ ] 1.3 Cover the two passing cases: an unrelated trusted user, and a group
  membership whose group is not trusted. Without these the script cannot tell
  the scoped assertion from a blanket one, and would report success for a
  predicate that rejects everything.
  Validation: `cd ~/NixOS && ./tests/trusted-users.sh | grep -c PASS-EXPECTED`

- [ ] 1.4 Verify the script actually discriminates, by temporarily weakening the
  predicate in `home/agent-jail.nix` -- drop the whitespace splitting -- and
  confirming the script reports exactly the string case as failed and the rest
  as passed. Restore the predicate afterwards. A check that has never gone red
  proves only that it runs.
  Validation: `cd ~/NixOS && git diff --quiet home/agent-jail.nix && ./tests/trusted-users.sh && echo RESTORED-AND-PASSES`

## 2. Make it findable

- [ ] 2.1 Point at the script from where a reader will already be looking: one
  line in `home/agent-jail.nix` beside the assertion saying what checks it, and
  one line in `AGENTS.md` beside the existing guidance about verifying the jail
  against bait, so the two verification stories sit together. Do not describe
  the cases in either place -- the script is the record.
  Validation: `cd ~/NixOS && grep -q 'tests/trusted-users' home/agent-jail.nix AGENTS.md && nix-instantiate '<nixpkgs/nixos>' -A system -I nixos-config=./hosts/spyridon >/dev/null && echo POINTERS-OK`

## Unreconciled
