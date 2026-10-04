## Why

`master` is 46 commits ahead of a public `origin/master` last updated in
January 2025, and cannot be pushed as it stands. The configuration itself is
clean -- no tracked file outside `plans/` contains a client name, a personal
identifier or a secret -- but 20 commits carry `plans/`, the superseded
hand-written planning workflow, whose files name a client, a client project,
the work-tree layout and the weaknesses this machine is known to still have.
OpenSpec replaces that workflow, so the plans are being removed rather than
migrated.

## What Changes

- Salvage the two plans whose reasoning is still load-bearing, while they
  still exist on disk: the applied agent-jail design becomes a baseline entry
  in `openspec/specs/`, and the investigated-but-unapplied jailed-containers
  design becomes a pending change of its own.
- Delete `plans/` and rewrite the unpushed history so no commit on any ref
  contains a `plans/` path. **BREAKING** for any other clone of this
  repository: it diverges and must be re-cloned rather than pulled.
- Remove `config/ai/`, a copy-library that `home/ai.nix` never installs and
  that nothing else references, and the README paragraph pointing at it.
- Add the two durable controls: `plans/` in `.gitignore`, because an installed
  opencode agent can still produce such a folder, and the project's hard
  constraint in `openspec/config.yaml`, which until now is an unfilled
  placeholder.

## Capabilities

No capability's behaviour changes. `.openspec.yaml` sets `skip_specs: true`.
The `agent-jail` spec this change writes records behaviour that already ships;
it is a baseline import, not a delta.

## Impact

`.gitignore`, `README.md`, `AGENTS.md`, `openspec/` (its config, the
`agent-jail` spec, this change and `011`) and the `.claude/` workflow tooling,
which this change is also what first publishes; `config/ai/` and `plans/`
removed; and every commit from the first plan commit onward. Nothing is pushed.
`config/opencode/` and `home/` are untouched.
