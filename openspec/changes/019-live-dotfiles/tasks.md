## 1. Remove build-time interpolation

- [x] 1.1 Inline the constant `@font@` value into `config/doom/config.el` and
      drop the `font` argument from the `replaceVars` call in
      `home/doom-emacs.nix`. The placeholder never varied, so nothing but the
      indirection is lost.
      Validation: `! grep -q '@font@' config/doom/config.el && nix-instantiate '<nixpkgs/nixos>' -A system -I nixos-config=./hosts/spyridon`

- [x] 1.2 Move the `LIGHT_MODE` session variable out of `home/neovim.nix` into
      a place that does not imply it belongs to Neovim, so Doom and vim can
      read it without depending on a module they are unrelated to.
      Validation: `nix-instantiate '<nixpkgs/nixos>' -A system -I nixos-config=./hosts/spyridon`

- [x] 1.3 Make `config/doom/config.el` select its theme from `LIGHT_MODE` at
      startup and drop the `replaceVars` call in `home/doom-emacs.nix`
      entirely, leaving `config.el` a plain source file like its three
      siblings. Requires 1.1 and 1.2.
      Validation: `! grep -q '@theme@' config/doom/config.el && ! grep -q replaceVars home/doom-emacs.nix`

- [x] 1.4 Make `config/vim/extra.vimrc` set `background` from `$LIGHT_MODE` and
      have `home/vim.nix` source the file from the repository path rather than
      reading it through `replaceVars`, so editing the vimrc stops needing a
      rebuild. Requires 1.2.
      Validation: `! grep -q '@background@' config/vim/extra.vimrc && nix-instantiate '<nixpkgs/nixos>' -A system -I nixos-config=./hosts/spyridon`

## 2. The link mechanism

- [x] 2.1 Add `home/dotfiles.nix` declaring the link helper over
      `systemd.user.tmpfiles.users.<name>.rules`, with `nixpkgs` as its only
      entry, and remove `xdg.configFile."nixpkgs/config.nix"` from
      `home/default.nix`. Smallest directory first, so the mechanism is proven
      before anything depends on it. Establish as part of this task when a newly
      added link is applied -- on the rebuild that declares it, or only at the
      next login -- and record the answer in `home/dotfiles.nix`.
      Validation: `nix-instantiate '<nixpkgs/nixos>' -A system -I nixos-config=./hosts/spyridon`

- [x] 2.2 Drop the ipython configuration instead of linking it: remove
      `config/ipython`, `home/ipython.nix` and its import, leaving ipython on
      its own defaults with no `IPYTHONDIR`. This task originally moved the
      inline configuration into the repository and linked the directory, which
      it did; the operator then decided the configuration was not wanted, so
      the link and the module were removed again. "Own defaults" holds only
      once `~/.config/ipython` is deleted by hand: tmpfiles does not retract a
      link when its rule goes, and a dangling one would capture a future
      `config/ipython`.
      Validation: `! test -e config/ipython && ! test -e home/ipython.nix && nix-instantiate '<nixpkgs/nixos>' -A system -I nixos-config=./hosts/spyridon`

- [x] 2.3 Link `nvim` and remove `xdg.configFile."nvim"` from
      `home/neovim.nix`, leaving that module responsible only for the package
      and its `extraPackages`.
      Validation: `! grep -q 'configFile."nvim"' home/neovim.nix && nix-instantiate '<nixpkgs/nixos>' -A system -I nixos-config=./hosts/spyridon`

- [x] 2.4 Link `doom` and remove all four `xdg.configFile."doom/..."` entries
      from `home/doom-emacs.nix`. Requires 1.3, since the directory cannot go
      live while a file in it is generated.
      Validation: `! grep -q 'configFile."doom' home/doom-emacs.nix && nix-instantiate '<nixpkgs/nixos>' -A system -I nixos-config=./hosts/spyridon`

- [x] 2.5 Link `opencode`, remove its five `xdg.configFile` entries, and delete
      `home.activation.resetOpenCodeState` together with the strategy comment
      defending it -- that hook exists to overwrite what the operator chose,
      which is the opposite of what a live directory is for.
      Validation: `! grep -q resetOpenCodeState home/opencode.nix && nix-instantiate '<nixpkgs/nixos>' -A system -I nixos-config=./hosts/spyridon`

## 3. Repository hygiene

- [x] 3.1 Inspect each linked directory from an unjailed shell -- a jailed
      session binds its own state directory over `$HOME` and would report on the
      jail -- and add a `.gitignore` to each directory whose application is
      found to drop churn there, leaving settings tracked. A file whose
      classification cannot be confirmed stays tracked. A directory may also
      earn a `.gitignore` for a credential its application could write there,
      which is an exclusion on publication grounds rather than churn.

      This was meant to run before the activation that applies section 2, since
      `L+` removes each path recursively; an accidental `nixos-rebuild test` got
      there first, so what occupied the four paths beforehand is gone unexamined
      and the audit reports only on the link targets.
      Validation: `git status --porcelain config/ | grep -v '^ M' | head` -- expect no untracked application churn

## 4. Documentation

- [x] 4.1 Record in `README.md` that the repository must be checked out at the
      path the links name for the desktop to be configured, since the
      installation section currently implies the symlink to
      `/etc/nixos/configuration.nix` is the only placement requirement.
      Validation: `grep -q 'customParams.repoPath' README.md` -- the option the
      requirement hangs on. A search for "dotfile" was the original check and
      passed before the task was begun, the word already appearing twice in the
      prose.

## Unreconciled

- `programs.neovim`'s `viAlias`, `vimAlias` and `vimdiffAlias` were all turned
  off in `home/neovim.nix` at the operator's request, no task having asked for
  it. Behaviour -- spec: this makes task 1.4 true rather than changing what it
  claims. `vi` and `vim` resolved to neovim while those aliases and
  `programs.vim` were all enabled, so the live `config/vim/extra.vimrc` the
  task created was read by nothing. All three names come from the vim package's
  own symlinks and now reach vim -- `EDITOR`, which `common.nix` sets to `vi`,
  among them. Neovim is reached as `nvim`, and its diff mode as `nvim -d`.
