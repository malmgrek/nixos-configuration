# Design

## Decisions

| # | Decision | Why |
| - | -------- | --- |
| 1 | Parse the flags in `mkJailedAgent`, not per harness | One code path gives every jailed command, `jailed-shell` included, the same behaviour, so verifying the shell verifies the agents. |
| 2 | Leading flags only: parsing stops at the first argument that is not `--reveal` or `--reveal-rw` | The agent's arguments reach it untouched, and no list of agent flags has to be kept in step with three CLIs. |
| 3 | Validate the resolved path, then bind through an open file descriptor (`--ro-bind-fd` / `--bind-fd`) | Checking a path and binding it by name later leaves a gap in which a concurrent session with a writable project could swap a component for a symlink. Binding the descriptor that was checked closes it. The session must not inherit that descriptor, since an open host directory would let it write past a read-only bind; `bwrap` closes it, and `tests/reveal.sh` asserts so. |
| 4 | The hidden-component test runs on the resolved path, relative to `$HOME` | A symlink in a visible place cannot smuggle in `~/.ssh`, and the session's own state, under `~/.local`, is excluded by the same rule. |
| 5 | Binds go shallowest first, then the launch directory last | The most specific bind wins whatever order the flags were typed in, and a revealed parent can never make the project read-only. |
| 6 | Paths inside the launch directory are refused, not ignored | The launch directory's bind would hide them, so accepting one would silently do nothing. |
| 7 | No registration with the agent | Making the path exist is what was missing; each harness's own command for adding a directory then works unchanged. |

## Context

See `proposal.md` -- Why. The wrapper is a `writeShellApplication` around one
`bwrap` call, and `$HOME` there is still the operator's real home, so judging
paths against it needs no extra configuration.

## Reaching the built system

`home/agent-jail.nix` carries all of it, inside `mkJailedAgent`; a reader greps
`--reveal`. It makes every `jailed-*` script on `PATH` accept the flags.
Remove the parsing and the wrappers behave exactly as they do today, because
with no flags given the `bwrap` call is unchanged. The README's AI tools
section documents the flags; without that the only place they are written down
is the wrapper's source.

## Risks / Trade-offs

- [A revealed repository's untracked files, `.env` included, become readable to
  the session] -> Accepted: the operator names each directory at launch, and
  the hidden-component rule keeps per-user credential directories out by
  default. Reveal the narrowest directory that serves.
- [`bwrap` creates the parents of each revealed path inside the state
  directory, because that directory is what is bound over `$HOME`, and they
  persist as empty directories] -> Accepted: they are the empty mount points
  the existing "Persistent per-agent state" requirement already allows for, and
  they hold no content. Task 1.3 confirms on the running system that they stay
  empty.
- [An agent's command for adding a directory may refuse a read-only one] -> The
  spec does not depend on it, but it is the point of the change, so task 1.3
  checks it with Claude Code by hand before the change is called done.
- [Launched through a symlinked path, the project is bound at the logical
  `$PWD` but judged by its resolved path] -> Accepted: a revealed parent of the
  resolved path shows the project read-only there while it stays writable at
  the launch path, and revealing the resolved path itself is refused. Both
  stay inside what the spec allows; launch from the real path to avoid it.

## Migration Plan

None. With no flags the wrappers behave as before; rollback is a rebuild
without the change.
