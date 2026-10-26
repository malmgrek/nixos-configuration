## Context

See proposal.md -- Why. What shapes the approach is that zsh, tmux and neovim
all read a system file before a user one, and that 019 already put four
directories in the home directory by reference. The work is therefore a
re-partitioning along a seam the tools already have, not a port.

## Goals / Non-Goals

**Goals:** every per-user program whose configuration is a file the operator
edits ends up live; what cannot be live is small, named, and in the system
layer; nothing home-manager-specific survives.

**Non-Goals:** making the colour mode switchable, which is 021. Changing what
any configuration says, with one deliberate exception the operator made while
this change was open: alacritty's font size, from 9 to 10. Keeping
home-manager's option names for their own sake.

## Decisions

1. **Two layers, the tools' own.** The NixOS module writes the system file --
   `/etc/zshenv`, `/etc/zshrc`, `/etc/tmux.conf` -- and the live dotfile is the
   user file each tool reads next. Store paths stay in the system layer; the
   live file names none and needs no `source` line to find them.
2. **zsh plugins become nixpkgs packages sourced from `/etc/zshrc`.** All five
   exist there, two with NixOS modules of their own, so the `fetchFromGitHub`
   blocks and their pinned hashes go. Home-manager materialises those plugins
   into `~/.config/zsh/plugins`; nothing replaces that, and `~/.config/zsh`
   ends up holding the operator's two files and a `.gitignore` for the
   completion dump zsh writes beside them.
3. **`ZDOTDIR` is set in `/etc/zshenv`** through `programs.zsh.shellInit`, which
   zsh reads before looking for any user file. Home-manager's one-line
   `~/.zshenv` bootstrap is not reproduced: nothing needs to exist in `$HOME`,
   and the directory stays linkable as a directory, so a later `.zprofile` costs
   no Nix edit.
4. **`home.sessionPath` moves to the live `.zshenv`, not `.zshrc`.** It arrives
   today through `hm-session-vars.sh`, which `.zshenv` sources, so every zsh
   invocation sees it including non-interactive ones; `.zshrc` would narrow that
   to interactive shells. Nothing outside zsh reads that file, so an
   X-launched process has never had these paths and still will not.
5. **tmux goes live now, with its theme inline.** The theme is the one
   `lightMode.enable = false` already selects, carried as a comment pointing at
   021. Waiting for 021 would mean moving tmux twice.
6. **Firefox becomes an ordinary entry in the per-user package set,** beside
   chromium, rather than a module. Its two preferences go with the module, and
   so does `configPath`: home-manager generated a `profiles.ini` under
   `~/.config/mozilla/firefox` naming a default profile, and without it firefox
   falls back to its own profile root and creates a fresh one. Any existing
   profile is then unreferenced rather than deleted, so bookmarks and logins
   appear gone while the data remains. Both roots have to be checked, not
   inferred: firefox wrote into `~/.mozilla/firefox` until `configPath` was
   activated and a profile is still there, while the pinned version reads
   `$XDG_CONFIG_HOME/mozilla/firefox` unprompted -- observed, by its creating a
   profile there with no home-manager left. So `configPath` moves nothing and
   only the generated `profiles.ini` goes; recovery is to name the old profile
   in its replacement rather than to move data. Keeping the
   preferences instead would mean adopting `policies.json`, a different
   mechanism, for a homepage and a density setting that are each one click in
   the interface.
7. **`home.pointerCursor` is replaced by the four things it does:** the theme
   package in the per-user set, `XCURSOR_THEME` and `XCURSOR_SIZE` in
   `environment.sessionVariables`, a small derivation providing
   `share/icons/default/index.theme`, and the `Xcursor.*` resources in an `xrdb`
   merge of their own beside them, rather than appended to the one `options.nix`
   performs for `Xft.dpi`, which is gated on a pinned density a cursor has no
   business depending on. Only `x11.enable` was set, so no GTK configuration is
   involved. The search path needs nothing: nixpkgs'
   `nixos/modules/config/xdg/icons.nix`, not a file here, lists every profile's
   `share/icons`, and `/etc/profiles/per-user/<name>/share/icons` is in it on
   the built system. It lists `$HOME/.icons` and `~/.local/share/icons` first
   though, so a `default` theme home-manager left in either answers before this
   one and both must go. Task 5.1 deletes `~/.Xresources` too, for a different
   reason: `options.nix` merges it ahead of the declared resources and it may
   hold operator-written lines.
8. **vim stops being configured at all: `vim-full` replaces plain `vim` in
   `environment.systemPackages` and `programs.vim` goes with the rest of the
   module.** Carrying the configuration forward was tried first, as a
   `vim-full.customize` call feeding `programs.vim.package`, and it hit decision
   13's collision: `common.nix` has listed plain `vim` since 2021, and a
   configured terminal `vim` turned out to be an accident of home-manager's
   profile ordering. `vim-full` and not plain
   `vim` because `gvim` is what every mime association in `home/default.nix`
   opens and plain `vim` ships `gvim.desktop` without a `gvim` binary, and
   because plain `vim` is built without `+clipboard`. nvim is the configured
   editor here, so vim keeps nothing: `home/vim.nix`, its twelve plugin
   declarations, the `vim-sensible` the home-manager module used to merge in
   regardless, and `config/vim/extra.vimrc` are all deleted. Neovim's module is
   thinner than home-manager's in a different way: no `extraPackages`, so the
   language servers move to the per-user set, and every provider and alias flag
   defaults to false where home-manager defaulted two of them true, so each must
   be set explicitly.
