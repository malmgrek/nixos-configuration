## Context

See proposal.md -- Why. Two constraints shape the approach. Every application
involved reads `~/.config/<name>` and none can distinguish a symlink from a
directory, which is what makes a single mechanism possible. And the repository
is already checked out at a fixed path the installation procedure assumes, so a
link into the working tree is not a new assumption.

`agent-jail` is unaffected and needs no delta: a jailed session binds its own
state directory over `$HOME`, so links placed in the operator's home are absent
inside the jail exactly as the rest of that directory is.

## Goals / Non-Goals

**Goals:** one mechanism for every live dotfile; a set of generated files small
enough to state in full; no home-manager-specific feature in the result, so 020
inherits nothing to redo.

**Non-Goals:** linking any directory outside `~/.config`. Making live any of
the four files that stay generated -- three in the home directory and dunstrc
in `/etc`. Deciding whether home-manager stays.

## Decisions

1. **One symlink per configuration directory, declared by
   `systemd.user.tmpfiles.rules` in a new `home/dotfiles.nix`.** A single
   mechanism for every application, chosen over a per-application fit, because
   a varying integration is the fragility this change exists to remove.
2. **Link directories, not files.** This is where the simplification is:
   twelve per-file entries become four per-directory lines, and the
   configuration stops enumerating the contents of a directory.
3. **`lightMode` is read at runtime, not interpolated at build time.** The
   option stays; only its delivery changes. `LIGHT_MODE` moves out of
   home-manager's session variables to `environment.sessionVariables` in
   `options.nix`, beside the `lightMode.enable` option it carries: home-manager
   writes a file only a shell sources, and Doom and vim start from the X
   session, which does not. The variable is therefore set for every PAM session
   rather than one user's shells, which is what reaching an X-launched process
   costs. `@font@` in `config/doom/config.el` is a constant and is inlined, so
   Doom's configuration has no placeholders left and the whole directory can go
   live as a unit -- which one generated file in it would otherwise block.

   Doom loads `$EMACSDIR/.local/env` ahead of `config.el` where that file
   exists, so `getenv` there reads a snapshot and a changed `lightMode.enable`
   needs `doom env` re-run before it shows. Accepted: `user-mail-address` in the
   same file already depends on that snapshot, so the dependency is not new, and
   an absent or stale variable yields the dark theme, which is the value the
   option's default asks for anyway.
4. **Three home-directory files stay generated, and the set is closed.**
   `alacritty` has no runtime conditional, zsh's configuration embeds plugin
   store paths, and tmux would need its theme split across two sourced files to
   read the mode at startup. `config/dunst/dunstrc` also stays generated and
   also interpolates -- a notification geometry that 018 fixed at the single
   pixel size it evaluated to, there being no second value to choose between
   until a density above 96 is wanted -- but it
   is an `environment.etc` entry and never reaches the home directory, so it
   sits outside the capability rather than inside its set, alongside the i3,
   rofi and i3status-rs files this repository already delivers through `/etc`.
   See the spec requirement on generated configuration for why this boundary is
   accepted rather than tolerated.
5. **`home.activation.resetOpenCodeState` is deleted, along with the strategy
   comment defending it.** That hook exists to make Nix defaults overwrite what
   the operator chose in the application; once the directory is live, the
   opposite is wanted. Deleting it also removes an activation hook that is a
   home-manager-only feature, so 020 has one less thing to replace.
6. **The mechanism does not depend on home-manager.** `systemd.user.tmpfiles`
   is a NixOS option, so 019 stands whether or not 020 ever happens, and 020
   never has to revisit how a dotfile reaches the home directory.

## What this makes true of the built system

`home/dotfiles.nix` is the only place a live link is declared; a reader greps
`systemd.user.tmpfiles` to find every one of them, and `LIGHT_MODE` to find
every runtime read of the colour mode. The rules are scoped to one user rather
than to the system profile, which every account's systemd instance reads and
where `%h` would aim each of their `~/.config` at this user's checkout; the file
lands under `/etc/profiles/per-user/<user>/etc/xdg/user-tmpfiles.d/`. They
are applied by `systemd-tmpfiles --user` in `system.userActivationScripts`,
which `switch-to-configuration` restarts on every switch, so a link appears on
the rebuild that declares it rather than at the next login.

