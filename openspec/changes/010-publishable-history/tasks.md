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
  Validation: `cd ~/NixOS && for c in $(git log --format=%H --all -- plans/); do git merge-base --is-ancestor "$c" origin/master 2>/dev/null && echo PUSHED; done; unzip -l backups/nixos-backup-*.zip | grep -q '\.git/config' && test -z "$(git status --short | grep backups)" && echo BACKUP-OK`

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

- [x] 3.1 Remove the three newest plan folders and commit everything else, so
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
  Do not assert a clean tree here: ticking this task's own checkbox dirties it.
  The clean tree is Task 4.1's precondition and is checked there.
  Validation: `cd ~/NixOS && test ! -e plans/009-jail-foreign-toolchains && test -z "$(git ls-files 'plans/00[789]*')" && git cat-file -e HEAD:openspec/specs/agent-jail/spec.md && git cat-file -e HEAD:openspec/changes/011-jailed-containers/design.md && echo DELETED-AND-SALVAGED`

- [x] 3.2 Remove `config/ai/` with `git rm -r` and the `README.md` paragraph
  that links to it, then commit. Nothing in `home/` references the directory,
  so this changes no behaviour -- but check the copilot `lsp-config.json`,
  `mcp-config.json` and the `rtk` hook and instructions before committing, as
  those are machine plumbing rather than agent prose.
  Validation: `cd ~/NixOS && ! grep -rn 'config/ai' README.md && nix-instantiate '<nixpkgs/nixos>' -A system -I nixos-config=/etc/nixos/configuration.nix >/dev/null && echo EVAL-OK`

## 4. History rewrite

- [x] 4.1 Commit any outstanding artifact edits, then run
  `nix-shell -p git-filter-repo --run 'git filter-repo --path plans/ --invert-paths --force'`,
  then re-add `origin` at `git@github.com:malmgrek/nixos-configuration.git`.
  `--path plans/` and nothing else: `resources/screenshot.png` lives in pushed
  history and rewriting it would turn a fast-forward into a force-push.
  `--force` is required because this is not a fresh clone, and Task 1.1's
  backup is what makes overriding that check reasonable -- do not run this if
  that task was skipped. `filter-repo` removes the remote on purpose; its
  absence afterwards is expected, not a failure. It may also drop
  `refs/remotes/origin/*`, so verify the fast-forward property against the SHA
  recorded in Task 1.1 rather than against `origin/master`.
  The run ends with a hard reset and a `gc`. Neither should touch an ignored
  path, so confirm the backup zip survived rather than assuming it -- and note
  that the same reset is why the tree must be committed first: `--force`
  proceeds on a dirty tree and the reset then discards whatever was
  uncommitted, checkbox edits included. The rewrite also removes a tenth plan
  folder that exists in history but in no index.
  Once this has run, do not run it again. `.git/filter-repo/already_ran`
  records that it did, but `--force` bypasses that check, so a second run
  would rewrite an already-rewritten repository.
  Validation: `cd ~/NixOS && test "$(git log --all --oneline -- plans/ | wc -l)" = 0 && test "$(git ls-files | grep -c '^plans/')" = 0 && git merge-base --is-ancestor 321a591 master && test -n "$(ls backups/nixos-backup-*.zip 2>/dev/null)" && echo FF-OK`

## 5. Durable controls and verification

- [x] 5.1 Add `plans/` to `.gitignore` with a comment stating that an
  installed opencode agent can still produce such a folder and that it must
  never enter a published history, then write the project's hard constraint
  over the unfilled placeholder in `openspec/config.yaml`. Keep that constraint
  to disclosure: no client, no client project, no personal name, address or
  network identifier, and a limitation stated only with the reason it is
  accepted, a merely-unfixed gap named rather than described. Name the
  identifiers meant and exclude the operator's username, which a NixOS
  configuration must declare, or the rule reads as forbidding this
  repository's own remote URL. Give the gap clause a reachable fallback -- stop and ask --
  since no path outside this repository is writable. Do not let it also rule on
  whether a gap is acceptable -- that is posture, not publication, and a
  publication rule phrased as "already public, therefore fine" ratchets the
  accepted security level downward. Put the posture rule in `AGENTS.md`
  instead: a known gap is a thing to fix, never a baseline to design against.
  Validation: `cd ~/NixOS && grep -q '^plans/$' .gitignore && ! grep -q 'the hard constraint that overrides' openspec/config.yaml && echo CONTROLS-OK`

- [x] 5.2 Verify the whole change end to end, across every ref rather than the
  current tree: no `plans/` path and no plan content on any ref; the tracked
  file count down from the 135 Task 1.1 recorded to 78, being 135 less the 45
  files under `plans/` and the 16 under `config/ai/`, plus the four that
  section 2 adds back (the `agent-jail` spec and three artifacts of `011`);
  the system derivation still evaluating; `plans/` absent from `git status`
  entirely rather than listed as untracked; and nothing pushed. Then read the
  two salvaged artifacts once more against the constraint written in Task 5.1.
  Validation: `cd ~/NixOS && test "$(git log --all -p -- plans/ | wc -l)" = 0 && test -z "$(git status --short | grep plans)" && nix-instantiate '<nixpkgs/nixos>' -A system -I nixos-config=/etc/nixos/configuration.nix >/dev/null && echo VERIFIED`

## Unreconciled

- Two artifact edits were made during section 4 that no task asked for, both
  aligning the plan with what the rewrite actually did: `design.md`'s pre-push
  control was respelled `git log -p 321a591..master`, since `filter-repo` drops
  `refs/remotes/*` and the `origin/master..master` form needs a working fetch;
  and Task 4.1 gained a guard against being run twice, because
  `.git/filter-repo/already_ran` is bypassed by `--force`. Visual only.
- `master` was fast-forwarded to the `010-publishable-history` branch before
  Task 4.1 ran. The work had been committed on that branch while `master` sat
  four commits behind, and the change's goal is a publishable `master`. Not
  required by 4.1's validation, which would have passed either way. Visual only.
- `README.md`: made the retained AI-tools sentence accurate. It named two of the
  six packages `home/ai.nix` installs, and its "vanilla" contrasted with the
  `config/ai/` sentence Task 3.2 removed. Visual only.
