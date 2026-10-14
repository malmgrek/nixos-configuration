## Why

Reaching a file means a terminal, `ranger` or a `find` pipeline, and naming the
program to open it with. As with the password store the obstacle is the shell,
not the picker: the file is wanted while another window has focus.

## What Changes

- Add a `rofi-file-menu` wrapper over rofi's built-in `filebrowser` and
  `recursivebrowser` modes — directory-at-a-time browsing and recursive fuzzy
  find, switchable through rofi's mode keys — installed like the five existing
  `rofi-*` wrappers.
- Bind it to `$mod+Shift+f` in the i3 config.
- Declare `xdg.mimeApps.defaultApplications`: `gvim` for plain text and
  markdown, `mupdf` for PDF, `feh` for images, `pcmanfm` for directories.
- Restore the `#` on the `rofi-window-menu` shebang in `i3.nix`; it is missing,
  so that script runs only by accident.

Both modes honour the fuzzy matching and vim-style row keys already in
`config/rofi/config.rasi`.

The mime half is not decoration: without it `xdg-open` picks by alphabetical
order in a generated cache -- PDFs and PNGs in Chromium, text in a fresh GUI
Emacs, unclaimed types in nothing.

## Capabilities

### New Capabilities

None. `skip_specs: true`: the sole capability under `openspec/specs` is scoped
to agent-jail confinement.

### Modified Capabilities

None.

## Impact

- `i3.nix`: a let-binding, a `systemPackages` entry, a restored `#`;
  `config/i3/config`: one `bindsym`; `home/default.nix`: an `xdg.mimeApps` block;
  `AGENTS.md`: a rule capping inline comments.
- `config/rofi/config.rasi`: `C-w` rebound from clearing the line to deleting a
  word. This reaches all six `rofi-*` launchers, not only the one added here.
- **BREAKING for `~/.config/mimeapps.list`**: Home Manager takes that path over
  and will not activate while the hand-written file is there, so it must be
  removed before switching. Its one live line needs no replacement; design.md
  decision 7 records why.
- No new dependencies: `rofi`, `gvim`, `mupdf`, `feh` and `pcmanfm` are declared
  already.

Out of scope: per-mode keybindings, a non-`$HOME` start directory, previews,
file operations, unlisted mime types.
