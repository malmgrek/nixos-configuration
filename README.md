# NixOS configuration -- first steps

Learning NixOS configuration. I am very much influenced by the config
<https://github.com/hlissner/dotfiles.git> because I love Doom Emacs.

## Installation

### On VirtualBox
1. Legacy boot partition according to NixOS Manual instructions (no `swapon`)
2. Install a minimal NixOS
3. Clone, source, and `nixos-rebuild`
   - Currently `fileSystem` in `hardware-configuration.nix` must be manually changed

### On laptop

## Notes

### Building

From `~/nixos-configuration/`

```bash

$ nixos-rebuild {arg} -I "bin=$(pwd)/bin" -I "config=$(config)"

```

### Nix-channel

Add and update Nix channels as sudo.

### Picom

Setting `vSync = true` causes an error in VirtualBox. Might be VirtualBox specific.

### Home-manager

#### ZSH

After `nixos-rebuild switch` run `zgen reset` to re-initialize Zgen packages
after next login.

## TODO
- Add apps/graphics (Inkscape, Gimp)
- Add apps/vm (VirtualBox)
- Add Qutebrowser
- Check that screen brightness and sound controls work (i3 vs. sxhkd)
- Fix `bin/scratch`
- LaTeX
- Ask user before cloning plugins etc.
- Node dev
  - History file paths wrong
- Swapcolors
- Themes
- Julia dev
- Tmux plugins and theming
- Add KDE/Gnome or some other floating window manager module
