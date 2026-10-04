# agent-jail Specification

## Purpose

Confine a CLI coding agent to the project directory it was launched from, so a
session reaches that project, the Nix store and its own state, and nothing else
of the operator's home directory. The confinement is a property of the session
process rather than of any individual command, so every child process inherits
it.

These requirements were imported from a shipped implementation rather than
agreed before it: they record behaviour observed in the running configuration,
and the verification transcripts behind them were deleted with the planning
documents they lived in. Treat the configuration as the authority where the two
disagree, and correct the spec rather than the code.

## Requirements

### Requirement: Opt-in jailed commands

The system SHALL provide a jailed command per supported harness alongside the
unmodified upstream command, so the jail is opted into per invocation and no
existing workflow changes. A jailed interactive shell SHALL be built by the same
mechanism as the agents, so that verifying the shell verifies the agents.

#### Scenario: Both forms are available
- **WHEN** the operator looks up the harness commands on `PATH`
- **THEN** a jailed form and the unmodified upstream form both resolve, and the
  upstream form behaves exactly as it did before the jail existed

#### Scenario: The capability leaves no residue
- **WHEN** the jail is not enabled
- **THEN** the built system derivation MUST be identical to one built before
  this capability existed, with no leftover option, package-list entry or
  wrapper in any other part of the configuration

### Requirement: Default-deny home directory

A jailed session SHALL NOT be able to reach any path under the operator's home
directory except those explicitly bound into it. Exclusion MUST be achieved by
default-deny rather than by enumerating sensitive paths, so that a newly created
secret directory is excluded without any configuration change. No secret path
SHALL be named in the configuration.

#### Scenario: Secrets are absent rather than denied
- **WHEN** a jailed session tests for the existence of the operator's SSH keys,
  GPG directory, password store, or documents
- **THEN** each path MUST NOT exist inside the session, rather than existing and
  refusing access

#### Scenario: A new secret directory needs no configuration change
- **WHEN** a sensitive directory that the configuration has never named is
  created in the operator's home
- **THEN** it MUST be unreachable from a jailed session with no change to the
  jail

### Requirement: Project scoping

A jailed session SHALL see exactly the directory it was launched from, bound at
its real host path so that absolute paths mean the same thing inside and outside
the session. Sibling and parent directories of that project MUST NOT be
reachable.

#### Scenario: Only the launch directory is present
- **WHEN** a session is launched from one project
- **THEN** the working directory inside equals the host path it was launched
  from, and no other project under the same parent is visible

#### Scenario: The launch directory decides what the project can read
- **WHEN** a session is launched from a subdirectory of a repository and a tool
  inside it reads a file above that subdirectory
- **THEN** the read MUST fail, because only the launch directory is bound; the
  session is therefore launched from the repository root when the toolchain
  reaches upward

### Requirement: Confinement is inherited

The confinement SHALL be a property of the session's namespace, so that every
process the session starts is subject to it without being enumerated. Ad-hoc
shells, package-runner commands and MCP server processes MUST be covered.

#### Scenario: A nested process is equally confined
- **WHEN** a jailed session starts a child shell and that child tests for a path
  outside the jail
- **THEN** the path MUST be absent inside the child exactly as in the parent

### Requirement: Privilege escalation is unavailable

A jailed session SHALL NOT be able to acquire privileges beyond those of the
calling user, even though it runs under the same user id. Only the calling
user's id SHALL be mapped into the session, so files belonging to any other user
appear owned by an unmapped placeholder id.

#### Scenario: Setuid escalation fails
- **WHEN** a jailed session attempts to escalate privileges through a setuid
  helper
- **THEN** the attempt MUST fail, because the setuid wrappers are not present in
  the session and new privileges are refused

#### Scenario: System files appear unowned
- **WHEN** a jailed session inspects the ownership of a file owned by another
  user, such as a system configuration file or a path in the shared store
- **THEN** it MUST appear owned by an unmapped placeholder id rather than by its
  real owner

#### Scenario: An ownership-checking program refuses its own configuration
- **WHEN** a jailed session runs a program that validates the ownership of its
  own system configuration before using it
- **THEN** that program MUST be expected to refuse to run until it is pointed
  away from that configuration, because the file reads as unowned inside the
  session

### Requirement: Persistent per-agent state

Each jailed harness SHALL have its own state directory, bound over the home
directory path so that the agent's own configuration and history persist across
sessions while the operator's real home remains absent. The state directory
SHALL be selectable independently of the command name, so a variant can isolate
one project's agent history from every other project's.

#### Scenario: State survives a session ending
- **WHEN** a jailed session writes to its home directory and exits, and a new
  session is started later
- **THEN** the earlier content MUST still be present

#### Scenario: The operator's home is still absent
- **WHEN** a jailed session lists its home directory
- **THEN** it MUST contain only agent state, the read-only tool-profile paths
  that keep `PATH` working, and the empty mount points the session mechanism
  creates -- and no directory of the operator's real home

### Requirement: System configuration is present and read-only

A jailed session SHALL have the host's system configuration directory
available, whole and read-only, rather than an enumerated subset of it. On this
system that directory is almost entirely links into the shared store, and one
bind is auditable where several that must stay in sync are not. This is the
broadest thing inside a session that is not the store itself, so a change
narrowing or widening it is a change to this capability.