One live file is reached by a second route that grep does not find. There is no
`~/.vimrc` to link: home-manager feeds `programs.vim.extraConfig` into
`vim-full.customize`, so the vimrc lives inside the wrapped package in the store
and arrives through `-u`. `home/vim.nix` therefore makes its single line a
`source` naming the real vimrc's path in the working tree, which is the one live
file outside `~/.config`. A reader looking for every live file must grep the
repository path as well as the tmpfiles rules.

Which binaries read it is a consequence of `programs.neovim`'s aliases all being
off: `vi`, `vim` and `vimdiff` come from the vim package, which `customize`
wraps with `-u` pointing at that vimrc, and neovim is reached as `nvim`, its
diff mode as `nvim -d`. With any of those aliases on, the live vimrc is read by
nothing.

If the module were removed, the system would still evaluate and build, and
already-created links would remain on disk pointing at the working tree --
`tmpfiles` creates but does not retract. Removing the module is therefore not
the way to undo this change; deleting the links is. That is stated here because
a reader who removes the import and rebuilds will see no change at all and
conclude wrongly that the module does nothing.

## Risks / Trade-offs

- **A directory at one of these paths is replaced, recursively** -> `L+` removes
  whatever occupies the path before linking, and the rule is re-applied by any
  activation -- `nixos-rebuild test` as much as `switch`, as this change found
  out -- and at every user-manager start, so this is a standing property and not
  a one-time migration step: anything that later puts a real directory back at
  one of the four paths is removed again, silently. What the first application
  cost here was IPython's history, which lived under `IPYTHONDIR`, and
  whatever LazyVim kept in its own directory; the repository carries and tracks
  `lazy-lock.json` now, the history is gone. The
  audit in task 3.1 was meant to precede that application and did not, so what
  occupied the four paths beforehand was never examined -- the reason the audit
  belongs first is exactly this. A plain `L` would be
  non-destructive, but it would also do nothing wherever home-manager's old
  symlink still sits, leaving the directory silently stale -- a wrong
  configuration being harder to notice than a missing one.
- **Applications write into the repository working tree** -> a `.gitignore` in
  each directory whose application is found to drop churn there, not in every
  linked directory: an empty one excludes nothing while implying an audit found
  something. Settings are meant to land, per the spec; only churn is excluded,
  and a file whose classification is unverified is left tracked, since a
  wrongly ignored decision defeats the requirement silently while a tracked
  churn file merely annoys.

  **This set cannot be closed by one audit.** Churn appears when an application
  is first exercised, not when its directory goes live: opencode's directory
  held nothing but its configuration until a theme was changed in its interface,
  which produced a 63 MB dependency tree, a generated package manifest and a
  migration backup in one session. The audit in task 3.1 therefore establishes
  the rules for what has run, and `git status` on a published repository is the
  standing check for what has not.
- **The link target is an absolute path** -> derived from
  `customParams.userName` rather than written out. `home/vim.nix` derives it
  locally, being the only caller so far; task 2.1 adds the second and should
  lift it somewhere single rather than let two definitions drift. A repository
  moved elsewhere leaves dangling links and applications fall back to their
  defaults, which is visible immediately rather than silently wrong.
- **A broken dotfile no longer fails the build** -> accepted, and stated in the
  spec. The error surfaces at the next application start instead.

## Migration Plan

Per directory, in any order, since each link is independent: remove the
`xdg.configFile` entries, add the link, confirm the application reads the
working tree. Doom and vim need their placeholders removed first, as the
directory cannot go live while a file in it is generated. Rollback for any one
directory is deleting its link and restoring its `xdg.configFile` entry.

The audit of what each application writes decides which `.gitignore` files
exist at all, and cannot run from inside a jailed session: the jail binds its
own state directory over the home directory, so a check there reports on the
jail rather than on the operator's configuration.
