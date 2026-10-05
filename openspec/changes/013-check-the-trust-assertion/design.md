## Decisions at a glance

1. Assert from outside the configuration, by injecting a module and requiring
   evaluation to fail -- not by unit-testing the predicate.
2. A shell script, not a Nix derivation or a VM test.
3. Keep both negative controls, so the check can tell a scoped assertion from a
   blanket one.
4. `tests/` at the repository root, run by hand.

## Context

The predicate under test is the `assertions` entry in `home/agent-jail.nix`.
There is no test infrastructure in this repository and no tracked executable,
so this change also picks the convention. See `proposal.md` for why the
predicate is worth a check at all.

## Goals / Non-Goals

**Goals:** a runnable artifact that fails if the predicate stops catching a
grant route, including the two routes a previous version missed.

**Non-Goals:** testing anything else in this configuration, and verifying the
jail's containment itself, which needs a VM and belongs with the change that
already plans one.

## Decisions

**Inject a module; do not unit-test the predicate.** The predicate is inline in
the assertion, so unit-testing it would first require extracting it somewhere
importable. That refactor would buy a faster check that tests less: the route
that actually hid -- group membership granted from the group's side -- lives in
the interaction between the predicate and this configuration's real group
declarations, which an extracted function called with synthetic arguments would
not exercise. Injecting a module evaluates the real configuration with one
thing changed, which is the shape of the threat: a convenience line added in
another file.

**A shell script, not a derivation or a VM test.** Each case is one
`nix-instantiate` invocation whose exit status is the assertion. A derivation
wrapping that would add a layer whose only job is to run the same command, and
a VM test would boot a machine to check something decided at evaluation time.
The script is what the thing being tested actually needs.

**Keep the negative controls.** Two cases must *pass*: an unrelated trusted
user, and a group membership whose group is not trusted. Without them the
check cannot distinguish the scoped assertion this project chose from a blanket
`trusted-users == [ "root" ]`, which was rejected because it would block a
legitimate remote builder and then be deleted wholesale. A test that only
proves failures would call both correct.

**`tests/` at the root, run by hand.** It is the obvious place for a reader to
look, and the script is the thing that carries this decision: without it, the
only record that the predicate was ever checked is prose in an archived change.
Running it by hand rather than from a hook or CI matches how this repository is
worked on -- rebuilds are deliberate and rare -- and nothing here has a hook
convention to join.

## Risks / Trade-offs

- Each case is a full system evaluation of the real configuration, so a run is
  about a minute warm and longer cold -- not seconds. Acceptable for something
  run when the predicate is touched, not on every save. Evaluating
  `config.assertions` alone would be several times faster, and is rejected: it
  would re-implement from outside the enforcement path the check exists to
  test.
- The check can only cover routes the configuration can express. A group
  granted outside this configuration, or a trusted-user line in free-form Nix
  options, stays uncovered -- both are already named as accepted gaps in the
  change that introduced the assertion, and this script does not change that.
- A script run by hand is a check someone has to remember. The alternative is a
  hook, which this repository does not have and which would be a larger
  decision than the check itself.
