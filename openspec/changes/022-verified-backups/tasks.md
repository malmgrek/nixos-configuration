# Tasks

## 1. Declaration and one target

- [ ] 1.1 Add a module declaring the protected set as one list of paths plus a
  list of exclusions, and generating one `services.restic.backups` entry per
  declared target from that single list. Start the protected set at the
  operator's secrets only, and declare one target on a local path.
  Validation: `nix-instantiate '<nixpkgs/nixos>' -A system -I nixos-config=./hosts/spyridon`

- [ ] 1.2 Declare the path the repository passphrase is read from, without the
  value, so a machine missing the file produces failing units rather than
  copies nobody can open. The runtime behaviour is asserted by task 3.4; this
  task only places the declaration.
  Validation: `nix-instantiate '<nixpkgs/nixos>' -A system -I nixos-config=./hosts/spyridon`

- [ ] 1.3 Place the mechanism's local cache at an explicitly declared path
  rather than its default under the running user's home, so its growth is a
  stated choice on a filesystem with little room.
  Validation: `nix-instantiate '<nixpkgs/nixos>' -A system -I nixos-config=./hosts/spyridon`

- [ ] 1.4 Declare retention and prune counts as named options with starting
  values, so changing them is an edit to one place rather than to each target.
  Validation: `nix-instantiate '<nixpkgs/nixos>' -A system -I nixos-config=./hosts/spyridon`

- [ ] 1.5 Give each target its own systemd unit with no ordering or requirement
  between targets, so an unreachable target cannot stop the others. The
  multi-target behaviour is asserted by task 3.2.
  Validation: `nix-instantiate '<nixpkgs/nixos>' -A system -I nixos-config=./hosts/spyridon`

## 2. Verification script

- [ ] 2.1 Add a backend-agnostic POSIX shell script taking a repository
  location, a password file and a manifest; it restores to a temporary
  directory and compares file names and checksums against the manifest,
  exiting non-zero on any mismatch. It reads nothing from this repository.
  Give it a `--self-test` mode that builds a throwaway repository and asserts
  both a passing and a deliberately mismatched manifest, so the comparison
  itself is checked rather than assumed.
  Validation: `nix-shell -p restic --run './<script> --self-test'`

- [ ] 2.2 Add the manifest for the secrets-only protected set, with names and
  checksums authored by hand rather than generated from the declaration in
  task 1.1, so a wrong declaration fails the comparison instead of agreeing
  with it.
  Validation: `grep -c . <manifest>`

- [ ] 2.3 Document the cold restore drill beside the script: external media,
  the mechanism's program, the paper passphrase, the manifest, and the script
  invocation. Verify the documented invocation matches the script's actual
  usage string; performing the drill needs external media and the operator, so
  it is listed under Workflow follow-up rather than checked here.
  Validation: `./<script> --help`

## 3. Verification bench

- [ ] 3.1 Add `tests/backups.nix` as a `runNixOSTest` that builds to a
  derivation, with a client node importing the module from task 1.1 and a
  second node serving an `sftp` target. Assert that a snapshot of literal
  fixture files restores byte-for-byte through the script from task 2.1, with
  expectations written in the test rather than read from the module.
  Validation: `nix-build tests/backups.nix --no-out-link`

- [ ] 3.2 Extend the bench to make one target unreachable and assert that the
  failure is reported, that the remaining targets still receive their copies,
  and that a target never reached reads differently from one whose last
  attempt failed.
  Validation: `nix-build tests/backups.nix --no-out-link`

- [ ] 3.3 Extend the bench to restore from a node that imports none of this
  configuration, using only the repository location, the passphrase and the
  mechanism's program.
  Validation: `nix-build tests/backups.nix --no-out-link`

- [ ] 3.4 Extend the bench to assert that a missing passphrase file makes the
  unit fail and report, rather than produce a copy that cannot be opened.
  Validation: `nix-build tests/backups.nix --no-out-link`

- [ ] 3.5 Extend the bench to assert that an empty or wrong protected set fails
  the comparison, so the bench demonstrably catches the declaration error it
  exists to catch.
  Validation: `nix-build tests/backups.nix --no-out-link`

## 4. Freshness and failure reporting

- [ ] 4.1 Add the command that reports, per target, the age of the newest copy,
  distinguishing a target never reached from one whose last attempt failed.
  Validation: `./<command> --repository /nonexistent | grep -qi never`

- [ ] 4.2 Add the block to `config/i3status-rs/config.toml` that runs the
  command from task 4.1. Seeing it on the bar needs a display and a restarted
  status daemon, so that part cannot stand alone; this task checks the block is
  present and the command it names exists.
  Validation: `grep -A3 backup config/i3status-rs/config.toml`

- [ ] 4.3 Add the `OnFailure` unit that raises a desktop notification when a
  target's copy fails. Observing the notification needs a running session, so
  the unit's wiring is what is checked here and its firing is asserted by task
  3.2.
  Validation: `nix-instantiate '<nixpkgs/nixos>' -A system -I nixos-config=./hosts/spyridon`

## 5. Integration

- [ ] 5.1 Add the offsite target to the declaration, with its credentials read
  from a declared file this repository does not contain, and confirm no edit to
  the protected set was needed to add it.
  Validation: `nix-instantiate '<nixpkgs/nixos>' -A system -I nixos-config=./hosts/spyridon`

- [ ] 5.2 Confirm the whole change builds and the bench still passes with both
  targets declared.
  Validation: `nixos-rebuild build && nix-build tests/backups.nix --no-out-link`

## Workflow follow-up

- Generate the repository passphrase, place the password file by hand, and
  write the paper copy for storage at a second address. Operator action on a
  secret; no task can do it and no check can confirm the paper exists.
- Seed the first real copy to removable media, then copy that repository to the
  offsite target rather than uploading the protected set from scratch.
- Perform the cold restore drill from external media against the real
  repository, using only the paper passphrase and the script. Until this
  succeeds, the capability's last requirement means nothing here is believed to
  be protected.
- Grow the protected set beyond secrets only after that drill has succeeded.
- Archive the change after the project's review requirements are satisfied.

## Unreconciled
