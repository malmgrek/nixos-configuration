## MODIFIED Requirements

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
