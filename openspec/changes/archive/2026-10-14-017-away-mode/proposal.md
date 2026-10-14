## Why

Leaving agent sessions running while away means leaving the laptop awake, and
the only lock this configuration offers runs animated screensaver modules on a
powered display. Closing the lid suspends the machine and pauses every session,
so the lid is left ajar and the display is left drawing graphics for nobody.
There is also no way to say "stay up for two more hours, then sleep" -- the
choice is between awake indefinitely and asleep now.

## What Changes

- A new lock mode that blanks the display and powers it down immediately instead
  of running a screensaver, and asks for the password on the next key or pointer
  event exactly as the existing lock does.
- While that mode is held, closing the lid no longer suspends the machine, so
  sessions keep running with the lid shut.
- Entering the mode asks how long to stay up. When that time expires the machine
  suspends on its own. Unlocking first cancels the pending suspend.
- The power menu gains this as one more entry, so the whole thing is reachable
  from the existing keybinding.

## Capabilities

### New Capabilities
- `away-mode`: hold the machine awake, locked and drawing as little as possible
  for a chosen length of time, then suspend.

### Modified Capabilities

None. The existing lock, its idle timer and its screensaver are untouched and
stay the default; this is a second mode alongside them.

## Impact

`i3.nix` gains two wrapper scripts and one entry in the command set that
`utils/rofi-power-menu.nix` already takes; `utils/rofi-power-menu.nix` gains the
matching menu option. No new package: `xsecurelock`, `rofi`, `coreutils` and
systemd's inhibit tooling are all present. No NixOS option changes, so lid
behaviour outside this mode is exactly what it is today.

## Out of scope

- `services.logind` lid settings. The inhibit lasts only as long as the mode, so
  nothing persistent is declared and nothing can be left switched on by mistake.
- Thermal policy. Cooling is handled by firmware and the kernel regardless of
  lid or lock state, and `thermald` is a system daemon rather than something a
  mode can switch.
- Deferring the suspend because a session is still working. The timer is a
  deadline the operator chose, not a guess about the workload.
