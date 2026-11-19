# Proposal

## Why

A jailed session sees only the directory it was launched from, but work in one
project often needs to read another -- a library it depends on, a sibling
service, a reference implementation. The agents' own "add a directory" commands
cannot help, because a path outside the launch directory does not exist inside
the jail.

## What Changes

- The jailed wrappers accept leading flags naming further directories to bind
  into the session at their real host paths: `--reveal <dir>` read-only,
  `--reveal-rw <dir>` writable. Everything after them reaches the agent
  unchanged.
- A revealed path must resolve to an existing directory under the home
  directory, other than the home directory itself and with no hidden component.
  Anything else aborts the launch, naming the path.
- The wrapper only makes the directories present. Registering one with the agent
  stays the operator's step, through the agent's own command for it.
- The launch directory stays writable even when a revealed directory contains
  it.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `agent-jail`: project scoping widens from exactly the launch directory to the
  launch directory plus what the operator reveals at launch, and the home
  listing a session sees includes those directories.

## Impact

`home/agent-jail.nix` only: argument parsing, path validation and the extra
binds in the shared wrapper, so every jailed command gains the flags at once.

Out of scope: a persistent per-project list of revealed directories, binds
outside the home directory, registering revealed directories with each
harness automatically, and anything the `011-jailed-containers` change
proposes.
