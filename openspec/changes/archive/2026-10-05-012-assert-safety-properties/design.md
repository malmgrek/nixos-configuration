## Decisions at a glance

1. Declare the trusted-user set in `home/agent-jail.nix`, beside the thing that
   depends on it, not in `common.nix` with the other system settings.
2. Back the declaration with an assertion, because a declaration alone protects
   nothing: `trusted-users` is a list option and NixOS merges definitions.
3. Scope the assertion to the user the jail runs as, not to the whole set, so an
   unrelated trusted user stays possible without editing this capability.
4. Put the SSID behind a click rather than removing it, or adding another
   check at screenshot time.
5. Fill the template prompts with the narrowest real command this project has.

## Context

The configuration declares no `nix.*` settings at all today, so the trusted-user
set is whatever NixOS defaults to. `home/agent-jail.nix` is a NixOS module that
happens to configure a home-manager user, so it can declare system settings
itself. See `proposal.md` for why this change exists and
`openspec/specs/agent-jail/spec.md` for the capability it modifies.

## Goals / Non-Goals

**Goals:** make both properties hold by construction -- one checked at build
time, one by the field being absent from the bar's resting state -- rather than
by a default nobody stated and a comment nobody has to read.

**Non-Goals:** narrowing anything else the jail binds, and writing the
containment checks `AGENTS.md` now describes. Both are their own work.

## Decisions

**Declare it beside the dependency, not with the other system settings.** The
audit's finding was that this is a two-file property: a reviewer of
`home/agent-jail.nix` sees the daemon socket bound and cannot see what makes
that safe, because the premise lives in a NixOS default. Putting the
declaration in `common.nix` would leave it a two-file property with one more
file in it. In the jail module, the bind and the premise are on the same screen.
A side effect worth having: the module's import is the capability's off switch,
so removing the jail removes the declaration too -- and the default it falls
back to is already the safe value, so nothing is left dangling.

**A declaration alone would be decoration.** `nix.settings.trusted-users` is a
list option, and NixOS merges list definitions rather than letting a later one
win or conflict. Declaring `[ "root" ]` here and adding `[ "@wheel" ]` in
another module produces `[ "root" "@wheel" ]` with no warning, which is exactly
the silent outcome this change exists to prevent -- the declaration would read
as a guard while guarding nothing. An `assertions` entry is what makes the
requirement real: the grant then fails the build and prints why.

**Assert about the jailed user, not about the whole set.** Requiring the set to
equal `[ "root" ]` would also block a future unrelated trusted user -- a remote
builder account, say -- and would be edited away wholesale the first time
someone needed one, taking the protection with it. The assertion instead fails
when the user the jail runs as becomes trusted, directly or through a group it
belongs to by either route -- the user's own group list or a group's member
list. It also fails when the trust arrives through a setting that appends to
the trusted set rather than replacing it, which is the first thing anyone
reaches for precisely because it does not clobber a declared list. Those are
the grants that turn the bound daemon socket into root-equivalent access, and
they are the only ones this capability has an opinion about. Both settings are
compared as words rather than as list elements, because nix.conf splits these
values on whitespace and a single string may therefore name several users.

**The assertion's message carries the reasoning, not just the rule.** Anyone who
trips it is mid-task and trying to make a flake or a substituter work. A message
that only says "not allowed" invites deleting the assertion; one that says the
jail binds the daemon socket and relies on this gives them the choice the spec
says they are making.

**Say in the spec's Purpose what the capability is not.** The requirements were
imported from a shipped module and cannot bound what the operator later runs,
so a reader could reasonably take them for a hardened sandbox contract. A
paragraph in the main spec's Purpose says instead that this is one machine's
boundary, verified by observation, and not a general sandboxing guarantee. It
goes in Purpose rather than in a requirement because it qualifies the whole
capability, and it is written directly rather than through this change's delta
because a delta carries requirements and not prose sections.

**Put the SSID behind a click.** Another screenshot-time check is what
already failed: the control was a comment asking a human to look at the bar,
and a screenshot was committed anyway. Deleting the field would fix that but
lose information the operator wants. The net block's `format_alt` toggles on
every left click, so the field lives there instead: the bar at rest cannot be
captured with it, and a freshly started bar is always at rest, which makes the
safe form the default rather than something to remember.

**Fill the template prompts with the narrowest real command.** The two unfilled
`PROJECT` prompts ask for what a design must state to be checkable here and for
the narrowest validation command. The validation answer is the simpler one:
evaluating the system derivation catches a structural mistake, and
`nixos-rebuild build` catches one that only appears once something is built.
The design answer has to be two-shaped, because this repository routinely makes
changes that never reach the built system -- this very section is one -- so a
rule demanding a built-system effect from every decision would declare its own
change undesigned. It asks for that effect where there is one, and for which
file carries the decision where there is not. Writing both down is what stops
the next change inventing its own convention.

## Risks / Trade-offs

- The assertion fires at evaluation time, so a legitimate need to trust the user
  becomes a build failure rather than a surprise. That is the intent, but it
  will land on someone unprepared; the message is the mitigation.
- Group membership is resolved by reading the configured groups, so a group
  granted outside this configuration is invisible to the assertion. A session
  whose trust arrives that way is not caught, and nothing here claims otherwise.
- A trusted-user line buried in free-form Nix options reaches the daemon
  without touching either setting the assertion reads. Guarding it would mean
  pattern-matching a free-form string, which is worse than the hole and would
  rot; it is left uncaught deliberately and named here because this is where a
  future editor meets it.
- The click toggle is sticky: revealing the field and forgetting leaves it
  visible until clicked again, so a screenshot taken then still carries it.
  Accepted, because the default is the safe state and a restart returns to it;
  the README reminder covers the rest.
- The two properties ship with unequal protection. The trust premise has an
  eval-time assertion and a spec requirement; the status-bar field has a
  comment, which is what this change objected to in the first place. Nothing
  stops a future edit moving `$ssid` back into `format`, because no capability
  covers the desktop and the grep that checks it lives in this change's task
  list, which archives. Accepted rather than fixed: inventing a desktop
  capability for one field would cost more than it guards.
- The declaration merges with the nixpkgs default, so the generated nix.conf
  reads the safe value twice. Harmless, and the comment beside the declaration
  says so, but the generated file does change.
- The remaining on-screen paths to the network name are not the status bar: the
  tray applet shows it on hover, and connection notifications render it
  briefly. Both are local to the operator's screen and reach a published
  artifact only through a screenshot, which is what the README reminder is for.
  Out of scope here.
- Deleting the stale branch discards a ref and not work: its tip is an
  ancestor of the default branch, so those commits stay in the mainline history
  and need neither the archive nor the backup to be recoverable.
