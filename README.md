# NixOS configuration

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
- Polybar as a service
- Themes
- Nix-shells instead of Conda environments for Python
- LaTeX + find out if minimal installation is enough
- Color swapping script
- Fix `bin/scratch`
- Check that screen brightness and sound controls work (i3 vs. sxhkd)
- Node
  - History file paths wrong
- Julia (https://discourse.julialang.org/t/using-julia-with-nixos/35129)
- Tmux plugins and themes
- Add KDE/Gnome or some other floating window manager module
- Ask user before cloning plugins and irreversible changes
