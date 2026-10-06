## 1. Launcher

- [ ] 1.1 Add a `rofi-pass-menu` `writeScriptBin` let-binding to `i3.nix`
  alongside the other `rofi-*` wrappers, and list it in
  `environment.systemPackages`. The script lists entry names under
  `$PASSWORD_STORE_DIR` (falling back to `$HOME/.password-store`) with `find`
  and `sed`, pipes them through `${rofiCmd} -dmenu`, and copies the selection
  with `${pkgs.pass}/bin/pass -c`; selecting nothing exits without calling
  `pass`, and a failing `pass` reports through `notify-send`. Note that
  `''${PASSWORD_STORE_DIR:-...}` must escape its `${` against Nix
  interpolation, as `utils/rofi-power-menu.nix:11` already does — the
  validation below greps the built script precisely because evaluation accepts
  the unescaped form and silently produces an empty prefix.

  Validation: `nix-build '<nixpkgs/nixos>' -A config.system.build.toplevel -I nixos-config=./hosts/spyridon --no-out-link | xargs -I{} grep -c PASSWORD_STORE_DIR {}/sw/bin/rofi-pass-menu`

- [ ] 1.2 Bind `$mod+p` to `rofi-pass-menu` in `config/i3/config`, in the block
  with the other `rofi-*` bindings (lines 74-77), using the same
  `exec --no-startup-id` form. Whether the overlay actually appears over a
  focused window, whether the pinentry prompt paints, and whether the clipboard
  receives the password cannot be checked by evaluating or building the
  configuration — they need a display and a switched-to system, so confirm them
  by hand after `nixos-rebuild switch` and reload i3. If no passphrase prompt
  appears, apply the `pinentry-gtk2` fallback recorded in design.md.

  Validation: `grep -n 'bindsym \$mod+p\b' config/i3/config`

## Unreconciled
