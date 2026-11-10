# Proposal

## Why

This configuration reproduces the system but not the data: `dotfiles` leaves
state and data directories outside its reach, and nothing else claims them. The
machine holds the only copy of its irreplaceable files, and the disk work this
machine needs puts that copy at risk first.

## What Changes

- A `backups` capability: one declared set of paths, replicated to every
  configured target.
- Targets as a set, identified by repository URL, so a local directory, an SSH
  host and rented object storage are one mechanism.
- `restic` via `services.restic.backups`; the passphrase comes from a root-only
  file this repository names but never contains.
- Per-target freshness on the status bar, because a backup that stops reports
  nothing.
- A `runNixOSTest` bench driving real units but asserting against hand-written
  fixtures, and one backend-agnostic verification script shared by the bench and
  a cold restore from external media.

## Capabilities

### New Capabilities

- `backups`: which data is protected, where copies go, and what must be
  demonstrated before the protection is believed.

### Modified Capabilities

None. `dotfiles` already names data directories as beyond its reach and accepts
that boundary; this change does not move it.

## Impact

A new module, the first `tests/` entry that boots a machine, a block in
`config/i3status-rs/config.toml`, and `restic` as a dependency.

Out of scope, with reasons: the concrete path list, which starts at secrets and
grows as the procedure earns trust; retention and check cadences, which need a
real repository to size; append-only remotes, deferred because credentials a
thief could use to delete an offsite copy are a smaller risk than having no
offsite copy; and the disk-space work, a separate problem this change precedes.
