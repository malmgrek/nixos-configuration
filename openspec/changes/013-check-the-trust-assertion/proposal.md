## Why

`home/agent-jail.nix` holds the only logic here whose wrongness would be
silent: the predicate deciding whether the operator has become a trusted user
of the Nix daemon. The rest of this configuration is declarative, and the few
conditionals elsewhere announce their own failure -- wrong DPI, no audio. This
one looks identical whether it works or not.

It has already been wrong once: a value naming several users in one
whitespace-separated string passed the assertion. That survived three review
rounds and a task whose whole purpose was proving the assertion fires, and was
caught by reading `nix.conf(5)` rather than by any check. The proof was a
one-time manual act, so whoever touches the predicate next inherits nothing.

## What Changes

- A script asserts the predicate from outside, by evaluating this
  configuration with an extra module that grants the trust by one route, and
  requiring the evaluation to fail.
- It covers every route the configuration can express -- the user named
  directly, group membership from either side, the appending setting, and both
  string forms -- plus the negative controls that keep the assertion from being
  a blanket rule: an unrelated trusted user, and a group membership whose group
  is not trusted.
- Being the first tracked executable here, it also settles where such a thing
  lives and how it runs.

## Capabilities

No capability's behaviour changes. This checks behaviour `agent-jail` already
specifies, and this project has already settled that how something is verified
is guidance rather than a requirement. `.openspec.yaml` sets
`skip_specs: true`.

## Impact

One new script and one new directory. No module, option or spec change, and
nothing a rebuild would notice. Out of scope: VM-based containment checks for
the jail, checks of the other conditionals here, and wiring this into a hook
or CI.
