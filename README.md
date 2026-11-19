# Definition of my NixOS system

This is my personal NixOS configuration. As of now, I have only installed NixOS
on my present laptop, Lenovo P14s, alongside Windows. At some point, I will
probably also install NixOS on my home server and add the configurations here. A
nice thing about NixOS is that it greatly facilitates managing multiple machines
in a reproducible way.

The most important sources of inspiration have been

- jluttine's [Nixos configuration](https://github.com/jluttine/nixos-configuration "Link to GitHub repo")
- hlissner's [Dotfiles](https://github.com/hlissner/dotfiles "Link to GitHub repo")

## Summary

I installed NixOS through USB. The installer doesn't do any disk partitioning or formatting, so one needs to do that by oneself, e.g. according to the official manual instructions.

After installing NixOS on a machine, symlink the file
`./hosts/awesomename/configuration.nix` at `/etc/nixos/configuration.nix`, and run

```shell
sudo nixos-rebuild switch
```

If all went well, boot to the system.

Where the repository itself sits is no longer free, though. Some dotfiles are
read from the working tree at runtime instead of being copied into the Nix
store, and the links that do that name an absolute path: `/home/<user>/NixOS`,
unless `customParams.repoPath` says otherwise. Check the repository out there or
set that option to match, or the applications concerned lose their
configuration, falling back to their own defaults.

## Description

I have tried to compose the configurations so that it is

- _modular_,
- _reasonably
  simple_, and that
- _I can configure my work laptop with it_.

While "developing" the configuration, at the same time I took a shot at
including all my dotfiles in it. This used to go through [Home
Manager](https://github.com/nix-community/home-manager "Link to Home Manager
GitHub project"), a system for managing a Linux user environment, but no longer:
the per-user modules under `./home/` are plain NixOS modules now, and most of
the dotfiles they used to generate are live files in `./config/`. Cloning this
repository therefore needs no home-manager channel.

### Dotfiles

Six directories under `./config/` reach `~/.config` as symlinks into this
repository, declared in `home/dotfiles.nix`: `doom`, `nixpkgs`, `nvim`,
`opencode`, `tmux` and `zsh`. Editing a file in one of them takes effect when
its application next reads it, with no rebuild in between.

For zsh and tmux the live file is the second of two layers: `/etc/zshrc` and
`/etc/tmux.conf` carry what cannot be live -- the plugin paths, which exist
only once the system is built -- and each tool reads them before the file in
this repository.

Everything else under `./config/` still needs a rebuild. `config/i3`,
`config/rofi`, `config/i3status-rs` and `config/dunst` are copied into the store
and delivered through `/etc` rather than the home directory, dunst's with its
notification geometry substituted in as a pixel constant. Alacritty's is the
one configuration still generated outright: it embeds the colour mode, and its
search path offers no system layer to carry that, so the home directory links
at the built file rather than at the working tree.

What the live arrangement costs is worth knowing. A successful `nixos-rebuild
build` no longer proves the desktop is configured correctly, and a rollback does
not revert a dotfile: the working tree is the only copy, so git holds the
history instead of the store. An application writing its own settings writes
them here, which is intended -- the choice shows up as a change to commit or
discard rather than being overwritten on the next rebuild. And a link replaces
whatever occupies its path, recursively, every time the configuration is
activated, `nixos-rebuild test` included. Dropping a directory from
`home/dotfiles.nix` does not undo that: tmpfiles creates links and never
retracts them, so the leftover has to be deleted by hand.

### AI development tools

`home/ai.nix` installs the Claude Code, Copilot CLI, opencode, OpenSpec and
pi executables, together with the Playwright tooling and `rtk`.

### Desktop environment

Currently I use an i3 based desktop environment that is included in the configuration as a module.

<!-- TODO: add a new screenshot as resources/screenshot.png and restore the
     image link below. The network block hides the network name until clicked,
     so capture it in that resting state -- and check the rest of the bar, the
     tray and any notification on screen before committing an image. -->

_Screenshot to be added._

## Installation alongside Windows

This [Stian Lågstad's
blogpost](https://stianlagstad.no/2020/09/dual-booting-nixos-and-windows-10-a-step-by-step-guide/ "Link to blog") was a useful reference when configuring an encrypted partition
for NixOS on a machine with an existing Windows installation.

TODO: Write an own version for reference.

## Roadmap

See [ROADMAP.md](ROADMAP.md).
