## 1. Launcher

- [x] 1.1 Add a `rofi-file-menu` `writeScriptBin` let-binding to `i3.nix`
  alongside the other `rofi-*` wrappers, and list it in
  `environment.systemPackages`. The script is a single `${rofiCmd}` invocation
  with `-modi filebrowser,recursivebrowser -show filebrowser`, following the
  shape of `rofi-app-menu` rather than the `rofi-pass-menu` pipeline: no
  selection handling, since both modes run their own `command` and exit. Leave
  `-filebrowser-*` and `-recursivebrowser-*` unset — the `xdg-open` default is
  decision 4 and the start directory is out of scope.

  Validation: `nix-build '<nixpkgs/nixos>' -A config.system.build.toplevel -I nixos-config=./hosts/spyridon --no-out-link | xargs -I{} grep -c 'recursivebrowser' {}/sw/bin/rofi-file-menu`

- [x] 1.2 Restore the missing `#` on the `rofi-window-menu` shebang in `i3.nix`
  (line 93 at the time of writing, `!/bin/sh`). The validation greps the built
  script rather than the Nix source because the broken form evaluates and builds
  without complaint — and because the script also *runs* without complaint, for
  the two reasons design.md decision 8 records, so nothing in ordinary use would
  surface it.

  Validation: `nix-build '<nixpkgs/nixos>' -A config.system.build.toplevel -I nixos-config=./hosts/spyridon --no-out-link | xargs -I{} grep -c '^#!/bin/sh' {}/sw/bin/rofi-window-menu`

- [x] 1.3 Bind `$mod+Shift+f` to `rofi-file-menu` in `config/i3/config`, in the
  block with the other `rofi-*` bindings (lines 74-78), using the same
  `exec --no-startup-id` form. The grep below is the only part a check can
  reach. After `nixos-rebuild switch` and an i3 reload, confirm by hand on the
  switched-to system: the picker appears over the focused window; Enter descends
  into a directory and `..` ascends; `Shift+Right` reaches the recursive list
  and `Shift+Left` returns; `Shift+Delete` toggles hidden files. Record here how
  long the recursive list takes to populate from `$HOME` — design.md flags that
  walk as unmeasured, and if it stalls, note it rather than reaching for
  `filter-regex` in this change.

  Confirmed by hand on the switched-to system: the picker appears over the
  focused window, Enter descends and `..` ascends, `Shift+Right` and
  `Shift+Left` move between the two modes, and `Shift+Delete` toggles hidden
  files. No stall was reported on the recursive list, so `filter-regex` stays
  unset and design.md's walk risk is resolved in the direction it hoped for.
  No numeric timing was captured, which is the one part of this task's text not
  satisfied -- recorded here rather than dropped, since the decision it was
  meant to inform is already settled by the absence of a stall.

  Validation: `grep -n 'bindsym \$mod+Shift+f\b' config/i3/config`

## 2. File associations

- [x] 2.1 Add an `xdg.mimeApps.defaultApplications` block to the Home Manager
  section of `home/default.nix`: `gvim.desktop` for `text/plain`,
  `text/markdown` and the source-code types a picker surfaces; `mupdf.desktop`
  for `application/pdf`; `feh.desktop` for `image/png`, `image/jpeg` and
  `image/gif`; and `pcmanfm.desktop` for `inode/directory`. The validation prints
  every pairing, which is the point: nothing checks these names at build time,
  so a typo in a mime type or a desktop file is visible only by reading them.

  Two things this task needs that it cannot do itself. The stale
  `~/.config/mimeapps.list` must be removed before switching — activation aborts
  until it is gone, since `home-manager.backupFileExtension` is not set here —
  and that path is outside the project directory, so an agent stops and asks
  rather than running it. Then, after `nixos-rebuild switch`, confirm by hand
  with `xdg-mime query default` for `text/plain`, `text/markdown`,
  `application/pdf`, `image/png`, `inode/directory` and
  `x-scheme-handler/claude-cli`, and open one file of each kind from
  `rofi-file-menu`.

  Confirmed on the switched-to system after the stale file was removed:
  activation reported success, `~/.config/mimeapps.list` is now a symlink into
  the generation carrying all 17 pairings, and `xdg-mime query default` returns
  gvim for `text/plain` and `text/markdown`, mupdf for `application/pdf`, feh
  for `image/png` and pcmanfm for `inode/directory`. The `claude-cli` carry-over
  was dropped during implementation and the scheme still resolves to
  `claude-code-url-handler.desktop` without it; design.md decision 7 records why.

  Validation: `nix-instantiate --eval --strict '<nixpkgs/nixos>' -I nixos-config=./hosts/spyridon -A config.home-manager.users.malmgrek.xdg.mimeApps.defaultApplications`

## Unreconciled
