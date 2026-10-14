## Context

`options.nix` declares `hidpiHacks.enable` and `customParams.dpi` and gates one
`config` block on the flag. Six files read the flag, each choosing between two
hard-coded values. See proposal.md for why that pair cannot stay.

Two things read a density and they are not the same thing. The X server's
reported resolution, set by `services.xserver.dpi`, is what toolkits sizing fonts
in points off the display read. The `Xft.dpi` X resource is what GTK, Qt, Firefox
and winit read, and when it is absent those fall back to 96 while the others
compute from the mode. Nixpkgs sets only the first -- it passes `-dpi` to the
server and nothing else -- so the second has to be declared here.

## Decisions

- `null` dpi means "declare nothing", so one option carries both the density and
  whether to pin it.
- The gate covers the X session only; the tty and boot menu are not its business.
- The value pins rather than raises: this host declares `96`.
- `Xft.dpi` is merged in `displayManager.sessionCommands`.
- Point-valued font sizes become single-valued.
- Everything that is not the density keeps the value it evaluates to today.

**The option pins a number; it does not enable scaling.** This is the decision
the rest follow from. The problem is not that the desktop is too small -- the
operator already solves that by lowering the panel's resolution -- it is that one
family of toolkits tracks the mode while the other does not, so the two drift
apart whenever the mode changes. Pinning both reads to one value removes the
drift without taking a position on how large anything should be. 96 is therefore
not a neutral placeholder: it is the value the stable half has been rendering at
for years, so choosing it is what makes "nothing but the pinning changes" true.

In the built system this makes `services.xserver.dpi` and the `Xft.dpi` merge
appear together, keyed on one value -- grep `customParams.dpi` and every consumer
is in the list. Remove `options.nix` and both reads revert to deriving their own
numbers; nothing is left half-pinned.

**`Xft.dpi` goes in `sessionCommands` because that is the one place that runs
after `~/.Xresources` and before the window manager.** The generated xsession
script merges `~/.Xresources` first, then inlines `sessionCommands`, then starts
the session, so the number set here wins over anything Home Manager wrote and is
in the database before the first client starts. `xresources.properties` through
Home Manager loses that ordering: it is merged earlier, so it would be the thing
being overridden. Without this line GTK and Firefox keep deriving 96 by accident
rather than by declaration, which is the same appearance and none of the
guarantee.

**Points scale, so the branches were correcting for an unpinned density.** Once
the density is fixed, `9.0` is one physical size, and the second value in
`home/alacritty.nix` and `home/doom-emacs.nix` has nothing to select between.
Deleting it is the fix rather than a simplification of it.

**Integer scaling is dropped rather than kept alongside.** `GDK_SCALE=2` with
`GDK_DPI_SCALE=0.5` scales GTK geometry by two and undoes the text half, is only
expressible at integer factors, and would multiply with a pinned `Xft.dpi`.
`_JAVA_OPTIONS` goes for the reason its own comment gave -- the JDK reads the
server dpi since Java 9 -- and the XTerm override goes because
`desktopManager.xterm.enable` is `false`.

**The tty and boot-menu settings leave this change entirely.** They were in the
old block and the obvious move was to keep them inside the new gate, which is
wrong: they are about the panel's pixel count, which no X setting changes, so
they follow from neither the density's value nor its presence. Keeping them would
also have broken the change's own premise -- the flag they were gated on is
`false` today, so a gate that is true at 96 switches on a boot mode and an initrd
console font that have been off for years, which is a visible change at boot that
pinning a density has no business making. Conditioning them on `dpi > 96` was the
other option and encodes the same confusion more quietly. A legible tty on a
dense panel is a real thing to want and a separate change, keyed on the panel
rather than on X.

**`rofi` is passed the number explicitly rather than letting it detect.** Its
`-dpi 0` auto-detects from the X11 screen size -- not from `Xft.dpi` -- which is
exactly the per-mode derivation being eliminated, so detection would leave rofi
the one client still drifting. `0` is kept for the `null` case, where drifting
with the mode is what every other client does too.

## Risks / Trade-offs

- X11 has one global dpi and no per-output override, so a value above 96 would be
  wrong for any monitor that is not the dense one. → Accepted and stated in the
  option's description, because the fix is not available in an X11
  configuration: it is Wayland. At 96 the limitation is not felt, which is part
  of why 96 is the value chosen now.
- The laptop panel is driven below its native resolution by hand, so its text is
  resampled and soft. → Accepted: it is the operator's existing practice and
  predates this change, which neither introduces nor removes it. Raising the
  density to run the panel natively is the alternative and is deliberately a
  later change, because it makes the external monitor wrong and so needs a
  mechanism for it.
- `rofi` and `dunst` will render slightly differently than today on the native
  panel, because both currently derive density from the mode and will now be
  pinned. → Accepted as the point of the change rather than a cost of it; the
  verification tasks look at them specifically.
- `dunst`'s notification geometry stays the single hard-coded pixel size it
  evaluates to today instead of being computed from the density. → Accepted: it
  is correct at 96 and the computation has no second value to choose between
  until a density above 96 is wanted, which is out of scope. It is named here so
  that raising the density knows to come back for it.
- `sessionCommands` is `types.lines`, which concatenates normal definitions, so
  the merge is not wrapped in `mkDefault`: that priority loses outright to any
  normal definition rather than appending, which would drop the `Xft.dpi` line
  with no error the day a second module defines the option. → Not a limitation
  but a trap declined; the old XTerm line had the same shape and it is not
  inherited.
- Adjusting the density takes effect on the next X session, and running
  applications never pick it up. → Commented at the declaration rather than
  worked around; a session restart is the normal cost of changing a display
  setting.