9. **Alacritty's configuration is generated into the store and delivered by a
   tmpfiles link.** It is the one case the two-layer pattern does not reach: its
   documented search path is `$XDG_CONFIG_HOME` only, with no system-layer
   fallback, and once home-manager is gone nothing else writes into the home
   directory. So the file stays generated, for the `lightMode` interpolation it
   already carries, and the home directory links the path at that store file
   rather than at the working tree. That rule sits in `home/alacritty.nix`
   beside the file it names, that being the only module able to produce the
   path. It is the only member of the generated set after this change, and 021
   is what lets it join the live ones.
10. **`.npm-global` becomes a tmpfiles `d` rule** beside the links in
   `home/dotfiles.nix`, replacing a `home.file` entry whose only purpose was to
   make the directory exist.
11. **`~/.config/zsh`'s link and home-manager's departure land in one step.**
   Home-manager manages that directory's contents today, so a link placed while
   it still runs reproduces the collision that broke neovim: `L+` would put a
   symlink where activation expects to write, and activation would refuse.
12. **`HISTFILE` moves to `$XDG_STATE_HOME/zsh/history`,** which is not what
   home-manager's options expressed. `ZDOTDIR` is a link into this published
   repository after this change, so history at the old path beside `.zshrc`
   would be committed to it; `L+` also destroys that file, and the plugin
   directory beside it, on the first switch. History is machine state, not
   configuration, and this is the only value this change deliberately relocates
   rather than carries.

13. **One binary, one provider: this change's own failure mode.** Two packages
   in one profile that ship the same binary collide, whether both are plain
   entries or one arrives through a `programs.*` module -- and moving a program
   off home-manager puts the module's package where `common.nix` may already
   list it. Under home-manager the two lived in separate profiles and
   `~/.nix-profile` won by PATH order, so the configured copy was served by
   accident; in one profile `buildEnv` picks silently by list order. It happened
   to both editors -- vim losing its vimrc, nvim all three providers -- and
   neither showed in a validation reading the module's own option, which reports
   what the module intends to build rather than what the profile serves. The
   check that catches it resolves the name through the built
   `config.system.path`. Both were resolved by removing a provider rather than
   prioritising one, since collision order is not a contract.

## What this makes true of the built system

`home/` ceases to exist as an import unit, and with it the only mechanism that
writes files into the home directory from Nix besides
`systemd.user.tmpfiles`. A reader greps `systemd.user.tmpfiles` for every link,
live or generated, and `environment.etc` for every system-layer file; there is
no third route. `users.users.<name>.packages` replaces `home.packages`, so a
per-user package set remains per-user rather than becoming system-wide, bar
`tmuxPlugins.pain-control` and `resurrect`: `programs.tmux.enable` places its
plugins in `environment.systemPackages`, which on a single account has no
practical effect but does narrow the claim.

The collision class that failed on 019's first switch disappears rather than
being guarded against. It exists only because home-manager declares files in
the same directories the links occupy; with no `home-files`, there is nothing
for a link to collide with, and no check is needed to catch it.

If the NixOS modules were removed instead, zsh would start with no plugins and
tmux with none, both silently -- the live files would still load, since each
tool reads its user file whether or not the system file exists. That is the
cost of the seam: a missing system layer degrades quietly where a missing live
file does not.

## Risks / Trade-offs

- **`/etc/zshenv` sets `ZDOTDIR` for every user** -> accepted on a single-user
  machine, where a second account simply finds no files at that path and falls
  back to zsh's defaults. A `$USER` guard is available and deliberately not
  taken until a second account exists.
- **A plugin tried outside Nix lives at a path Nix does not guarantee** -> the
  live `.zshenv` sources it behind an existence test, so a fresh checkout loads
  nothing rather than failing. The experiment path is deliberately imperative;
  promoting a plugin to the system layer is what makes it reproducible.
- **Firefox loses two preferences** -> accepted, per decision 6.
- **zsh and `home.pointerCursor` have the least mechanical replacements** ->
  taken last, so an awkward one cannot strand the rest.
- **Home-manager's own profile outlives the module** -> removing the module
  removes the activation service, so nothing deactivates `~/.nix-profile`, and
  `set-environment` keeps it ahead of `/etc/profiles/per-user/<name>` in PATH --
  pre-020 copies of every moved package shadow the new ones until
  `nix-env -e home-manager-path` removes it. Deleting the files home-manager
  wrote does not.
- **`programs.direnv` enables `nix-direnv` where home-manager's did not** ->
  accepted and desirable, though no task asked for it: `use nix` and `use flake`
  take the caching implementation and write `.direnv` gcroots into project
  directories.
- **Nothing proves the layering until a session restarts** -> `/etc/zshenv` and
  `/etc/zshrc` are read at shell start, so a rebuild alone leaves the running
  shell on the old files. Each task that touches them says to open a new shell,
  and evaluation checks cannot stand in for that.

## Migration Plan

Mechanical first, in any order: packages, session variables, `xdg.mimeApps`,
`.npm-global`, firefox, neovim, vim, direnv, fzf, autojump. Then tmux, which
adds a live directory. Then alacritty, which decision 9 shapes and which must
precede the import's removal for the same reason zsh's link must accompany it.
Then zsh, as one step with the removal of the `<home-manager/nixos>` import,
`useGlobalPkgs` and `stateVersion` -- decision 11 requires it.

`home.pointerCursor`'s *replacement* comes last, being the only one with no
module behind it, but its *declaration* cannot: the import will not evaluate
while any `home-manager.users` option is still set, so that block goes with the
import and the cursor sits at its default until the replacement lands. The same
is true of any other declaration still standing at that point.

Rollback for any one module is restoring its `home/` file and the import; after
the final step there is no import to restore, so that step is the point of no
return and should follow a working rebuild of everything before it.
