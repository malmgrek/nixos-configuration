## 1. Shared prompt appearance

- [x] 1.1 In `i3.nix`, extract the prompt style, font, background colour and
  composite-obscurer lines out of `xsecurelock-xscreensaver` into one `let`
  binding, and have that wrapper include it so its behaviour is unchanged. The
  comment explaining the obscurer workaround moves with the lines it explains.
  Validation: `nix-instantiate '<nixpkgs/nixos>' -A system -I nixos-config=./hosts/spyridon`

## 2. The blank locker

- [x] 2.1 In `i3.nix`, add an `xsecurelock-blank` wrapper that includes the
  shared binding from 1.1 and sets the blank saver module, a zero blank delay
  and the display's off state as the blank state, then add it to
  `environment.systemPackages` beside the existing wrappers.
  Validation: `nix-instantiate '<nixpkgs/nixos>' -A system -I nixos-config=./hosts/spyridon`

- [x] 2.2 Confirm the wrapper locks, blanks and powers the display down with no
  animation, and that a key press raises the same prompt as the existing lock.
  Needs a display, so it cannot be checked by evaluation: run
  `xsecurelock-blank` from a terminal.

  Confirmed by the operator on 2026-10-14. A zero blank timeout is documented
  upstream as nonsensical because key-release events wake the screen, so the
  blanking was the specific thing watched: one wake-then-blank cycle on entry is
  expected, repeated blanking and unblanking would not be, and raising the blank
  timeout to one second is the remedy if it ever appears.
  Validation: none

## 3. Away mode

- [x] 3.1 In `i3.nix`, add an `away-mode` wrapper that asks for a duration with
  rofi -- offering common durations plus a no-deadline choice, accepting typed
  input, exiting without locking if the question is dismissed, and refusing a
  duration the timeout tool cannot parse before anything is locked -- then stops
  the X idle timer, starts the blank locker, and holds a lid-handling inhibitor
  in one foreground process that ends on whichever comes first, the locker
  exiting or the deadline. Suspend only in the deadline case, restore the idle
  timer on exit, and comment that the restored value is the one
  `config/i3/config` sets. Add it to `environment.systemPackages`.
  Validation: `nix-instantiate '<nixpkgs/nixos>' -A system -I nixos-config=./hosts/spyridon`

- [x] 3.2 In `utils/rofi-power-menu.nix`, add the away entry to the options list
  and its dispatch case, following the existing entries' shape, and pass the
  matching command in the `cmds` set `i3.nix` builds.
  Validation: `nix-instantiate '<nixpkgs/nixos>' -A system -I nixos-config=./hosts/spyridon`

## 4. Verification

Away mode hides the terminal, so these cannot be checked by running a command
and reading its output on the machine itself. Either read the output afterwards
from the terminal's scrollback, or reach the session over `ssh` from another
device, which works with the lid shut.

- [x] 4.1 Rebuild, then confirm the entry appears in the power menu and leads to
  the duration question, and that dismissing the question leaves the session
  unlocked. Needs a display and a running rofi.

  Confirmed by the operator on 2026-10-14, dismissal included -- the path that
  matters, since a mode that half-starts would lock the screen without a
  deadline or the lid held. The refusal of an unusable duration was confirmed in
  the same way, by typing one the timeout tool cannot parse and seeing the
  notification with the session still unlocked; it is checked here rather than
  under its own task because it belongs to the same prompt.
  Validation: none

- [x] 4.2 Confirm the deadline suspends and that unlocking cancels it, using a
  duration short enough to watch -- one minute for the suspend, then a second
  run unlocked before it elapses to confirm no suspend follows. Do this before
  trusting the mode with a long duration, since neither the inhibitor nor the
  suspend has been checked against a locked session on this machine.

  Confirmed by the operator on 2026-10-14, both paths. A locked session is
  therefore allowed both to hold the lid inhibitor and to suspend, which was the
  open question behind this task. The inhibitor half follows from the suspend
  rather than being observed: a refused lock makes systemd-inhibit exit without
  running its child, so reaching the deadline at all means the lock was granted.
  Validation: none

- [x] 4.3 Confirm closing the lid while the mode is held keeps the machine awake
  and a process inside the session running, and that closing the lid after the
  mode has ended suspends as before. Needs the physical lid.

  First half confirmed by behaviour on 2026-10-14: with the mode held, the lid
  read `closed` while a session on the machine kept executing commands, so it
  had not suspended. No external monitor was connected, which rules out logind
  ignoring the lid because it is docked, and no declaration in this repository
  changes lid handling -- leaving the mode's own inhibitor as the only thing
  that can have suppressed it. The inhibitor was not observed directly: a
  confined session cannot reach the system bus or the host process table.

  Second half confirmed by the operator on 2026-10-14: once the mode had ended,
  closing the lid suspended again, so the inhibitor really does release with the
  process that held it.
  Validation: none

## Unreconciled
