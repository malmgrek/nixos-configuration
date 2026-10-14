## Purpose

Let the operator leave the machine locked and physically closed while sessions
inside it keep running, drawing as little power as a locked X session can, for a
length of time the operator chooses at the moment of leaving.

## ADDED Requirements

### Requirement: A lock that draws nothing

Away mode SHALL lock the session with a blank screen and SHALL put the display
into its power-saving state immediately rather than after a delay. No
screensaver module SHALL run while the mode is held.

Unlocking SHALL work exactly as the default lock does: the first key or pointer
event raises the password prompt, and the prompt's appearance MUST match the
default lock's so the operator is not asked to recognise a second prompt.

#### Scenario: The display powers down on entry

- **WHEN** the operator enters away mode
- **THEN** the screen goes blank and the display enters its power-saving state
  without an intervening animation or delay

#### Scenario: Waking shows the usual prompt

- **WHEN** a key is pressed or the pointer moved while away mode is held
- **THEN** the password prompt appears, and accepting the password returns the
  session

#### Scenario: The default lock is unaffected

- **WHEN** the operator locks the session by the existing means, or the idle
  timer fires
- **THEN** the existing lock runs with its screensaver as before, because away
  mode is a separate mode and not a replacement

### Requirement: The lid does not suspend while away mode is held

While away mode is held, closing the lid SHALL NOT suspend the machine, so
processes inside the session keep running and remain reachable. This SHALL be
achieved for the duration of the mode only: once the mode ends, by unlocking or
by its own timer, closing the lid SHALL suspend the machine again.

No persistent system setting SHALL be changed to achieve it, so that a mode that
is not running cannot leave the lid's behaviour altered.

#### Scenario: Sessions survive a closed lid

- **WHEN** the lid is closed while away mode is held
- **THEN** the machine stays awake and processes in the session keep running

#### Scenario: Normal lid behaviour returns

- **WHEN** away mode has ended
- **THEN** closing the lid suspends the machine, exactly as it did before away
  mode was ever entered

#### Scenario: Nothing is left switched on

- **WHEN** the configuration is inspected for how the lid is handled
- **THEN** no declaration changes it, and the only thing that ever suppresses
  the lid is the running mode itself

### Requirement: The operator chooses a deadline on entry

Entering away mode SHALL ask how long the machine should stay awake, offering
common durations to pick from and accepting a duration typed in. Dismissing the
question without answering SHALL leave the machine as it was and enter no mode.

The offered choices SHALL include one that holds the machine awake with no
deadline, for the case where the operator does not want a suspend at all.

#### Scenario: A duration is chosen

- **WHEN** the operator picks or types a duration
- **THEN** away mode is entered and that duration becomes the deadline

#### Scenario: The question is dismissed

- **WHEN** the operator dismisses the duration question without choosing
- **THEN** nothing is locked, no deadline is set, and the lid keeps its normal
  behaviour

#### Scenario: A duration that cannot be used is refused

- **WHEN** the operator types something that cannot be read as a duration
- **THEN** the operator is told so, nothing is locked, and no deadline is set

  A mode entered on an unusable duration would present as a blank locked screen
  with neither a deadline nor the lid suppressed -- indistinguishable from a
  working mode, and failing in the one way the mode exists to prevent. So the
  duration MUST be refused before anything is locked rather than reported after.

### Requirement: The deadline suspends the machine, and unlocking cancels it

When the chosen duration expires while away mode is still held, the machine
SHALL suspend. The lid suppression MUST have ended by then, so that the suspend
is not blocked by the mode that scheduled it.

If the operator unlocks before the deadline, the pending suspend SHALL be
cancelled, so returning to the machine never leads to it sleeping underneath the
operator at a time they can no longer see.

#### Scenario: The deadline is reached

- **WHEN** the chosen duration expires and the session is still locked
- **THEN** the machine suspends

#### Scenario: Returning cancels the suspend

- **WHEN** the operator unlocks before the duration expires
- **THEN** no suspend happens at the former deadline, and the machine stays
  awake until something else sends it to sleep

### Requirement: Reachable from the power menu

Away mode SHALL be offered as an entry in the existing power menu, alongside the
existing entries, so it is reached by the keybinding the operator already uses.
Selecting it SHALL lead directly to the duration question.

#### Scenario: The entry is present

- **WHEN** the operator opens the power menu
- **THEN** away mode appears as one of the entries, and the existing entries all
  still work as they did
