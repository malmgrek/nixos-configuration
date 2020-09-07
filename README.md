# NixOS configuration -- first steps

Learning NixOS configuration. I am mimicking the config
<https://github.com/hlissner/dotfiles.git> because I really like
it's modular structure.

## Next
- Adopt home manager, otherwise end up in a configuration hell

## Project general loop
- Include modules one by one
- Test a new rebuild every once in a while
  - Try to make only incremental changes one by one

## Installation

### On VirtualBox
1. Legacy boot partition according to NixOS Manual instructions
2. Install a minimal NixOS
3. Clone, source, and `nixos-rebuild`
