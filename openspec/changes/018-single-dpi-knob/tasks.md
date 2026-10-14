## 1. One option

- [x] 1.1 In `options.nix`, remove `hidpiHacks.enable`, give `customParams.dpi`
  the default `null`, and gate the `config` block on `dpi != null`. Write the
  option's description: that the value is pinned rather than scaled, why pinning
  is the point, and the one-global-dpi limitation. Evaluation is the real check
  here -- any file still reading the removed option fails to evaluate.
  Validation: `nix-instantiate '<nixpkgs/nixos>' -A system -I nixos-config=./hosts/spyridon`

- [x] 1.2 In `hosts/spyridon/default.nix`, drop `hidpiHacks.enable` and change
  `dpi` from `150` to `96` -- the value the stable half of the toolkits already
  renders at, which is what makes the rest of this change appearance-neutral.
  The check must report `96`, where today it reports `null`.
  Validation: `nix-instantiate --eval --strict '<nixpkgs/nixos>' -A config.services.xserver.dpi -I nixos-config=./hosts/spyridon`

## 2. The pinning

- [x] 2.1 In `options.nix`, replace the `environment.variables` block and the
  XTerm `sessionCommands` with a `sessionCommands` that merges `Xft.dpi` from
  `customParams.dpi`, keeping `services.xserver.dpi`. Comment which toolkits read
  which of the two, and that the value lands on the next X session rather than
  the next boot.
  Validation: `nix-instantiate --eval --strict '<nixpkgs/nixos>' -A config.services.xserver.displayManager.sessionCommands -I nixos-config=./hosts/spyridon | grep -F 'Xft.dpi: 96'`

- [x] 2.2 In `options.nix`, do not carry the console font, `earlySetup` or the
  boot-menu mode into the new block -- drop them. They were gated on a flag that
  is `false`, so they are inert today, and a gate that is true at 96 would switch
  them on: a changed boot menu and an initrd console font, from a change that
  promises to alter nothing but the pinning. Comment that their absence is
  deliberate. The check asserts they are still inert: `earlySetup` must report
  `false`, as it does at upstream default.
  Validation: `nix-instantiate --eval --strict '<nixpkgs/nixos>' -A config.console.earlySetup -I nixos-config=./hosts/spyridon`

## 3. Point-valued font sizes

- [x] 3.1 In `home/alacritty.nix`, replace the two-valued font size with the
  single value, commented as points scaled by the pinned density. The real bug
  this catches is keeping the HiDPI branch's `6.0`, so the check asserts the
  surviving value: it must still be `9`.
  Validation: `nix-instantiate --eval --strict '<nixpkgs/nixos>' -A config.home-manager.users.malmgrek.programs.alacritty.settings.font.size -I nixos-config=./hosts/spyridon`

- [x] 3.2 In `home/doom-emacs.nix`, replace the two-valued `font-spec` with the
  single value and the same comment. The substitution happens in a derivation, so
  the narrowest check is the source.
  Validation: `grep -n 'font-spec :family "monospace" :size 10.5' home/doom-emacs.nix`

## 4. Call sites that read the removed flag

- [x] 4.1 In `home/xsession.nix`, delete the `home.pointerCursor.size` line
  rather than computing one. It is `mkIf hidpiHacks.enable`, which is `false`, so
  the cursor is already Home Manager's default of 32 and deleting the line is
  what preserves that. Replace the file's header comment, which describes the
  arrangement being removed, with one saying why cursor theming lives here rather
  than in `options.nix`.
  Validation: `nix-instantiate --eval --strict '<nixpkgs/nixos>' -A config.home-manager.users.malmgrek.home.pointerCursor.size -I nixos-config=./hosts/spyridon`

- [x] 4.2 In `i3.nix`, switch the `rofi -dpi` argument from the removed flag to
  `dpi != null`, keeping `0` for the null case. Pass the number rather than
  letting rofi detect: its `-dpi 0` reads the X11 screen size, not `Xft.dpi`, so
  detection would leave rofi the one client still following the mode.
  Validation: `grep -n 'customParams.dpi' i3.nix`