#### Scenario: Name resolution and certificate validation work
- **WHEN** a jailed session resolves a hostname or validates a TLS certificate
- **THEN** it MUST succeed, because the system configuration those need is
  present inside the session

#### Scenario: The system configuration cannot be modified
- **WHEN** a jailed session attempts to write into that directory
- **THEN** the write MUST be refused

### Requirement: Declarative dependency resolution inside the jail

A jailed session SHALL be able to resolve ad-hoc and project dependencies
through Nix, so that dependency fetching does not get redirected to unpinned,
unreviewable alternatives. The build service MUST remain unable to read the
operator's home: it SHALL only build sandboxed derivations into the shared
store. This depends on the calling user not being a trusted user of that
service -- a configuration granting that trust would let a session request an
unsandboxed build and read the home directory this capability withholds, so
granting it is a change to this capability and not a convenience.

#### Scenario: An ad-hoc dependency resolves
- **WHEN** a jailed session asks for a package that is not installed and runs a
  command from it
- **THEN** the package MUST be built or fetched into the store and the command
  MUST run

#### Scenario: A project environment resolves
- **WHEN** a jailed session enters a project whose environment is declared in
  the project itself
- **THEN** the declared interpreters, libraries and `PATH` entries MUST resolve,
  including entries that live under the home directory path

### Requirement: No container daemon socket

A jailed session SHALL NOT be given access to a container daemon socket. Any
process able to reach such a daemon can ask it to mount the operator's home
directory, which would return everything the jail withholds. The unmodified
upstream command is the supported route for work that genuinely requires a
container daemon.

#### Scenario: Container commands fail inside the jail
- **WHEN** a jailed session runs a container command against the daemon
- **THEN** the command MUST fail

### Requirement: Shared network namespace

A jailed session SHALL share the host network namespace, because agents must
drive services the operator runs locally. Network isolation is therefore not
part of this capability, and every locally listening service is reachable from
inside a session.

#### Scenario: A local service is reachable
- **WHEN** a service is started outside the jail on a local port and a jailed
  session requests it
- **THEN** the request MUST succeed

#### Scenario: A browser automation tool drives that service
- **WHEN** a jailed session drives a headless browser against that local service
- **THEN** the automation MUST succeed without disabling the browser's own
  sandbox

### Requirement: Foreign toolchains execute

A jailed session SHALL be able to run software that was not built by Nix:
interpreter shims resolved through the filesystem-standard paths, prebuilt
dynamically linked binaries, and virtual environments whose interpreter is
managed outside the project. These paths SHALL be bound read-only, and SHALL
expose no file that was not already readable inside the session.

#### Scenario: An imperatively packaged project runs
- **WHEN** a jailed session runs a package-manager-installed executable shim, a
  prebuilt native extension, or a virtual environment whose interpreter lives
  outside the project
- **THEN** each MUST work, rather than failing with a missing interpreter or
  missing loader

#### Scenario: The bound toolchain paths are read-only
- **WHEN** a jailed session attempts to write into a bound compatibility path or
  the managed interpreter store
- **THEN** the write MUST be refused

#### Scenario: Binding a subdirectory does not expose its siblings
- **WHEN** a managed interpreter store is bound from within a parent directory
  that also holds credentials
- **THEN** only the bound subdirectory MUST be present inside the session, and
  its sibling directories MUST be absent

#### Scenario: A machine where the optional toolchain was never used still works
- **WHEN** the managed interpreter directory does not exist on the host
- **THEN** every jailed command MUST still launch

### Requirement: Caches are not shared with the host

Package and build caches of the operator SHALL NOT be writable from a jailed
session. A session re-downloading its own dependencies is accepted in exchange:
a writable shared cache would let a jailed session place content that the
operator's unjailed work later consumes, which crosses the boundary rather than
reading through it.

#### Scenario: A jailed session cannot write the operator's caches
- **WHEN** a jailed session fetches dependencies
- **THEN** the artefacts MUST land inside the session's own state or the
  project, and the operator's caches MUST be unaffected

### Requirement: Environment passthrough

A jailed session SHALL inherit the caller's environment unchanged, so that a
project environment already resolved outside the session continues to work with
no forwarding logic. Exactly one variable MAY be set deliberately, to select
daemon-mediated access to the shared store; any other modification is outside
this capability.

#### Scenario: A pre-resolved project environment survives the transition
- **WHEN** the operator has activated a project environment and then launches a
  jailed session from that directory
- **THEN** the tools that environment provided MUST resolve inside the session

### Requirement: A session's own state may shadow a sensitive name

A session writes freely into its own state directory, so that directory may
come to hold a path whose name matches one of the operator's sensitive
directories. Such a path SHALL NOT be taken as evidence that the jail leaks:
the two are different directories, and the operator's is still absent.

#### Scenario: An agent's own file does not read as a leak
- **WHEN** a session has created, inside its own state directory, a directory
  whose name matches one of the operator's sensitive directories
- **THEN** that path existing inside the jail MUST NOT be treated as a leak,
  and whatever asserts absence MUST do so on a path no session can create
