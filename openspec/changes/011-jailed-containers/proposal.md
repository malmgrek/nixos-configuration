## Why

`agent-jail` withholds the container daemon socket: any process that reaches a
daemon can ask it to mount the operator's home directory, returning everything
the jail exists to withhold. So container work leaves the jail. This gives
jailed agents an ordinary Docker daemon whose own filesystem view holds only the
project trees it is told about.

## What Changes

- A second rootless Docker daemon runs as its own system user, storing images
  and volumes under `/var/lib`, not in any home directory.
- Its filesystem view replaces the operator's home directory with an empty one,
  into which only a declared list of project roots is bound back at their real
  paths, so existing `-v` arguments and compose files keep working.
- The declared roots become group-accessible to the daemon user; nothing else in
  the home directory does.
- New opt-in wrappers receive that socket; the existing jailed wrappers are
  unchanged and still have none.
- Verification happens in a throwaway VM before anything reaches the host.

## Capabilities

### New Capabilities
- `jailed-containers`: a container daemon reachable from a jailed agent session,
  confined to declared project roots by two independent barriers.

### Modified Capabilities
- `agent-jail`: the prohibition on reaching a container daemon socket becomes
  conditional. It still holds for every existing wrapper; for the new opt-in
  wrappers it is replaced by a requirement on what that daemon may itself see.

## Impact

A module for the daemon user, unit and confinement; an option listing the
project roots; an opt-in parameter and two wrapper variants in the jail module;
a permission change on the declared roots only. The operator's own rootless
Docker is untouched. Out of scope: nesting a runtime inside the agent's
namespace, binds outside the declared roots, and resource limits.
