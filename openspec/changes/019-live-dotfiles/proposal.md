## Why

Editing a dotfile requires `nixos-rebuild`, because every file reaches
`~/.config` as a copy in the store. Adding one costs more: home-manager names
the five opencode files individually, so a sixth agent is a Nix edit first.
Both fall hardest on what changes most often -- Emacs, Neovim and the agents.

## What Changes

- Each configuration directory reaches `~/.config` as one symlink to its path
  in this repository, declared through `systemd.user.tmpfiles`. Four directory
  links replace eleven per-file `xdg.configFile` entries; the twelfth,
  ipython's, is dropped rather than linked.
- `lightMode` stops being interpolated into Doom and vim configuration and is
  read at runtime from `LIGHT_MODE`, set in `options.nix`.
  `@font@` in `config/doom/config.el` is a constant wearing a placeholder's
  clothes and is inlined.
- `home.activation.resetOpenCodeState` is removed, reversing the rule that Nix
  defaults overwrite runtime state: a setting changed in an application's own
  interface becomes a diff.
- A linked directory gains a `.gitignore` where its application writes churn
  beside those settings.

Out of scope: removing home-manager, which is 020 and which this only shrinks.
Also `alacritty`, `config/dunst/dunstrc`, `zsh` and `tmux`, which stay
generated -- the first three have no runtime form for a colour mode, a pixel
geometry or a store path, and tmux would need its theme split in two.

## Capabilities

### New Capabilities
- `dotfiles`: what is editable without a rebuild, what stays generated and why,
  and what the repository stops guaranteeing once its dotfiles leave the store.

### Modified Capabilities

None.

## Impact

Five `home/` modules lose `xdg.configFile` blocks to one new module,
`home/ipython.nix` goes entirely, `home/vim.nix` loses a `replaceVars` call,
two `config/` files lose placeholders. `nixos-rebuild build` stops proving the
desktop correct and rollback no longer reverts a dotfile -- accepted, because
this repository is already these files' only source of truth.
