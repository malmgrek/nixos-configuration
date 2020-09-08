# NixOS configuration -- first steps

Learning NixOS configuration. I am mimicking the config
<https://github.com/hlissner/dotfiles.git> because I really like
it's modular structure.

## Next
- Start using `home-manager,` zsh as an example case
- Enable `rofi` properly

## Project general loop
- Include modules one by one
- Test a new rebuild every once in a while
  - Try to make only incremental changes one by one

## Installation

### On VirtualBox
1. Legacy boot partition according to NixOS Manual instructions
2. Install a minimal NixOS
3. Clone, source, and `nixos-rebuild`

## Notes

### Building

From `~/nixos-configuration/`

```bash

$ nixos-rebuild {arg} -I "bin=$(pwd)/bin" -I "config=$(config)"

```

### Nix-channel
I had some problems updating `nix-channel` correctly to `NIX_PATH` regarding `<home-manager/nixos>`.
The problem was solved by updating the channels as `root`.
