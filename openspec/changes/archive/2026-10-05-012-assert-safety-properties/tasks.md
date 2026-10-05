## 1. Assert the jail's trust premise

- [x] 1.1 Declare `nix.settings.trusted-users` in `home/agent-jail.nix`, beside
  the daemon-socket bind it protects, with a comment naming what depends on it:
  the jail binds that socket, and a trusted caller can make the root daemon act
  on its behalf, which Nix documents as root-equivalent. Keep the
  value at the safe default rather than widening it.
  Validation: `cd ~/NixOS && grep -n 'trusted-users' home/agent-jail.nix && nix-instantiate '<nixpkgs/nixos>' -A system -I nixos-config=./hosts/spyridon >/dev/null && echo DECLARED`

- [x] 1.2 Add an `assertions` entry in the same module that fails when the
  jailed user becomes trusted -- named directly, through any group it belongs
  to by either route, or through a setting that appends to the trusted set
  instead of replacing it. This is the part with teeth: `trusted-users` is a
  list option, so the declaration in 1.1 would otherwise merge silently with a
  later `@wheel` and guard nothing. Write the message so it names every cause
  it fires for and states the consequence, not just the rule -- whoever trips
  it is trying to make a flake or substituter work, and will delete a rule
  that only says no.
  Validation: `cd ~/NixOS && nix-instantiate '<nixpkgs/nixos>' -A system -I nixos-config=./hosts/spyridon >/dev/null && echo EVAL-OK`

- [x] 1.3 Prove the assertion fires. An assertion that has never failed is a
  belief, not a check. Inject the grant as an extra module at evaluation time
  rather than editing a scratch copy: that reproduces the two-file merge which
  is the actual threat, and leaves nothing in the tree to revert. Cover every
  route this configuration can express, and both negative controls:
  - the user named directly;
  - a group the user joins via its own `extraGroups`;
  - a group joined from that group's `members` list, which this configuration
    does use;
  - a group named only in `extraGroups` with no matching `users.groups`
    declaration, which nothing requires to exist -- the case that distinguishes
    reading both membership routes from reading only one;
  - a setting that appends to the trusted set, as a list, as a single-name
    string, and as a whitespace-separated string naming several users, since
    the values are compared as words rather than as elements;
  - an unrelated trusted user, which must still evaluate;
  - a group membership whose group is not trusted, which must also still
    evaluate -- otherwise the assertion is a blanket rule wearing a scope.
  Validation: `cd ~/NixOS && nix-instantiate '<nixpkgs/nixos>' -A system -I nixos-config=./hosts/spyridon >/dev/null && echo REVERTED-AND-EVALUATES`

## 2. Stop rendering the SSID

- [x] 2.1 Move the SSID behind a click in `config/i3status-rs/config.toml`
  rather than removing it: keep it out of the net block's `format` and put it
  in `format_alt`, which the block toggles on every left click. Keep signal
  strength, frequency and the wired-connection fallback in both. A screenshot
  of the bar at rest cannot carry the field, and a freshly started bar is
  always in that state, so the safe form is the default rather than something
  to remember. The toggle is sticky until clicked again, so revealing and
  forgetting leaves it visible -- the README reminder covers that.
  Validation: `cd ~/NixOS && grep -q '^format = .*{\$signal_strength \$frequency' config/i3status-rs/config.toml && grep -q '^format_alt = .*\$ssid' config/i3status-rs/config.toml && echo SSID-BEHIND-CLICK`

- [x] 2.2 Soften the `README.md` screenshot TODO now that the specific field is
  gone: it should still say to look at the bar before committing an image, but
  it is no longer the only control and should not imply it is.
  Validation: none

## 3. Housekeeping

- [x] 3.1 Remove the template scaffolding from `openspec/config.yaml`: the
  "copy to" header and the "lines marked PROJECT" line, which describe a
  template rather than this project. Fill the two unfilled `PROJECT` prompts in
  the `design` and `tasks` rules with this project's answers -- evaluating the
  system derivation is the check that catches a structural mistake, and
  `nixos-rebuild build` catches one that appears only when something is built.
  Leave every invariant block as it is.
  Validation: `cd ~/NixOS && ! grep -n 'PROJECT:\|Template: copy to' openspec/config.yaml && openspec validate 012-assert-safety-properties >/dev/null && echo CONFIG-CLEAN`

- [x] 3.2 Remove `AGENTS.md`'s opening "append into the project's AGENTS.md"
  comment, which instructs a reader to do what has already been done, and drop
  the empty row from the path-exceptions table so the table reads as
  deliberately empty rather than unfilled. Keep the sentence that says an empty
  table means the project directory is the whole world.
  Validation: `cd ~/NixOS && ! grep -n 'Append into the' AGENTS.md && echo AGENTS-CLEAN`

- [x] 3.3 Delete the stale `010-publishable-history` branch, whose change is
  archived and whose tip is behind `master`. Confirm first that it carries
  nothing `master` lacks, so the deletion discards a ref and not work.
  Validation: `cd ~/NixOS && test -z "$(git branch --list 010-publishable-history)" && echo BRANCH-GONE`

## Unreconciled
