## Why

Two mechanisms carry display density and this configuration sets neither. GTK, Qt
and Firefox read the `Xft.dpi` resource; nothing declares it, so they fall back to
96 and have been stable for years. Alacritty and Emacs derive theirs from the
current mode, so it moves with the resolution -- hence a hand-lowered laptop
resolution giving a usable desktop with an oversized terminal font.

`hidpiHacks.enable` cannot fix that: it must agree with `customParams.dpi`, is
`false` here while the number says `150`, and never sets `Xft.dpi`. Six files
branch on it, each with its own pair of values.

## What Changes

- `customParams.dpi` becomes the only knob, and its job is to *pin* the density,
  not raise it: the server's reported value and `Xft.dpi` both come from it, so
  every toolkit reads one number that no longer follows the mode.
- This host declares `96`, what its monitors already render at, which is what
  makes the rest appearance-neutral.
- `GDK_SCALE`, `GDK_DPI_SCALE`, `_JAVA_OPTIONS` and the XTerm override go:
  integer scaling would multiply with a pinned density, and nothing runs XTerm.
- Point-valued font sizes stop branching. The tty and boot-menu settings are
  dropped rather than re-gated: inert today, and not about X.
- Everything else keeps today's value.

## Capabilities

### New Capabilities
- `display-scaling`: one pinned density every toolkit agrees on, independent of
  the current resolution.

### Modified Capabilities

None.

## Impact

Net deletion, no new package. `options.nix` loses an option and rewrites its
block; `hosts/spyridon`, `i3.nix` and three `home/` modules lose their branches.
Another host would need `dpi` set, or left at its `null` default.

## Out of scope

- Raising the density above 96, which makes the external monitor wrong and needs
  a mechanism for it. The pinning is its prerequisite either way.
- Per-monitor density: X11 has one global dpi, so that needs Wayland.
- A legible tty on a dense panel: real, but keyed on the panel, not on X.
