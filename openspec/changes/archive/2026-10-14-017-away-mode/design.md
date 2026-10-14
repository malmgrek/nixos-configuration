## Context

`i3.nix` already wraps `xsecurelock` twice -- once as the xss-lock notifier that
dims, once as the locker that runs the xscreensaver saver module -- and
`utils/rofi-power-menu.nix` is a flat dispatch table taking one shell command
per menu entry. The idle chain itself (`xset s 300 10`, then `xss-lock`) lives in
`config/i3/config`, which is a static file this repository copies rather than
generates. See proposal.md for why a second lock mode is wanted.

`xsecurelock` 1.9.0 is installed and already does everything the blank mode
needs, through three environment variables read directly by the binary:
the saver module, the delay before blanking, and the display power state to
blank into.

## Goals / Non-Goals

**Goals:**

- The mode's effects last exactly as long as the mode, including the lid
  suppression, without a cleanup step that can be skipped.
- One place decides what the password prompt looks like, so the two lock modes
  cannot drift apart visually.

**Non-Goals:**

- Measuring the power saved. The mode removes a running animation and powers the
  panel down; that it draws less is structural, and a number would only invite
  defending it.
- Reworking the existing idle chain or moving it out of the static i3 file.

## Decisions

**Blanking is configuration of the existing locker, not a new one.**
`xsecurelock` blanks and powers the display down on its own once the blank delay
is zero and the blank state is the display's off state; the saver module is set
to the blank one so nothing is drawn behind it. So the mode is a third wrapper
script beside the two in `i3.nix`, not a new program, and the auth prompt is the
same binary's prompt by construction.

**The prompt appearance moves into one shared binding.** The existing
`xsecurelock-xscreensaver` wrapper sets the prompt style, font, background colour
and the composite-obscurer workaround inline. The spec requires the two modes to
present the same prompt, so those lines become one `let` binding that both
wrappers include, and each wrapper then declares only what makes it different.
Copying them into the new wrapper was the alternative, and it is exactly the
drift the requirement exists to prevent.

**One foreground process holds the inhibitor and ends the mode.** It runs under
`systemd-inhibit --what=handle-lid-switch` and finishes on whichever comes
first: the locker exiting, or the deadline elapsing. Because the inhibitor is
that process's, its lifetime is the mode's lifetime by construction -- there is
no cleanup path that a kill can skip. The deadline case is distinguished from the
unlock case by the timeout's exit status, and only the deadline case suspends,
which is what makes unlocking cancel the suspend without a second mechanism.

A backgrounded timer with a kill on unlock was the obvious alternative and was
rejected: killing the wrapper shell orphans the inhibitor, which then holds the
lid open with nothing left to release it -- indefinitely, for the no-deadline
choice.

**Inhibiting only lid handling is what lets the deadline work.** The inhibitor
blocks logind's response to the lid, not sleep itself, so the explicit suspend at
the deadline is not blocked by the mode that scheduled it. Inhibiting sleep as
well would have required dropping the inhibitor before suspending, reintroducing
an ordering the first decision removes.

**The duration is proved usable before anything is locked.** The timeout tool
accepts one number and one suffix, so a plausible typed duration like `1h30m` is
rejected -- and a rejected duration surfaces as an ordinary non-zero status,
which is indistinguishable from the locker having exited. Running the timeout
once against a no-op first turns that into a refusal the operator sees, while the
desktop is still visible to show it on. Interpreting the status afterwards was
the alternative and cannot work: by then the screen is already blank.

**The duration question lives in the away script, not in the menu template.**
`utils/rofi-power-menu.nix` stays a flat table of entry to command; the entry's
command is the away script, which asks its own follow-up. The template keeps
having no notion of a nested menu, and a dismissed question is simply the script
exiting before it locks anything.

**`i3.nix` declares all of it.** The two new scripts are `pkgs.writeScriptBin`
derivations in its `let` block, added to `environment.systemPackages` beside the
existing wrappers, and the menu entry is one more attribute in the `cmds` set it
passes to the power-menu template. In the built system this makes two more
executables appear on `PATH` and one more line in the generated power menu --
grep `away` in `i3.nix` and in `utils/rofi-power-menu.nix`. Remove the two
attributes and the template entry and nothing else changes: no NixOS option, no
service, and the existing lock, idle timer and lid behaviour are untouched,
because the mode only ever acts while its own process is running.

## Risks / Trade-offs

- The script stops the X idle timer on entry and restores it on exit, and the
  value it restores is the one `config/i3/config` sets, so the same pair of
  numbers now lives in two files. → Accepted with a comment in the script naming
  the other place. Not stopping the timer was tried on paper and is worse: the
  idle chain would run its dimming animation on top of the blank lock, which is
  the drawing the mode exists to avoid.
- An inhibitor the session is not allowed to take would also surface as a
  non-zero status, and by then the screen is blank, so the mode would degrade to
  a plain lock with the lid live and no way to say so. → Not guarded, though it
  could be: taking and releasing the same inhibitor next to the duration guard
  would predict the real one and refuse visibly, as the duration guard does.
  Declined because the degraded outcome pauses sessions rather than losing
  anything, and because the hardware checks have since shown that a locked
  session on this machine is granted the inhibitor -- so the guard would never
  fire. Revisit only if that stops holding.
- Suspending and taking a lid inhibitor both go through polkit, which allows them
  for an active local session; a locked session stays active, so neither is
  refused. → Settled rather than assumed: the deadline was exercised with a short
  duration, and the locked session both held the inhibitor and suspended.
- The machine stays awake with the lid shut, so a session that starts compiling
  heats up behind a closed panel. → Firmware and the kernel's thermal zones
  throttle and, at the limit, shut down regardless of lid state, so this is a
  comfort and noise question rather than a safety one. `thermald` would add
  earlier, gentler throttling, but it is a system daemon and not something a
  mode can hold, so it belongs in its own change if wanted.
