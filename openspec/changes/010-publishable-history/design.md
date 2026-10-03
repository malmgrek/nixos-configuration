## Decisions at a glance

1. Rewrite history with `git-filter-repo`; a `git rm` would leave all 20 plan
   commits intact and the next push would publish them.
2. Verify the "nothing pushed" precondition offline, against the existing
   tracking ref, and abort if it fails.
3. Scope the rewrite to `plans/` and nothing else.
4. Delete the plans rather than preserve them in a second repository.
5. Salvage two of them first: one as a baseline spec, one as a pending change.
6. No leak-detection gate. The denylist would have to contain the secrets.
7. Keep `plans/` in `.gitignore` even though the directory is gone.
8. Remove `config/ai/` outright; it is already orphaned.

## Context

`origin/master` is a January 2025 commit; everything since is local. The full
jail boundary is already public in `home/agent-jail.nix` -- every bind, the
tmpfs over `$HOME`, the refusal to bind the Docker socket. `openspec/specs/` is
empty, so the project currently promises nothing in writing. See
`proposal.md` for why this change exists.

## Goals / Non-Goals

**Goals:** a `master` that can be pushed as an ordinary fast-forward; the
reasoning worth keeping moved into OpenSpec before its source is destroyed;
the publication rule written down where the next session will read it.

**Non-Goals:** pushing, which stays a separate decision taken after this
change; and anything already public, which this change cannot reach.

## Decisions

**`git-filter-repo`, not `git rm` or `filter-branch`.** The content, not the
tip, is what must not reach the remote. `filter-branch` is deprecated, far
slower, and easy to get subtly wrong.

**Verify the precondition offline.** No commit touching `plans/` may be an
ancestor of `origin/master`; if one is, this stops being a local correction
and becomes a force-push against a public repository, which is a different
decision. The check is a `merge-base --is-ancestor` loop against the existing
tracking ref: the remote has not moved since January 2025 and this is the only
developer, so a fetch adds nothing and would make the check depend on working
network credentials. Abort on any hit rather than widening scope.

**Scope the rewrite to `plans/`.** `resources/screenshot.png` is the other
privacy defect in this repository's history, and it is tempting to strip it in
the same pass. It must not be: that history *is* pushed, so rewriting it
converts a fast-forward into a force-push. It has also been served publicly
since 2022 and is beyond recall. The SSID it exposes is fixed by renaming the
network, not by git.

**Delete the plans; do not keep them.** They were written as one-time working
documents for a workflow that OpenSpec now replaces. A nested second
repository would leave a discontinued artifact needing its own backup regime,
to preserve documents nothing will read again.

**Salvage exactly two, before deleting anything.** The applied agent-jail
design is the argument for why three FHS root binds are not holes in a
default-deny home directory; deleted, a reader meets `--ro-bind /bin /bin`
with no justification and no baseline to compare a future change against.
The jailed-containers design is unapplied but carries measured facts that cost
real experiments -- notably that a bind mount to a path the daemon cannot
resolve silently mounts an empty directory. Both are free of client names
already. Everything else goes.

**The agent-jail spec is a baseline import, not a delta.** The jail already
ships; writing it as a change delta would claim this change adds those
requirements. So it is written straight into `openspec/specs/` and this change
sets `skip_specs: true`.

**No leak-detection gate.** A pre-push denylist would have to contain the
client name, the client project name, a surname and the SSID -- three of which
are exactly the secrets. Tracked, the gate publishes what it guards; untracked,
it dies with the clone and fails open, which is worse than nothing because it
looks like a control. What replaces it: the hard constraint in
`openspec/config.yaml`, which is agent-facing and costs nothing, and one read
of `git log -p origin/master..master` before the first push. Pushes here are
roughly annual and there is one developer.

**Keep `plans/` in `.gitignore`.** The directory is being deleted, but
`config/opencode/agents/spar-and-plan.md` and `build-orchestrator.md` stay
installed, and either can still write a `plans/NNN/` folder into whichever
repository it runs in. Two lines with the reason attached are cheaper than
discovering a plan folder in a published commit.

**Remove `config/ai/` outright.** `home/ai.nix` installs packages and two
Playwright variables and references the directory nowhere; its own README says
nothing in it is loaded automatically. It is a copy-library whose equivalents
are now tracked elsewhere, so deletion changes no behaviour. `README.md:48`
links to it and goes with it.

## Risks / Trade-offs

- Commits that touched only `plans/` become empty and are dropped, so the
  history gets shorter and some commit messages disappear. Expected and
  harmless for a configuration repository.
- The `feature/001-*`, `backup/001-*` and `x11-cleanup` branches are rewritten
  along with `master`; `x11-cleanup` is the only ref carrying the tenth plan
  folder. Any other clone diverges and must be re-cloned.
- Salvage happens in Tasks 2.1-2.2 and destruction in Task 3.1 onward. If the
  order is broken the source is gone -- mitigated by the Task 1.1 backup, which
  zips the working tree including `.git` and the untracked plan folders, and is
  retained until the result has been used for real work.
- That backup lives inside the directory it backs up, because the agent making
  it cannot write outside this repository. It covers every failure in this
  change -- a bad rewrite, a premature deletion -- but not the loss of the
  directory itself. Copying the zip to another disk is a manual step and is not
  a task here.
- `filter-repo --force` is irreversible and runs against a repository that is
  not a fresh clone. The backup is what makes overriding that safety check
  reasonable, so Task 05 must not run if Task 01 was skipped.
- Dropping the gate means the publication rule is enforced by a constraint an
  agent reads and a diff a human reads. Both can be skipped. Accepted: the
  alternative cannot be both complete and public.
- `config/ai/` removal also drops four things unrelated to planning
  (`doc-audit`, `grilling`, a reviewer agent, the `rtk` hook and instructions)
  plus two copilot JSON configs. Confirmed as archived elsewhere; the copilot
  plumbing is the part worth a glance before the deletion commit.

## Migration Plan

Rollback restores `backups/nixos-backup-<date>.zip`: move the zip aside, clear
the working tree, and unzip it in place. Nothing needs undoing on the remote,
because nothing is pushed at any point in this change.
`git-filter-repo` removes `origin` deliberately, to prevent an accidental push
of rewritten history; re-adding it is a conscious step after the result has
been inspected, not a repair.
