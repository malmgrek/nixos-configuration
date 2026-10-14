## Purpose

Let a host pin the display density its session renders at, once, so that every
toolkit reads the same number and none of them changes the size of its text
because the resolution changed.

## ADDED Requirements

### Requirement: One declaration, and it pins rather than scales

The configuration SHALL expose exactly one option for display density: a value
that is either absent or a number. Absent SHALL mean nothing is declared and
every setting that would carry a density is left at its upstream default. A
number SHALL be the single place that density is written.

No second option SHALL gate the density independently of its value, so that a
host cannot declare a density that is not in effect.

#### Scenario: Nothing declared

- **WHEN** a host leaves the density unset
- **THEN** the X server's reported density and the `Xft.dpi` resource are both
  left to be derived, neither one individually overridden

#### Scenario: A density declared

- **WHEN** a host declares a density
- **THEN** every setting that carries one takes its value from that number, and
  a reader can find all of them by searching for the option's name

### Requirement: Both ways a toolkit learns the density agree, and neither follows the mode

A declared density SHALL be reported by the X server and SHALL also be present as
the `Xft.dpi` X resource, because the two are read by different toolkits and
neither alone reaches all of them.

The resource SHALL be set after any per-user X resource file is loaded and before
the window manager starts, so that it is the effective value for every client in
the session and no client starts before it.

Where a client offers its own density setting, that setting SHALL be given the
declared value rather than left to the client's own detection, if its detection
reads anything other than the two declarations above.

No additional integer scaling mechanism SHALL be declared alongside them, so the
two cannot multiply.

#### Scenario: Changing resolution does not resize text relative to interfaces

- **WHEN** the resolution is changed while a density is declared
- **THEN** every client's text and interface change apparent size by the same
  factor, because none of them is deriving a density from the new mode

#### Scenario: A point-sized font is one physical size

- **WHEN** a font size is stated in points
- **THEN** the configuration states one value for it, because a pinned density
  leaves nothing for a second value to select between

#### Scenario: Toolkit geometry and toolkit text scale together

- **WHEN** an application that reads `Xft.dpi` for its scale factor runs in the
  session
- **THEN** its interface and its text are scaled by the same declared density,
  not one scaled up and the other scaled back down

### Requirement: A declared density is correct for one output only

Where several outputs of different densities are connected, the declared density
SHALL apply globally and MAY be wrong for all but one of them. This limitation
SHALL be stated where the density is declared.

It is accepted because X11 provides exactly one global dpi with no per-output
override; expressing per-output density requires a different display server, so
there is no configuration of this one that would not be a claim the server
cannot keep.

#### Scenario: A second panel of a different density is connected

- **WHEN** an external display whose density differs from the built-in panel is
  connected
- **THEN** both render at the declared density, and the operator is told so by
  the option's own documentation rather than discovering it
