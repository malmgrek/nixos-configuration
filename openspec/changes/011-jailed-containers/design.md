## Decisions at a glance

1. Separate the daemon by Linux user, not by nesting a runtime inside the
   agent's own namespace.
2. Reverse `agent-jail`'s "no separate Linux users" reasoning for this case
   only, and narrowly: a daemon is a service, not an operator.
3. Run it as a NixOS system service with `User=`, not a systemd user service.
4. Confine it with systemd's own namespacing directives, not a hand-written
   prologue.
5. Bind the project roots at their real paths, so nothing the operator already
   wrote has to be rewritten.
6. Declare the roots as an explicit allowlist, which fails loudly rather than
   leaking silently.
7. Make the socket opt-in per wrapper; leave the existing wrappers alone.
8. Leave the operator's own rootless Docker entirely untouched.
9. Verify in a VM before the host.

## Context

Four facts were measured before this design was written, and it depends on all
four:

- The operator's home directory is mode `0700`. A separate daemon uid therefore
  cannot reach any of its files by path, independently of any namespace work.
- `docker build` streams its context over the socket. A build whose context path
  existed only inside a jail's private filesystem -- a path the daemon could not
  resolve -- completed and produced a correct image. Dockerfile iteration does
  not require the daemon to see the project at all.
- `docker run -v <path the daemon cannot see>:/x` mounts an **empty
  directory** and reports no error. Bind mounts fail silently, which is why
  the project roots must be bound into the daemon's view rather than left out
  and hoped for.
- This configuration already evaluates to a VM derivation, so a throwaway VM is
  available as the verification path before anything touches the host.

Nothing in this change has been executed. The daemon unit, its confinement and
the socket permissions are all untested. See `proposal.md` for motivation, and
`openspec/specs/agent-jail/spec.md` for the boundary this builds on.

## Goals / Non-Goals

**Goals:** an ordinary Docker daemon -- multi-uid images, service containers,
named volumes, bridge networks with container DNS, published ports -- reachable
from a jailed session, confined to the declared project roots by two barriers
that are independently sufficient.

**Non-Goals:** protecting the whole host, as opposed to the operator's data; and
network isolation, which `agent-jail` already rules out and this change does not
revisit.

## Decisions

**Separate by Linux user rather than by namespace nesting.** Two alternatives
were investigated and rejected, recorded here so the finding is not re-derived.
Rootless podman inside the agent's own namespace works but is limited to a
single uid, so service images such as `postgres` and `redis` cannot start
(`chown: Invalid argument`). Establishing the user namespace before the jail
lifts that limit, but costs `--cap-add ALL`, a delegated cgroup subtree, and
launching through a transient systemd scope. A second uid achieves the same
protection with a guarantee that is one `ls -ld` to audit.

**Reverse the "no separate Linux users" decision, narrowly.** The jail's
original design reasoned that the Unix user model separates different people
who hold different data, while an operator and an agent share one workspace
and differ only in capability. That holds for the agent and this change does
not disturb it. It does not hold for a daemon: a daemon is a service with its
own data and no legitimate interest in the operator's files, which is
precisely what the user model separates well.

**A system service with `User=`, not a systemd user service.** A user service
would need lingering enabled, a user manager for a non-login account, and
per-user service entries that NixOS applies to every user. A system service
keeps the unit in one place and takes cgroup delegation from the unit itself.

**Confine with systemd's own namespacing directives.** They are declarative,
reviewable in the unit, and the rootless runtime's own child namespace inherits
the restriction -- which removes the one part of this design that would
otherwise have needed a hand-written prologue script.

**Bind the project roots at their real paths.** The operator's projects do not
move, so a container's `-v /real/path/project/x:/app` resolves inside the daemon
to the real tree and existing compose files and `-v` arguments keep working.

**An explicit allowlist of roots, where `agent-jail` rejected a blocklist.** The
failure directions are opposite. There, a forgotten entry in a list of secrets
to hide would leak a secret silently; here, an unlisted path is simply absent
from the daemon's view, so forgetting one breaks a build loudly.

**Group access scoped to the declared roots only.** The daemon user is granted
group read-write on those trees, with the setgid bit on directories so new files
inherit the group. The daemon user is *not* added to the operator's primary
group: that would grant it access to every file the operator owns, and although
the namespace would currently still hide most of them, it would make the
namespace the only barrier for those files. Two independent barriers is the
whole point.

**Opt-in socket per wrapper.** New wrapper names receive the socket; the
existing jailed wrappers keep none. `agent-jail` excluded the socket
deliberately, and what this change alters is what the socket exposes, not that
judgement -- so both forms stay available and comparable in practice.

**Leave the operator's own rootless Docker untouched.** Interactive `docker`
keeps talking to the existing daemon on the existing socket. The new daemon is
reachable only through the environment set inside the opt-in wrappers.

**Verify in a VM first.** Building a VM from this configuration needs no root
and changes nothing outside the store, and every check must be run from inside a
jailed session rather than as the operator, because the claim under test is
about what an *agent* can reach.

## Risks / Trade-offs

- Files a container writes into a bound project directory are owned by the
  daemon user or one of its subuids. The operator can delete them, because
  deletion depends on the directory's permission bits, but cannot edit them in
  place. This is the familiar root-owned-build-output annoyance with a different
  uid on it, and it is the design's main day-to-day cost.
- Everything inside the declared roots is fully exposed to the agent, read and
  write, through the daemon. That is the intent: the agent already has it
  directly.
- A socket holder has full control of that daemon, including privileged
  containers and host networking. Confined to what the daemon can see, that
  means the declared roots and nothing else of the operator's.
- The daemon can read world-readable system paths. This design protects the
  operator's data, not the whole host.
- The temporary-filesystem directive is load-bearing alongside the uid barrier.
  A typo in the bind list fails closed, because a missing path is simply absent;
  a mistake that drops the temporary filesystem would silently fall back to the
  uid barrier alone. Verification must therefore assert the negative case from
  inside a container rather than trust the unit text.
- A second image store is unbounded and duplicates images the operator has
  already pulled -- roughly 0.5 GB for four images during investigation. No
  quota is applied; the reclaim procedure is to stop the daemon and delete its
  state directory.
- Adding a project root later means both appending to the option and applying
  the group and setgid change to that tree. The setgid bit does not propagate to
  a root that did not exist when it was set.

## Migration Plan

VM first, then `nixos-rebuild test` on the host, which is active immediately and
leaves the bootloader untouched so a reboot returns the machine to the current
generation, and only then `switch`. The module's import is the on switch, as in
`agent-jail`: removing the line removes the daemon, its user and the wrappers,
so no feature flag is added for something an import already expresses.
