# NixOS configuration -- first steps

Learning NixOS configuration. I am very much influenced by the config
<https://github.com/hlissner/dotfiles.git> because I really like
it's modular structure.

## TODO
- SSH module with public key
- Vim keybindings to Rofi
- Dunst
- Tmux plugins and theming
- Fix `bin/scratch`
- LaTeX
- Ask user before cloning plugins etc.
- Node dev
  - History file paths wrong
- Themes

## Project general loop
- Include modules one by one
- Test a new rebuild every once in a while
  - Try to make only incremental changes one by one

## Installation

### On VirtualBox
1. Legacy boot partition according to NixOS Manual instructions (no `swapon`)
2. Install a minimal NixOS
3. Clone, source, and `nixos-rebuild`
   - Currently `fileSystem` in `hardware-configuration.nix` must be manually changed


## Notes

### Building

From `~/nixos-configuration/`

```bash

$ nixos-rebuild {arg} -I "bin=$(pwd)/bin" -I "config=$(config)"

```

### Nix-channel

I had some problems updating `nix-channel` correctly to `NIX_PATH` regarding `<home-manager/nixos>`.
The problem was solved by updating the channels as `root`.

### Picom

Setting `vSync = true` causes an error in VirtualBox. Might be VirtualBox specific.

### Home-manager

#### Service

Starting Home Manager service was failing on syntax error `...string 'Derive(['` indicating
corrupted user environment `.drv` file. Running `nix-store --delete /path/to/drv` and then `nixos-rebuild switch` fixed the problem.

#### ZSH

After `nixos-rebuild switch` run `zgen reset` to re-initialize Zgen packages
after next login.
