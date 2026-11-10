## Why

`lightMode.enable` is a NixOS option, so switching colour scheme costs a rebuild
and a re-login. 019 removed that cost for what dotfiles say; it remains for the
one switch that changes all of them. Reading the mode at runtime from a variable
only settable at build time is half a mechanism.

## What Changes

- The mode becomes a file the operator writes, read at startup by each
  application that follows it, with a command that toggles it and reloads
  running applications.
- `lightMode.enable` and `LIGHT_MODE` go: `options.nix` stops carrying a choice
  the operator should make without it.
- Doom and vim read the file rather than the environment. 019 moved both off
  build-time interpolation, so only the source changes.
- A switch reaches applications already running, which the variable never
  could: a new value was invisible until the next login.

Out of scope: making `alacritty` live. This unblocks it -- it can import a
colour fragment -- but it has no system layer either, so that move is its own
change. tmux went live in 020 with its theme inline; the light palette is in
commit `7f54a3d`, `home/tmux.nix`. Also out of scope is `config/dunst/dunstrc`,
whose interpolated value is a pixel geometry tied to density, not colour.

## Capabilities

### New Capabilities
- `colour-mode`: how the operator switches scheme, which applications follow,
  what happens to those already running, and what a fresh checkout does before
  any choice is made.

### Modified Capabilities
- `dotfiles`: its scenario on choosing a colour scheme at read time has the
  application select "from the environment at startup", which stops being how
  the value arrives.

## Impact

`options.nix` loses the option and the variable. `config/doom/config.el` and
`config/vim/extra.vimrc` change where they read from. The toggle is new, and
`home/dotfiles.nix` may gain a link.