- [x] 4.3 In `i3.nix`, replace the branching `dunst` geometry with the single
  value the `false` branch selects today, so the generated `dunstrc` is unchanged
  by this change. Comment that the value is pixels and is therefore tied to the
  declared density, which is why it is a constant and not a branch.
  Validation: `nix-instantiate --eval --strict '<nixpkgs/nixos>' -A config.environment.etc.dunstrc.text -I nixos-config=./hosts/spyridon | grep -F '300x5-30+24'`

## 5. Verification (no review)

Waived by the operator on 2026-10-14. Every task here has `Validation: none` and
is an observation made at the machine, so a reviewer reading the diff could not
check any of them; the confirmations recorded under each task are the evidence.
The waiver covers 5.1 and 5.2, marked below, and 5.3 when it is done.

These need a logged-in X session, so they cannot be checked by evaluation. A
`nixos-rebuild switch` does not apply them, and neither does logging out and back
in: `restartIfChanged = false` on the display-manager service (nixpkgs
`services/display-managers/generic.nix`) keeps lightdm running with the session
wrapper it read at startup, so a new wrapper is picked up only after
`systemctl restart display-manager` or a reboot. Restarting ends the X session.

- [x] 5.1 Confirm the declared density reaches the session:
  `xrdb -query | grep Xft.dpi` reports 96.

  Confirmed by the operator on 2026-10-14, in a session started by
  `systemctl restart display-manager`. The restart is what makes the reading
  meaningful: a value merged by hand while diagnosing did not survive it, so 96
  here can only have come from the session wrapper.

  The X server's own reported density is deliberately not checked. `xdpyinfo` is
  not installed, `xrandr` does not print the screen's physical size, and neither
  the process table nor the Xorg log is reachable from a confined session on this
  machine. Accepted because task 1.2 evaluates `services.xserver.dpi` to 96 and
  nixpkgs passes `-dpi` to the server for any non-null value unconditionally
  (`services/x11/xserver.nix`), leaving no step between the two that this
  repository controls.

- [x] 5.2 The acceptance test for the whole change. Change the laptop resolution
  with `arandr` as usual and confirm that Alacritty's and Firefox's apparent
  sizes change by the same factor, rather than the terminal font growing relative
  to everything else. Re-check `xrdb -query | grep Xft.dpi` at the lowered mode
  and confirm it still reports 96, which is the thing that was previously not
  true.

  Confirmed by the operator on 2026-10-14: the two applications' text was matched
  in scale at the native mode, both changed by the same factor on dropping to
  1920x1080, and the resource still read 96 afterwards. That last reading is what
  distinguishes the fix from a coincidence -- before this change the density was
  re-derived from each new mode, which is what moved the terminal font relative
  to everything else.

- [ ] 5.3 Confirm the appearance-neutral claim on the external monitor: at its
  usual resolution the desktop looks as it did before this change. `rofi` and
  `dunst` are the two to look at specifically -- both previously derived their
  density from the mode and are now pinned, so they are where a difference would
  show.

  Deferred on 2026-10-14: the monitor is not available for several days. Nothing
  depends on the answer -- a difference here would be cosmetic and fixable at
  rofi's or dunst's own call site without touching the pinning -- so sections 1
  to 4 and tasks 5.1 and 5.2 stand as verified and this is the only thing between
  the change and archiving.

## Unreconciled

- `home/xsession.nix` lost `lib` from its module arguments. Task 4.1 deleted the
  `lib.mkIf` that was its only user, so the argument became dead, but the task
  named only the size line and the comment. Visual only.
- Inline comments across the five touched files were shortened, and the one
  claiming a new X session suffices was dropped -- it predated finding that the
  display manager has to be restarted. Visual only.
