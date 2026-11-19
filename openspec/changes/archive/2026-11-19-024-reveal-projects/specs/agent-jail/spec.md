# Spec Delta

## MODIFIED Requirements

### Requirement: Project scoping

A jailed session SHALL see exactly the directory it was launched from, together
with the directories the operator reveals when launching it, each bound at its
real host path so that absolute paths mean the same thing inside and outside
the session. Sibling and parent directories of the project that were not
revealed MUST NOT be reachable.

#### Scenario: Only the launch directory is present
- **WHEN** a session is launched from one project with nothing revealed
- **THEN** the working directory inside equals the host path it was launched
  from, and no other project under the same parent is visible

#### Scenario: The launch directory decides what the project can read
- **WHEN** a session is launched from a subdirectory of a repository without
  revealing the repository, and a tool inside it reads a file above that
  subdirectory
- **THEN** the read MUST fail, because only the launch directory is bound; the
  session is therefore launched from the repository root when the toolchain
  reaches upward

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
  that keep `PATH` working, the empty mount points the session mechanism
  creates, and the directories revealed at launch together with the parents
  leading to them -- and no other directory of the operator's real home

## ADDED Requirements

### Requirement: Operator-revealed directories

A jailed command SHALL accept, ahead of the agent's arguments, flags revealing
further directories: read-only by default, writable only by an explicit second
form. Revealing is the operator's act at launch: nothing a session writes SHALL
reveal a directory to a later session. The jail only makes a directory present;
registering it with the agent stays the operator's step.

#### Scenario: A revealed directory is readable but not writable
- **WHEN** a session is launched with a directory revealed by the read-only
  form
- **THEN** that directory MUST be present at its host path and readable, and a
  write into it MUST be refused

#### Scenario: The writable form is an explicit choice
- **WHEN** a session is launched with a directory revealed by the writable form
- **THEN** a write into that directory MUST succeed and be visible on the host

#### Scenario: The agent's own arguments pass through
- **WHEN** a jailed command is given reveal flags followed by arguments meant
  for the agent
- **THEN** the agent MUST receive exactly those following arguments, and none
  of the reveal flags

#### Scenario: A revealed parent leaves the project writable
- **WHEN** a session is revealed, read-only, a directory that contains the
  launch directory
- **THEN** the launch directory MUST stay writable while its revealed siblings
  are read-only

#### Scenario: The most specific reveal wins
- **WHEN** two revealed directories are nested and given different access
- **THEN** the inner directory MUST have the access named for it, regardless
  of the order the flags were given in

### Requirement: What may be revealed

A revealed path SHALL be accepted only if, after resolving symbolic links, it
is an existing directory under the operator's home, not the home itself, with
no hidden component, and outside the launch directory. Refusing hidden
components excludes per-user credentials by rule, naming no secret path. A
refused path SHALL abort the launch, naming it.

#### Scenario: Over-broad or outside paths are refused
- **WHEN** a jailed command is asked to reveal the home directory, a path
  outside it, or a path that does not exist or is not a directory
- **THEN** the launch MUST abort before any session starts, naming the path

#### Scenario: Hidden paths are refused
- **WHEN** a jailed command is asked to reveal a path any component of which is
  hidden
- **THEN** the launch MUST abort, naming the path

#### Scenario: A symbolic link cannot smuggle a refused path
- **WHEN** a revealed path is a symbolic link that resolves to a refused path
- **THEN** the launch MUST abort exactly as if the resolved path had been given

#### Scenario: A path inside the project is refused
- **WHEN** a jailed command is asked to reveal the launch directory or a
  directory inside it
- **THEN** the launch MUST abort, because the project is already present and
  writable and the reveal would have no effect
