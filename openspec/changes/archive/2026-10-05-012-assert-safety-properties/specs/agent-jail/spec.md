## ADDED Requirements

### Requirement: The jail does not constrain what the operator later runs

A session writes freely into the project directory, and the operator runs that
work later, outside the jail, with their own privileges -- build hooks,
environment files, version-control hooks and scripts on the project `PATH` all
run that way. This capability bounds what a session can read while it runs, and
SHALL NOT be relied on to bound what the code a session produces does once the
operator runs it. Accepted as inherent to agentic development rather than a
property of this design.

#### Scenario: Agent-authored code runs unconfined
- **WHEN** a session writes a hook or a script into the project and the operator
  later runs that project outside the jail
- **THEN** that code MUST be expected to run with the operator's privileges and
  outside the session's namespace

## MODIFIED Requirements

### Requirement: Declarative dependency resolution inside the jail

A jailed session SHALL be able to resolve ad-hoc and project dependencies
through Nix, so that dependency fetching does not get redirected to unpinned,
unreviewable alternatives. The build service MUST remain unable to read the
operator's home: it SHALL only build sandboxed derivations into the shared
store.

That guarantee rests on the caller not being a trusted user of the build
service. A trusted caller may set options the service refuses to untrusted
ones, including hooks the service then runs itself with its own privileges, and
the service runs outside the session's namespace with the host's view of the
filesystem -- so trusting the caller does not merely widen what a build can
read, it hands over the machine. The configuration SHALL therefore declare its
trusted-user set explicitly rather than inherit it from a default, and SHALL
record alongside that declaration what depends on it. Granting the trust is a
change to this capability and not a convenience.

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

#### Scenario: The build service refuses privileged settings from a session
- **WHEN** a jailed session asks the build service for any setting it restricts
  to trusted callers, such as disabling its sandbox or exposing an extra path
- **THEN** the service MUST ignore that setting and say so, and a build MUST NOT
  be able to read the operator's home directory

#### Scenario: The trusted-user set is declared, not inherited
- **WHEN** the configuration is searched for its trusted-user declaration
- **THEN** that declaration MUST be present, so that an edit granting the trust
  has to overwrite a statement of what depends on it rather than fill a silent
  default

#### Scenario: Granting the trust fails the build
- **WHEN** the configuration is changed so that the user a session runs as
  becomes a trusted user of the build service, by any route the configuration
  can express -- named directly, through a group from either side, or through a
  setting that appends to the trusted set, in list or whitespace-separated form
- **THEN** the configuration MUST fail to evaluate, and the failure MUST name
  what depends on the premise

