## Why

Home-manager is a second module system doing four jobs, three of which this
repository already does at the NixOS level for i3, rofi, dunst and i3status-rs.
The fourth is 019's. What remains is a separate channel, a `stateVersion` and a
`useGlobalPkgs` coupling, in exchange for options NixOS also has.

## What Changes

- `home.packages` across seven modules becomes `users.users.<name>.packages`:
  same scoping, one module system.
- `programs.{zsh,tmux,neovim,direnv,fzf,autojump}` move to the NixOS modules of
  the same names. For zsh and tmux those write `/etc/zshrc` and
  `/etc/tmux.conf`, which each tool loads before the user's own file, so plugin
  store paths stay generated there and the live dotfile names none. `alacritty`
  and firefox have no module to move to, so those two are assembled here
  instead; vim loses its configuration rather than being ported, per design
  decision 8.
- `home.pointerCursor` becomes the files it wraps.
- `home.sessionVariables` folds into `environment.sessionVariables`, bar
  `EDITOR`, which `common.nix` alone keeps; `home.sessionPath` goes to the live
  `.zshenv`.
- `xdg.mimeApps` becomes `xdg.mime.defaultApplications` in
  `/etc/xdg/mimeapps.list`, which `XDG_CONFIG_DIRS` leads with.
- **BREAKING** for anyone cloning this: the home-manager channel is no longer
  required, and `home/` stops being disableable as a unit.

Out of scope: how dotfiles reach the home directory -- 019 settles that, and
`systemd.user.tmpfiles` survives untouched. Also making `alacritty` live: it is
generated because it interpolates `lightMode` and has no system layer, so that
follows 021.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `dotfiles`: tmux and zsh become live, leaving one generated file where the
  spec names three. `agent-jail` needs no delta -- it states confinement
  properties and names no declaration mechanism.

## Impact

Every file under `home/`. zsh's five `fetchFromGitHub` blocks become nixpkgs
packages, two through NixOS modules of their own. `home.pointerCursor` has no
module behind it. Take those two last, so one awkward module cannot strand the
rest.
