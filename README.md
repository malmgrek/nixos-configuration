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

``` shell
sudo nixos-rebuild switch
```

If all went well, boot to the system. Obviously the configuration could be
defined anywhere on the hard disk, as long it is symlinked to
`etc/nixos/configuration.nix`. This is just how I have organized it.

## Description

I have tried to compose the configurations so that it is 

- _modular_, 
- _reasonably
simple_, and that 
- _I can configure my work laptop with it_.

While "developing" the configuration, at the same time I took a shot at
including all my dotfiles in it. I have used the [Home
Manager](https://github.com/nix-community/home-manager "Link to Home Manager
GitHub project") which is a system for managing a Linux user environment (e.g.
Emacs/Vim configurations). All related configs are defined under `./home/` and
can be disabled completely from the configuration.

### Desktop environment

Currently I use an i3 based desktop environment that is included in the configuration as a module.

![Screenshot](https://raw.githubusercontent.com/malmgrek/nixos-configuration/master/resources/screenshot.png)

## Installation alongside Windows

This [Stian Lågstad's
blogpost](https://stianlagstad.no/2020/09/dual-booting-nixos-and-windows-10-a-step-by-step-guide/
"Link to blog") was a useful reference when configuring an encrypted partition
for NixOS on a machine with an existing Windows installation.

TODO: Write an own version for reference.

## TODO
- [ ] VirtualBox
- [ ] Color switching
- [ ] Installation instructions
- [ ] CUDA
