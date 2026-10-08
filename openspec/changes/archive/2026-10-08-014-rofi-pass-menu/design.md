## Context

See proposal.md — Why. The rofi-over-terminal choice and its rationale are
settled there; this document covers the rest.

Everything the wrapper needs is already declared: `pass` in `home/default.nix`,
`rofi` and `xclip` in `i3.nix` and `common.nix`, a graphical pinentry from the
`programs.gnupg.agent` default, and fuzzy matching plus vim-style row keys in
`config/rofi/config.rasi`.

## Goals / Non-Goals

**Goals:**
- One keypress from any focused window to a password on the clipboard.
- Behave like the four `rofi-*` wrappers already in `i3.nix`, so a reader who
  understands one understands this.

**Non-Goals:**
- Any pass operation other than copying: no insert, edit, generate, OTP, or
  field selection.
- Configurability. No options, no config file; the one theme and the one
  keybinding are the ones in this repository.

## Decisions

1. Inline `writeScriptBin` let-binding in `i3.nix`, not a file under `utils/`.
2. Build the rofi invocation from the existing `rofiCmd` let-binding.
3. Hardcode `${pkgs.pass}/bin/pass`; do not resolve `pass` from `PATH`.
4. List entries from the filesystem with `find` and `sed`, not from `pass ls`.
5. Selecting nothing is a no-op; a failure is reported through `notify-send`.
6. Clipboard lifetime is whatever `pass -c` does. No custom clearing.

### 1. Inline, not `utils/`

`rofi-power-menu` lives in `utils/` because it is a 45-line dispatch table with
six branches worth isolating. `rofi-app-menu`, `rofi-dmenu` and
`rofi-window-menu` are three-line let-bindings in `i3.nix`. This wrapper is a
four-line pipeline, so it belongs with the latter group; a file under `utils/`
would imply more substance than there is.

### 2. Reuse `rofiCmd`

`rofiCmd` already carries `-theme /etc/rofi/config.rasi` and the `-dpi` value
derived from `hidpiHacks.enable`. Calling `${pkgs.rofi}/bin/rofi` directly would
compile and run, and would silently render at the wrong scale on a HiDPI host —
a defect invisible to every check that does not involve a display. Going through
`rofiCmd` makes that class of mistake unavailable rather than merely avoided.

### 3. Hardcoded `pass` path

Every tool in `i3.nix` is referenced by store path (`${pkgs.xsecurelock}/bin/…`,
`${pkgs.brightnessctl}/bin/…`), and this follows. It also matters here
specifically: i3 spawns the wrapper with the X session's environment, not a
login shell's, so depending on `PATH` would couple a desktop keybinding to
whatever the user profile happens to export.

`pkgs.pass` evaluates to the same store path as the `pass` in
`home/default.nix`, so nothing is duplicated. The accepted limitation: if that
entry is later changed to `pass.withExtensions`, the wrapper keeps referring to
the plain package. This is accepted because the wrapper uses only `pass -c`,
which no extension alters — and a future change that needs an extension here
would have to touch this line anyway.

### 4. Filesystem listing, not `pass ls`

`pass ls` renders a tree with box-drawing characters and colour, built to be
read by a person. Stripping that back into entry paths is more work, and more
fragile, than reading the names off disk. `find … -name '*.gpg'` with the prefix
and suffix trimmed yields exactly the relative paths `pass -c` accepts. The
prefix comes from `PASSWORD_STORE_DIR` where set, falling back to
`$HOME/.password-store`, which is the same precedence `pass` itself uses.

Three limitations of this listing were raised in review and left in
deliberately:

- Symlinked entries are skipped, since `find -type f` does not follow them
  while `pass` resolves them and treats them as ordinary entries. Accepted
  because the hand-run pipeline this replaces behaved the same way, so nothing
  regresses; `find -L` is the fix if aliases ever enter the store.
- Entries come out in directory-traversal order rather than sorted, so their
  order shifts as the store changes. Accepted because an entry is reached here
  by typing at a fuzzy matcher, not by its position in a list.
- A trailing slash in `PASSWORD_STORE_DIR` defeats `s|^$store/||`, leaving an
  absolute path that `pass -c` rejects — for every entry, not just some.
  Accepted because nothing in this configuration sets that variable, so the
  case is unreachable until someone sets it by hand.

### 5. Empty selection and failure reporting

Dismissing rofi prints nothing, so the selection must be tested before `pass` is
invoked — otherwise `pass -c` runs with no argument and falls through to
printing the store tree.

A process i3 spawns has nowhere to put stderr. A failing `pass` would therefore
look identical to a working one: nothing happens, no clipboard. Routing failure
to `notify-send` makes the two distinguishable. `dunst` is already started from
`config/i3/config`, so this needs no new daemon.

### 6. Clipboard lifetime

`pass -c` clears the clipboard itself after its own timeout. Reimplementing that
would mean a second timer that can disagree with the first.

## What this makes true of the built system

`environment.systemPackages` in `i3.nix` puts `rofi-pass-menu` on the system
path, so the name resolves in `/run/current-system/sw/bin` for any session, not
only under i3. The keybinding is separate: it lives in `config/i3/config`, which
`i3.nix` hands to `services.xserver.windowManager.i3.configFile`. A reader looks
for `rofi-pass-menu` — two hits in `i3.nix`, one in `config/i3/config`.

Were `i3.nix` removed from the host, both the binary and the binding would go
with it, while `pass` itself would keep working, since the store and the `pass`
package are declared in `home/default.nix` and owe nothing to this change.

## Risks / Trade-offs

- **`pinentry-gnome3` may not paint a prompt under bare i3** → It needs the gcr
  D-Bus prompter, which here comes from `services.gnome.gnome-keyring.enable` in
  `common.nix`. If the prompt fails to appear, set
  `programs.gnupg.agent.pinentryPackage = pkgs.pinentry-gtk2`, which draws
  directly and needs no session bus. This cannot be settled by evaluating the
  configuration; it needs a display, so the task that covers it says so.
  Not encountered in practice: decryption succeeded on the switched-to system, so
  the fallback stayed unused. Whether a prompt was painted or `gpg-agent`
  already held the key unlocked was not distinguished, so the fallback is kept
  on record rather than deleted.

- **The entry names are shown full-screen** → `config/rofi/config.rasi` sets
  `fullscreen: true`, so the matching entry names fill the screen while the
  picker is open. Only names are shown, never a secret, and they are already
  visible to anyone who can run `pass ls` as this user — the overlay widens who
  can read them over the operator's shoulder, not who can obtain them. Accepted
  on that basis; narrowing it would mean a second theme maintained for one
  launcher.

- **HiDPI rendering is unverifiable from a rebuild** → Shared with every other
  `rofi-*` wrapper, and mitigated by decision 2 rather than by a check.
