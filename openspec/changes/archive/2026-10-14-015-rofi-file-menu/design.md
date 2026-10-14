## Context

See proposal.md — Why. Two facts about the current state shape everything below.

Rofi in this configuration already lists `filebrowser` and `recursivebrowser`
among its modes, and `config/rofi/config.rasi` already sets `matching: "fuzzy"`
and the vim-style row keys. Both modes default to `command: "xdg-open"` and both
accept `directory`, `cancel-returns-1` and, on the recursive one, `filter-regex`.

`xdg-open` on this machine has no chosen answers. `~/.config/mimeapps.list` is a
hand-written regular file whose only live line is the `claude-cli` scheme
handler, so every file type falls through to `mimeinfo.cache` — a generated
reverse index listing candidates alphabetically by desktop-file name, per
`XDG_DATA_DIRS` entry, first match winning.

## Goals / Non-Goals

**Goals:**
- One keypress from a focused window to a file open in a program chosen here.
- Behave like the five `rofi-*` wrappers in `i3.nix`, so one reader understands
  all six.
- Make the open step a property of the system, not of this wrapper.

**Non-Goals:**
- A file manager. No copy, move, delete, rename, previews, or bulk selection.
- Covering every mime type. Only the types a file picker actually surfaces.
- Configurability: no options, no start-directory setting.

## Decisions

1. Rofi's built-in modes, not a script, a plugin, or a terminal file manager.
2. Both modes in one wrapper, one keybinding, switched with rofi's mode keys.
3. Build the invocation from the existing `rofiCmd` let-binding.
4. Leave `command` at its `xdg-open` default; put the choice in mime defaults.
5. Declare those defaults with `xdg.mimeApps` in `home/default.nix`.
6. `gvim` for text, `mupdf` for PDF, `feh` for images, `pcmanfm` for directories.
7. Delete the stale `mimeapps.list` before switching; declare no `claude-cli` line.
8. Fix the `rofi-window-menu` shebang here rather than deferring it.
9. Rebind `C-w` to delete a word, across all six launchers.

### 1. Built-in modes

`filebrowser` gives directory-at-a-time navigation with `..` as a selectable
entry, `directories-first`, and hidden files behind `kb-delete-entry`.
`recursivebrowser` gives a flat fuzzy list under a root. Between them they are
the whole of what was wanted, so the alternatives all cost more for less:
`rofi-file-browser-extended` is a plugin needing a build and an ABI match for
toggles the built-ins now cover; `ranger` or `lf` in a dropped terminal
reintroduces the managed window 014 deliberately rejected; `fd | rofi -dmenu |
xdg-open` is a hand-rolled `recursivebrowser` with its own bugs to keep.

### 2. One wrapper, two modes

`-modi filebrowser,recursivebrowser -show filebrowser` opens on directory
browsing, and `kb-mode-next` (`Shift+Right`, `Control+Tab`) switches to the
recursive list without leaving the launcher. Two wrappers on two keys would mean
two bindings to remember and no way to change your mind mid-search, which is
exactly when the choice between "browse" and "find" actually gets made. Neither
mode key collides with the `Control+j`/`Control+k` row keys in `config.rasi`.

### 3. Reuse `rofiCmd`

Identical to 014's reasoning: `rofiCmd` carries `-theme /etc/rofi/config.rasi`
and the `-dpi` value derived from `hidpiHacks.enable`. Calling
`${pkgs.rofi}/bin/rofi` directly would evaluate, build, and render at the wrong
scale on a HiDPI host — a defect no check without a display can see.

### 4. `xdg-open`, not a per-wrapper `command`

Both modes accept a `command`, so the wrapper could name programs itself. It
should not. The same wrong answers that make this change necessary also affect
Chromium's downloads, mail attachments, and `xdg-open` from a shell; fixing them
at the mime layer fixes all of those at once, while a `command` flag would fix
only the launcher and leave a second, divergent set of associations to maintain.

### 5. `xdg.mimeApps`, not a hand-written file

The current file is untracked, unreproducible, and already wrong. Declaring the
associations puts them in the repository, where the reason for each pick can be
read next to it.

### 6. The picks

- **`gvim` for `text/plain` and the source-code types.** `programs.vim.enable`
  in `home/vim.nix` pulls `vim-full` — a GTK3 GUI build — and the `gvim` wrapper
  execs it with the generated vimrc, so `config/vim/extra.vimrc` and the declared
  plugins apply. `Terminal=false`, so no terminal is spawned. It loses today only
  because `emacs.desktop` sorts before `gvim.desktop`, and that Emacs entry is
  `Exec=emacs %F`: a fresh GUI instance per file rather than the running one.
- **`text/markdown` listed explicitly.** `gvim.desktop`'s own `MimeType=` omits
  it, which is why Okular wins markdown now. A `[Default Applications]` line
  overrides regardless of what the desktop file claims, so this type has to be
  named by hand; it does not follow from `text/plain`.
- **`mupdf` for PDF.** `common.nix` carries four PDF readers and its own comments
  rank them for this purpose: `mupdf` is the "vim-esque lightweight" one, which
  is what a picker's open step wants. `okular` stays the one to launch by name
  for an annotating session; neither it nor `evince` nor `xournalpp` is removed.
- **`feh` for images.** Declared in `common.nix` as "simplest image viewer" and
  currently never selected, because `chromium-browser.desktop` is the only
  `image/png` candidate in the home profile and the home profile outranks the
  system one.
