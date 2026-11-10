# Design

## Decisions

| # | Decision | Why |
| - | -------- | --- |
| 1 | `restic` through `services.restic.backups`, not a script | Encryption, deduplication, snapshots, pruning and integrity checking are security-critical and already solved. It also streams rather than staging, so protecting tens of gigabytes needs no free space to do it in — which a `tar`-to-file script would. |
| 2 | One declared path set, mapped over a set of targets | The capability requires paths and targets to vary independently. Generating one job per target from a single list makes that structural rather than a convention a later edit can break. |
| 3 | Each target is an independent repository | Any single target restores on its own, and corruption cannot propagate from a primary. The cost is re-uploading the same data per target, which is acceptable at this volume. |
| 4 | Passphrase read from a root-only file this repository names but never holds | This repository is published. It can declare where the secret is read from; the value is placed by hand, once. |
| 5 | Root of trust is memorized, with a paper copy kept elsewhere | Breaks the circularity the capability forbids: no stored file of the operator's is needed to open the copy that holds their stored files. |
| 6 | The bench drives with NixOS and asserts with literals | A test that reads its expectations from the declaration under test agrees with itself when the declaration is wrong, which is exactly the failure most likely to occur. |
| 7 | One backend-agnostic verification script, shared by bench and cold restore | The drill then exercises the same code the bench does, so it is rehearsed rather than improvised, and the script needs nothing from this repository. |
| 8 | Freshness is pulled and displayed; failures are pushed as notifications | "No copy was ever attempted" produces no event, so no notification can report it. Only a staleness read expresses it. |
| 9 | One systemd unit per target, none depending on another | An absent target is the normal state for removable media and for a host that is off. One unreachable target must not stop the others. |
| 10 | The mechanism's local cache is placed explicitly, never defaulted | The root filesystem is nearly full. An unbounded cache under the running user's home is the one way this change could worsen the problem it is adjacent to. |

## Context

See `proposal.md` — Why. Three constraints shape the approach rather than the
motivation:

- The root filesystem is at ninety-two percent. Anything requiring scratch space
  proportional to the protected set is unavailable, and a unit that fills the
  disk breaks the thing it was added to provide.
- Targets are heterogeneous and intermittent by nature: removable media, a host
  on the operator's local network, and rented storage. Only the last is reachable
  at all times, and only the last is in a different place from the machine.
- `openspec/specs/dotfiles` already states that data and state directories are
  beyond its reach, and accepts that. This capability is the other side of that
  boundary, so nothing here needs to move it.

## Goals / Non-Goals

**Goals:**

- A declaration a reader can answer "what is protected?" from, without inspecting
  a copy.
- A restore that works on hardware that has never seen this repository.
- Verification whose failure mode is a failed test rather than a passing one.

**Non-Goals:**

- Protecting what this repository already reproduces. The system closure is not
  data.
- Bare-metal or whole-disk imaging. The protected set is files, and a reinstall
  plus this repository plus a restore is the recovery path.
- Replicating the operator's mail or code hosting. Where a server already holds
  a copy, a path may be excluded on that ground, stated where it is excluded.

## Reaching the built system

- **The copies themselves.** A new module declares one
  `services.restic.backups.<target>` entry per configured target; a reader greps
  `services.restic.backups`. What it makes true of the built system is a systemd
  timer and service per target, each invoking the mechanism against one
  repository with the same path list. Remove the module and there are no timers,
  no units and no copies — and nothing else in the configuration would report
  that, which is precisely why the capability puts the burden of proof on an
  observed restore rather than on a successful build.
- **Freshness.** `config/i3status-rs/config.toml` carries the block that displays
  each target's age. Without it the capability's visibility requirement is unmet
  and a stalled target becomes invisible; a reader greps the block's command
  name. The command itself is the one place that reads repository state for
  display rather than for restore.
- **Verification.** A `tests/` entry carries the bench — this repository's first
  test that boots a machine, where `tests/trusted-users.nix` only evaluates. A
  shell script, referenced by both the bench and the documented cold restore,
  carries the comparison. Without the script the capability's verification
  requirement has no implementation, and a reader would be left taking a green
  build as proof, which the capability explicitly forbids.
- **The secret's location.** The module names the file the passphrase is read
  from. The file is not in this repository and is not created by it; a rebuild on
  a fresh machine therefore produces units that fail until a human places it,
  which is the correct behaviour — a backup silently running without the
  operator's secret would be a backup nobody can open.

## Risks / Trade-offs

- **The declaration protects the wrong set, and everything passes** → literal
  fixtures in the bench (decision 6), plus a cold restore compared against a
  manifest written by hand. This is the failure the whole verification design
  exists for.
- **The disk fills and the units fail quietly** → the cache is placed explicitly
  (decision 10) and the staleness display surfaces the stall. Headroom itself is
  the separate disk change this one precedes.
- **The first seed is tens of gigabytes over domestic upstream** → seed to
  removable media at local speed, then copy that repository to the remote, rather
  than uploading from scratch.
- **Whoever takes the machine can delete the offsite copy** → accepted for now;
  the reason is in `proposal.md` — Impact. An append-only remote is the upgrade
  path, and it is a change of its own because it alters the credential model.
- **The bench stays green while the real repository rots** → a scheduled
  integrity check against each real repository, which is the only tier that can
  read real bytes. Its cadence is deferred below; its existence is not.
- **The paper secret was never actually written, or is wrong** → only a cold
  restore detects this. The drill is therefore scheduled before the protected set
  grows past secrets, while a failed restore still costs nothing.

## Migration Plan

No migration: nothing exists to migrate from. Deployment order matters, though,
because the value of each step depends on the one before it.

1. Secrets only, one target, restore demonstrated. The protected set is a few
   hundred kilobytes, so a wrong declaration is cheap to discover.
2. Remaining targets added, each one restored from before it is believed.
3. The protected set grows to the bulk data, by which time the procedure is the
   part that is already proved.

Rollback is removing the module; it destroys no data, and leaves existing
repositories readable by the mechanism's program and the passphrase alone.

## Open Questions

- The concrete path list beyond secrets. Deliberately deferred: the capability
  requires the declaration to be authoritative, not to be complete on day one.
- Retention and prune counts, and the cadence of the real-repository integrity
  check. Both want a real repository's size and growth to choose sensibly.
- Which transport the host on the local network is reached by. It changes a
  repository URL and nothing else.
