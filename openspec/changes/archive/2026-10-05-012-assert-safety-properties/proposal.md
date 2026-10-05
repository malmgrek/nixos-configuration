## Why

Two safety properties hold by accident of a default, or by someone remembering
to check. The jail binds the Nix daemon socket and relies on the caller not
being a trusted user of it -- otherwise a session could make the root daemon
act on its behalf, which Nix documents as root-equivalent. That premise is
asserted nowhere: it is NixOS's default, and the operator is in `wheel`, so
the usual `trusted-users = [ "@wheel" ]` would remove it silently. Separately,
the status bar renders the WiFi SSID, which is why a committed screenshot once
leaked it; the only control is a comment asking a human to check the bar
before committing one.

## What Changes

- The configuration declares its trusted-user set explicitly, so the jail's
  dependency on it is stated where a future edit meets it.
- The status bar shows the SSID only after a click, so a screenshot of it at
  rest cannot carry the field.
- The spec regains a limitation lost when it was imported: agent-authored
  hooks are run later by the operator, outside the jail.
- Housekeeping: `openspec/config.yaml` and `AGENTS.md` shed their template
  scaffolding; the stale `010-publishable-history` branch goes.

## Capabilities

### Modified Capabilities
- `agent-jail`: the requirement covering dependency resolution through the Nix
  daemon states the trusted-user condition as something the capability depends
  on. It becomes something the configuration asserts, with a scenario that the
  daemon refuses settings it restricts to trusted callers. A second requirement
  is added, recording that the capability does not constrain what the operator
  later runs.

## Impact

`openspec/config.yaml`, `AGENTS.md`, `config/i3status-rs/config.toml`,
`home/agent-jail.nix` (the declaration and its assertion; the jail's own
`bwrap` invocation is untouched), one deleted branch. Out of scope: the
containment checks `AGENTS.md` describes, other status-bar fields, and further
narrowing what the jail binds.
