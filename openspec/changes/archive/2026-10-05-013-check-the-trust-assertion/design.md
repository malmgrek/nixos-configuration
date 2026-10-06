## Decisions at a glance

1. Assert from outside the configuration, by injecting a module and requiring
   that assertion to fail -- not by unit-testing the predicate.
2. A Nix expression evaluated by hand, not a shell script, a derivation or a
   VM test.
3. Keep both negative controls, so the check can tell a scoped assertion from a
   blanket one.
4. `tests/` at the repository root, run by hand.

## Context

The predicate under test is the `assertions` entry in `home/agent-jail.nix`.
There is no test infrastructure in this repository at all, so this change also
picks the convention. See `proposal.md` for why the predicate is worth a check
at all.

## Goals / Non-Goals

**Goals:** a runnable artifact that reports false for any grant route the
predicate stops catching, including the two routes a previous version missed,
and that signals that failure through the exit status of the invocation it
documents.

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

**A Nix expression, not a shell script, a derivation or a VM test.** The thing
under test is decided at evaluation time, so the check is an evaluation: one
file whose every attribute must be true. A derivation would add a layer whose
only job is to run that evaluation, and a VM would boot a machine to observe
something no machine has to run. A shell script was written first and replaced:
it drove `nix-instantiate` once per case and read exit statuses, which cost
eight full system instantiations and some ninety lines of bash to express what
twelve lines of Nix say directly in a repository that is otherwise
declarative.

**Keep the negative controls.** Two cases must *pass*: an unrelated trusted
user, and a group membership whose group is not trusted. Without them the
check cannot distinguish the scoped assertion this project chose from a blanket
`trusted-users == [ "root" ]`, which was rejected because it would block a
legitimate remote builder and then be deleted wholesale. A test that only
proves failures would call both correct.

**`tests/` at the root, run by hand.** It is the obvious place for a reader to
look, and the file is the thing that carries this decision: without it, the
only record that the predicate was ever checked is prose in an archived change.
Running it by hand rather than from a hook or CI matches how this repository is
worked on -- rebuilds are deliberate and rare -- and nothing here has a hook
convention to join.

## Risks / Trade-offs

- Each case evaluates the real configuration, so a run is about twelve seconds
  warm and longer cold. Acceptable for something run when the predicate is
  touched, not on every save.
- The check reads `config.assertions` rather than forcing the evaluation to
  throw, which means it mirrors one `filter` of what the system's own assertion
  check does and stops one step short of the main spec's wording, "the
  configuration MUST fail to evaluate". Accepted: forcing the throw costs a
  full system instantiation per case for the last link in a chain the module
  system owns, and the message match pins the failure to this assertion rather
  than to the mechanism around it. The step not covered is that a false
  assertion aborts a build.
- Failure is signalled by a `false` attribute, not by the evaluator's exit
  status, which is zero either way. The documented invocation greps for `false`
  to turn that into an exit status. Accepted rather than fixed in the
  expression: an `assert` wrapping the results would abort on the first false
  attribute and hide which of the others also failed, and the whole point of
  eight named cases is to see all of them at once.
- The check can only cover routes the configuration can express. A group
  granted outside this configuration, or a trusted-user line in free-form Nix
  options, stays uncovered -- both are already named as accepted gaps in the
  change that introduced the assertion, and this check does not change that.
- A check run by hand is one someone has to remember. The alternative is a
  hook, which this repository does not have and which would be a larger
  decision than the check itself.
