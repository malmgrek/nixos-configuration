## Why

Copying a password from the store currently means opening a terminal and running
a `find | sed | fzf | xargs pass -c` pipeline by hand. The pipeline itself is
fine; needing a shell to reach it is not, because the password is almost always
wanted while another window has focus.

## What Changes

- Add a `rofi-pass-menu` wrapper: list the store's entry names, pick one through
  `rofi -dmenu`, copy it with `pass -c`.
- Bind it to `$mod+p` in the i3 config.
- Install it alongside the four `rofi-*` wrappers already in `systemPackages`.

Rofi replaces `fzf` because it draws an override-redirect window: i3 never
tiles, places or tracks it, so it appears over whatever has focus and returns
focus there on exit. A terminal running `fzf` would be a managed container
instead, needing placement and dismissal. Fuzzy matching and the vim-style row
keys the pipeline relied on are already configured in `config/rofi/config.rasi`,
so nothing new is needed to keep that behaviour.

## Capabilities

### New Capabilities

None. `skip_specs: true` is set in `.openspec.yaml`: the four sibling
`rofi-*` wrappers carry no spec, and a fifth launcher of the same shape is the
same class of thing. Inventing a `desktop-launchers` capability for this one
would describe the siblings' behaviour as much as its own, which is a wider
change than this.

### Modified Capabilities

None.

## Impact

- `i3.nix`: one `writeScriptBin` let-binding, one `systemPackages` entry.
- `config/i3/config`: one `bindsym`.
- No new dependencies. `pass`, `rofi`, `xclip` and a graphical pinentry are
  already present.

Out of scope: typing a password into the focused field (would need `xdotool` in
`systemPackages`), OTP, multi-line field selection, and editing entries.