- **`pcmanfm` for `inode/directory`.** Already the winner, and already right, so
  it is declared to pin it rather than to change it. It fires only from
  `recursivebrowser`; `filebrowser` descends into directories itself.
- **Twelve text types, not one.** `xdg-open` resolves a default without walking
  shared-mime-info's subclass chain, so `text/x-python` does not inherit
  `text/plain`'s entry: declaring `text/plain` alone would leave `.py`, `.json`,
  `.yaml`, `.toml`, `.css`, `.lua` and `.el` still opening nothing. Each type
  this repository actually contains is therefore named. Absent on purpose:
  `.nix` and `.vimrc`, which arrive as `text/plain`, and `.sh`, which arrives as
  the `application/x-shellscript` that `text/x-sh` aliases.

### 7. The stale file, and the `claude-cli` handler that needed nothing

Home Manager owns `~/.config/mimeapps.list` once `xdg.mimeApps` is set, and will
not activate over the existing regular file. Removing it is therefore a task
step rather than something a reader is left to infer from an activation error.

That file's one live line, `x-scheme-handler/claude-cli`, was first carried into
the declaration to keep removing the file from silently breaking a URL handler
nothing here would explain. That turned out to be unnecessary and is not
declared: after the switch the scheme still resolves to
`claude-code-url-handler.desktop` with no entry in the generated file. Which
index carries it was not established -- `xdg-mime` reads `mimeapps.list` and
`mimeinfo.cache`, not a desktop file's own `MimeType=` key, so that file
claiming the scheme cannot be the whole account. This decision rests on the
observation and not on the mechanism, which is accepted because the remedy is
known and cheap: if the scheme ever stops resolving, declare the line again.
Leaving it undeclared also keeps the repository from referring to a hand-made
file in `~/.local/share/applications` that pins a Claude Code store path and
that nothing here manages.

### 8. The shebang

`i3.nix:93` reads `!/bin/sh`. With no valid shebang the kernel refuses the exec,
the calling shell runs the file itself, and `!` parses as pipeline negation — so
it works, by two accidents in a row. It is one character, in a let-binding
sitting directly beside the one this change adds, and copying a broken pattern
into a sixth wrapper is the likelier outcome of leaving it.

### 9. `C-w` deletes a word

Rofi's defaults are readline-shaped, which already matches vim's insert mode on
`C-h`, `C-u`, `C-a` and `C-e`; `config.rasi` had moved `C-j`/`C-k` to row
movement. The one combination still disagreeing was `C-w`, bound to
`kb-clear-line` where vim insert mode and Doom's evil insert state delete the
preceding word. It is moved to `kb-remove-word-back`, and `kb-clear-line` is
emptied so the combination holds one action rather than two, since whether rofi
rejects a duplicate binding or silently picks one could not be settled here --
`-dump-config` does not bind keys and no headless display was available.

This reaches every `rofi-*` launcher, not only the one this change adds, because
`config.rasi` is shared through `rofiCmd`. That breadth is the reason it is
recorded as a decision rather than left in the ledger: `C-w` stops clearing the
line in the pass menu and the app menu too, and `C-u` is the replacement.

## What this makes true of the built system

`environment.systemPackages` in `i3.nix` puts `rofi-file-menu` in
`/run/current-system/sw/bin`, so the name resolves in any session, not only under
i3. The keybinding is separate, in `config/i3/config`, which `i3.nix` hands to
`services.xserver.windowManager.i3.configFile`. A reader looking for
`rofi-file-menu` finds two hits in `i3.nix` and one in `config/i3/config`.

The mime defaults are declared a level down, in the Home Manager block of
`home/default.nix`, and materialise as `~/.config/mimeapps.list` symlinked into
the user's generation. Were `i3.nix` dropped from the host, the wrapper and the
binding would go with it while the associations stayed: `xdg-open` from a shell,
from Chromium, or from a mail client would keep reaching `gvim` and `mupdf`. That
asymmetry is deliberate — the launcher is an i3 convenience, the associations are
a property of the user's session.

## Risks / Trade-offs

- **`recursivebrowser` walks the tree itself** → It takes no external command, so
  a run rooted at `$HOME` scans everything, including `.git`, `.cache`,
  `node_modules` and the Nix profile trees. Whether it streams results or blocks
  on the walk could not be determined without a display, so the task that
  exercises it says to check by hand. `filter-regex` is the lever if it stalls;
  it is left unset for now rather than tuned against a guess.
- **Home Manager activation aborts on the existing `mimeapps.list`** → Decision 7
  and an explicit task step. The symptom is an activation error, not a broken
  system, and the rollback is to remove the `xdg.mimeApps` block. Avoided in
  practice by doing the removal first; activation then reported success and the
  file became a symlink into the generation.
- **A declared default can name a type its desktop file does not claim** →
  `xdg-open` honours `[Default Applications]` anyway, which is how markdown
  reaches `gvim` at all. The accepted limitation: nothing validates these
  pairings at build time, so a typo in a mime type or a desktop-file name fails
  silently at open time, falling back to the alphabetical answer. Accepted
  because task 2.1 spot-checks the six types a wrong answer would be noticed on
  daily, with `xdg-mime query default`. The twelve source-code types are not
  individually checked, which is the thin part of this mitigation: a typo among
  them has no symptom until someone opens that kind of file.
- **HiDPI rendering is unverifiable from a rebuild** → Shared with every other
  `rofi-*` wrapper, and mitigated by decision 3 rather than by a check.
