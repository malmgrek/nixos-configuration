# dotfiles Specification

## Purpose
States how this configuration's dotfiles reach the operator's home directory:
which of them take effect the moment they are saved, which are built and need a
rebuild, and what the repository stops guaranteeing in exchange.

## Requirements

### Requirement: Editing a live dotfile needs no rebuild

A configuration file in a live directory SHALL take effect through nothing but
the application's own reload, with no rebuild and no activation step between
saving the file and the application reading it.

A live directory is one the home directory reaches by reference rather than by
copy, so that the file the application opens and the file in the repository's
working tree are the same file.

#### Scenario: A theme is adjusted and reloaded
- **WHEN** the operator edits Doom's configuration in the repository working
  tree and reloads Doom
- **THEN** the edit is in effect, and no rebuild has run

#### Scenario: An unsaved repository is still the live copy
- **WHEN** the operator edits a file in a live directory and does not commit it
- **THEN** the application reads the edited file, because the working tree is
  what the home directory points at

### Requirement: Adding a file to a live directory needs no configuration change

A file newly created in a live directory SHALL be visible to its application
without any edit to this configuration, so that the set of files inside such a
directory is not a thing the configuration enumerates.

#### Scenario: A new agent definition appears
- **WHEN** a new agent definition is written into the opencode directory in the
  repository
- **THEN** opencode finds it, and no module in this configuration names it

### Requirement: Generated configuration is a closed and justified set

Of the configuration this repository places in the operator's home directory as
a file an operator would otherwise edit by hand, the part whose source cannot be
edited without a rebuild SHALL be limited to files whose content cannot be
chosen at the moment the application reads it, and each SHALL carry, where it is
declared, the reason it is in that set. Delivery does not decide membership: a
built file reaches the home directory by a link like any other, and it is the
rebuild, not the mechanism, that puts it in this set.

Configuration this repository declares as options instead of authoring as a
file -- mime associations and browser preferences -- is outside this capability:
there is no file an operator would edit, so there is nothing to link.

This boundary is accepted rather than merely tolerated. A file that embeds a
path into the store has no runtime form to read at all. A file whose format
offers no conditional cannot choose at startup however the value reaches it.
One file remains in this set -- the terminal's, whose search path offers no
system layer to lean on and whose format offers no conditional -- and it is not
edited often enough for that rebuild to be a cost worth removing.

Where a tool reads a system file before the operator's own, the part that cannot
be live SHALL go in the system file rather than forcing the whole configuration
to be generated. A tool offering no such seam is the only reason a
hand-edited file stays generated.

Configuration this repository delivers through `/etc` instead of the home
directory is outside this capability, whether or not it is interpolated. It
reaches its application by a route this capability does not describe, and the
home directory is where the rebuild this capability removes was being paid. A
system file that a live file is layered on top of is not such a case: the pair
is one configuration, and the live half is in scope.

#### Scenario: A colour scheme is chosen at read time, not build time
- **WHEN** an application can select its colour scheme from the environment at
  startup
- **THEN** its configuration is live rather than generated, and the
  configuration does not interpolate the choice into it

#### Scenario: A value exists only once the system is built
- **WHEN** a configuration file in the home directory must embed a path into
  the store
- **THEN** that file is generated, or the embedding part is moved to the system
  file the tool reads first and the operator's file stays live

#### Scenario: A tool reads a system file before the operator's
- **WHEN** a tool's plugin paths exist only once the system is built, and the
  tool loads a system file ahead of the operator's own
- **THEN** those paths are declared in the system file and the operator's file
  is live, naming no store path

#### Scenario: A tool has neither a system layer nor a conditional
- **WHEN** an application reads its configuration only from the operator's own
  directory, and its format cannot choose a value at startup
- **THEN** the file is built into the store and the home directory links at the
  store rather than at the working tree, and it is in the generated set despite
  arriving as a link

#### Scenario: A file reaching /etc is not in the set
- **WHEN** this repository delivers a configuration file through `/etc` rather
  than the home directory, and no live file is layered on it
- **THEN** whether it is built or linked is outside this capability, and its
  absence from the set is not a gap in it
### Requirement: A setting changed inside an application survives as history

Where an application writes its own settings into a live directory, those writes
SHALL land in the repository working tree, so that a choice made in the
application's interface becomes a reviewable change rather than something
discarded at the next rebuild.

An application may rewrite a file the operator authored in order to record such a
choice, and SHALL be allowed to -- that rewrite is the change the operator
reviews. Comments and commented-out alternatives in that file are not protected
from it.

A setting an application keeps outside its configuration directory, in a state or
data directory of its own, is beyond this reach, and no rebuild SHALL delete it
to reassert a declared default. The limitation is accepted because linking such a
directory would drag caches, conversation history and credentials into a
published repository to capture the few decisions among them.

Churn written into a live directory -- caches, dependency trees, migration
backups, recency lists -- SHALL be excluded from the repository, because it
carries no decision worth reviewing.

A file that carries a decision and churn together, or whose classification
cannot be confirmed, SHALL stay tracked instead: a wrongly excluded decision
fails silently, where tracked churn only shows as noise in a diff.

#### Scenario: A theme is chosen in an application's interface
- **WHEN** the operator selects a theme inside opencode and quits
- **THEN** the selection appears as a change in the repository, to commit or
  discard, and a later rebuild does not revert it

#### Scenario: Recording a choice rewrites an authored file
- **WHEN** an application moves a setting out of a file the operator wrote, to
  record it in a file of its own
- **THEN** both edits appear in the repository, the operator's file having lost
  what it said about that setting

#### Scenario: A plugin set is resolved and pinned
- **WHEN** an editor resolves its plugins and writes the versions it pinned into
  its own configuration directory, which is live
- **THEN** the pin file appears as a change in the repository, to commit or
  discard

#### Scenario: A credential is kept outside the configuration directory
- **WHEN** an application stores a credential in a data directory of its own
- **THEN** nothing of it reaches the working tree, and a rule naming it is a
  guard against a later version moving it rather than a record of churn

#### Scenario: A dependency tree is installed beside the configuration
- **WHEN** an application installs its own dependencies into a live directory
- **THEN** the repository ignores them

### Requirement: A successful build no longer proves the desktop

This configuration SHALL NOT be read as claiming that a system which evaluates
and builds has correct dotfiles, and a rollback SHALL NOT be read as reverting
them.

The limitation is accepted because these files are version-controlled in this
same repository, which is already their only source of truth and already holds
their history; what is lost is a second copy of that guarantee, not the
guarantee. The cost of the gap is that a machine restored from this
configuration alone, without the repository present at the path the links name,
has applications running on their own defaults.

#### Scenario: The system builds and a dotfile is broken
- **WHEN** a live dotfile contains a syntax error its application rejects
- **THEN** the system still evaluates and builds, and the error surfaces when
  the application next starts

#### Scenario: A rollback leaves dotfiles where they are
- **WHEN** the operator boots a previous generation
- **THEN** the live dotfiles are the ones currently in the working tree, not
  the ones current when that generation was built
