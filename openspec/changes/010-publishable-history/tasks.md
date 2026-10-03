## 1. Precondition and backup

- [x] 1.1 Record the pre-migration state, then back up into this repository.
  Record `git rev-parse origin/master` (currently `321a591`),
  `git ls-files | wc -l`, and `git log --all --oneline -- plans/ | wc -l`; later
  tasks compare against these. Confirm offline that no commit touching `plans/`
  is an ancestor of `origin/master` -- any hit means the rewrite would become a
  force-push against a public repository, so stop and report instead of
  continuing. Then add `backups/` to `.gitignore` *before* creating the
  directory, so it never shows as untracked and never makes the tree dirty for
  Task 4.1; Task 3.1's commit sweeps that line up. Zip the whole working tree,
  including `.git` and the untracked plan folders and excluding `backups/`
  itself, to `backups/nixos-backup-$(date +%F).zip`. Keep it until the result
  has been used for real work.
  The two recorded lines above the loop are part of the check rather than
  decoration. The loop prints nothing both when no plan commit is an ancestor
  of `origin/master` and when `origin/master` does not resolve or the commit
  list is empty, so it is the recorded `origin/master` SHA and the recorded
  plan-commit count that rule out a vacuous pass. Record them first, and read
  them.
  Validation: `cd ~/NixOS && for c in $(git log --format=%H --all -- plans/); do git merge-base --is-ancestor "$c" origin/master 2>/dev/null && echo PUSHED; done; unzip -l backups/nixos-backup-$(date +%F).zip | grep -q '\.git/config' && test -z "$(git status --short | grep backups)" && echo BACKUP-OK`

## 2. Salvage, while the plans still exist

- [x] 2.1 Write `openspec/specs/agent-jail/spec.md` as a baseline entry from
  `plans/006-agent-jail/` and `plans/009-jail-foreign-toolchains/`: the
  requirements the jail already satisfies, including why the three FHS root
  binds and the uv interpreter bind are not holes in the default-deny home
  directory, and why the Nix daemon socket is bound while the Docker socket is
  not. Do not describe the unapplied jailed-containers work. Plan 009 names a
  client project in two places; read the finished spec and confirm no client
  or project name survived -- this is a published file.
  Validation: `cd ~/NixOS && openspec show agent-jail --type spec >/dev/null && echo SPEC-OK`

- [x] 2.2 Scaffold `011-jailed-containers` with `openspec new change` and
  transform `plans/007-jailed-containers/` into its `proposal.md` and
  `design.md`. Carry the four measured facts and the two rejected alternatives;
  the fact that an unresolvable bind mount silently mounts an empty directory
  is the one the design depends on. Declare the capabilities it would add, and
  leave its specs and tasks for whenever the change is taken up. The source
  plan is free of client names, so this is a transformation, not a scrub.
  Validation: `cd ~/NixOS && openspec status --change 011-jailed-containers --json | grep -c '"status": "done"'`

## 3. Deletions

- [ ] 3.1 Remove the three newest plan folders and commit everything else, so
  `filter-repo` has the clean tree it requires. `plans/007-*`, `plans/008-*`
  and `plans/009-*` are **staged**, not untracked, so clearing them needs
  `git rm -r --cached` as well as `rm -rf`: a bare `rm -rf` leaves index
  entries that this task's commit would then record as deletions of files that
  were never committed. They appear in no commit, so Task 4.1 will not reach
  them. Plans `001`-`006` are committed and need no `git rm` -- Task 4.1
  removes those from history and from the resulting tree in one pass. Commit
  all the rest: the staged openspec and `.claude` scaffolding, this change's
  own artifacts, Task 1.1's `backups/` ignore line, and the four files section
  2 produced (`openspec/specs/agent-jail/spec.md` and the three under
  `openspec/changes/011-jailed-containers/`).
  Validation: `cd ~/NixOS && test -z "$(git status --short)" && test ! -e plans/009-jail-foreign-toolchains && echo CLEAN`

- [ ] 3.2 Remove `config/ai/` with `git rm -r` and the `README.md` paragraph
  that links to it, then commit. Nothing in `home/` references the directory,
  so this changes no behaviour -- but check the copilot `lsp-config.json`,
  `mcp-config.json` and the `rtk` hook and instructions before committing, as
  those are machine plumbing rather than agent prose.
  Validation: `cd ~/NixOS && ! grep -rn 'config/ai' README.md && nix-instantiate '<nixpkgs/nixos>' -A system -I nixos-config=/etc/nixos/configuration.nix >/dev/null && echo EVAL-OK`

## 4. History rewrite

- [ ] 4.1 Run `nix-shell -p git-filter-repo --run 'git filter-repo --path plans/ --invert-paths --force'`,
  then re-add `origin` at `git@github.com:malmgrek/nixos-configuration.git`.
  `--path plans/` and nothing else: `resources/screenshot.png` lives in pushed
  history and rewriting it would turn a fast-forward into a force-push.
  `--force` is required because this is not a fresh clone, and Task 1.1's
  backup is what makes overriding that check reasonable -- do not run this if
  that task was skipped. `filter-repo` removes the remote on purpose; its
  absence afterwards is expected, not a failure. It may also drop
  `refs/remotes/origin/*`, so verify the fast-forward property against the SHA
  recorded in Task 1.1 rather than against `origin/master`.
  Validation: `cd ~/NixOS && test "$(git log --all --oneline -- plans/ | wc -l)" = 0 && test "$(git ls-files | grep -c '^plans/')" = 0 && git merge-base --is-ancestor 321a591 master && test -f backups/nixos-backup-$(date +%F).zip && echo FF-OK`

## 5. Durable controls and verification

- [ ] 5.1 Add `plans/` to `.gitignore` with a comment stating that an
  installed opencode agent can still produce such a folder and that it must
  never enter a published history, and replace the unfilled placeholder on
  `openspec/config.yaml:19` with this project's hard constraint: artifacts here
  are published, so none may name a client, a personal identifier, or a
  weakness that is known and not yet fixed; detail of that kind belongs
  outside this repository.
  Validation: `cd ~/NixOS && grep -q '^plans/$' .gitignore && ! grep -q 'the hard constraint that overrides' openspec/config.yaml && echo CONTROLS-OK`

- [ ] 5.2 Verify the whole change end to end, across every ref rather than the
  current tree: no `plans/` path and no plan content on any ref; the tracked
  file count down from the 135 Task 1.1 recorded to 78, being 135 less the 45
  files under `plans/` and the 16 under `config/ai/`, plus the four that
  section 2 adds back (the `agent-jail` spec and three artifacts of `011`);
  the system derivation still evaluating; `plans/` absent from `git status`
  entirely rather than listed as untracked; and nothing pushed. Then read the
  two salvaged artifacts once more against the constraint written in Task 5.1.
  Validation: `cd ~/NixOS && test "$(git log --all -p -- plans/ | wc -l)" = 0 && test -z "$(git status --short | grep plans)" && nix-instantiate '<nixpkgs/nixos>' -A system -I nixos-config=/etc/nixos/configuration.nix >/dev/null && echo VERIFIED`

## Unreconciled
