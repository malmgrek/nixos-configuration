## 1. Mechanical substitutions

- [x] 1.1 Replace `home-manager.users.<name>.home.packages` with
      `users.users.<name>.packages` in every module that declares it, keeping
      each module's own list where it is. `home/agent-jail.nix` is among them,
      so its wrappers change declaration site without changing what they do.

      Two deliberate departures the operator made while this change was open:
      `home/opencode.nix` was folded into `home/ai.nix` rather than keeping each
      module's own list where it is, and `unstable.pi-coding-agent` was added.
      Neither is part of dropping home-manager; both are recorded here because
      the task said the lists stay put.
      Validation: `! grep -rn 'home\.packages' home/ && nix-instantiate '<nixpkgs/nixos>' -A system -I nixos-config=./hosts/spyridon`

- [x] 1.2 Move `home.sessionVariables` to `environment.sessionVariables`: the
      two Playwright variables in `home/ai.nix`, and `EDITOR` out of
      `home/neovim.nix` altogether so that `common.nix` is its only declaration
      site. Moving `EDITOR` as a `mkDefault` cannot work -- `common.nix` sets it
      as a plain value, which wins -- and the effective value in a shell
      therefore changes from `nvim`, which home-manager's session file supplied,
      to whatever `common.nix` says. The operator chose `vim` as the most basic
      of the three -- unconfigured, per design decision 8 -- so
      `common.nix` names it and a comment there says it is the only declaration.
      Validation: `nix-instantiate --eval '<nixpkgs/nixos>' -A config.environment.sessionVariables.EDITOR -I nixos-config=./hosts/spyridon`

- [x] 1.3 Replace `home.file.".npm-global/.keep"` with a tmpfiles rule in
      `home/dotfiles.nix` creating the directory, so `npm install -g` still has
      somewhere to write.
      Validation: `nix-instantiate --eval --strict '<nixpkgs/nixos>' -A config.systemd.user.tmpfiles.users.malmgrek.rules -I nixos-config=./hosts/spyridon | grep -F '.npm-global'`

- [x] 1.4 Replace `xdg.mimeApps` with `xdg.mime.defaultApplications`, keeping
      the same associations. Note in the module that a `~/.config/mimeapps.list`
      overrides the generated `/etc/xdg/mimeapps.list` per MIME type rather than
      wholesale, and that such a file was written by an application rather than
      left by home-manager, so it may carry live associations and is to be read
      rather than deleted.
      Validation: `nix-instantiate --eval --strict '<nixpkgs/nixos>' -A config.xdg.mime.defaultApplications -I nixos-config=./hosts/spyridon | grep -F 'gvim.desktop'`

- [x] 1.5 Replace the `programs.firefox` block with `firefox` in the per-user
      package set beside chromium, dropping its two preferences and its
      `configPath` per design decision 6.
      Validation: `nix-instantiate --eval '<nixpkgs/nixos>' -A config.home-manager.users.malmgrek.programs.firefox.enable -I nixos-config=./hosts/spyridon` -- expect false. A grep for "programs.firefox" never matched, the block being nested under `programs = {`.

- [x] 1.6 Move `programs.{direnv,fzf,autojump}` to the NixOS modules of the same
      names, dropping each `enableZshIntegration` -- the NixOS modules inject
      their hooks into `/etc/zshrc` themselves.
      Validation: `nix-instantiate --eval --strict '<nixpkgs/nixos>' -A config.programs.zsh.interactiveShellInit -I nixos-config=./hosts/spyridon | grep -c direnv`

- [x] 1.7 Move `programs.neovim` to the NixOS module and its `extraPackages` to
      the per-user package set. Drop `sideloadInitLua`, which that module does
      not have and does not need: it writes nothing into the home directory, so
      the collision 019 hit cannot recur. Every provider and alias flag there
      defaults to false, the opposite of home-manager, so the three providers
      must be set explicitly to keep working.
      Validation: `test "$(dirname "$(dirname "$(readlink "$(nix-build '<nixpkgs/nixos>' -A config.system.path -I nixos-config=./hosts/spyridon --no-out-link)/bin/nvim")")")" = "$(nix-build '<nixpkgs/nixos>' -A config.programs.neovim.finalPackage -I nixos-config=./hosts/spyridon --no-out-link)" && echo same` -- the profile's `bin/nvim` must resolve into `finalPackage` itself. Reading `finalPackage` alone proves only what the module intends to build; it cannot see which provider the profile serves, which is what task 1.9 had to fix.

- [x] 1.8 Replace plain `vim` with `vim-full` in `environment.systemPackages`
      and delete `home/vim.nix`, its import in `home/default.nix` and
      `config/vim/extra.vimrc`. Per design decision 8 vim keeps no
      configuration, and one package providing all four names is what removes
      the `bin/vim` collision rather than resolving it. `vim-full` for `gvim`,
      which the mime associations open, and for `+clipboard`.
      Validation: `nix-build '<nixpkgs/nixos>' -A config.system.path -I nixos-config=./hosts/spyridon --no-out-link | xargs -I{} sh -c 'for b in vim vi vimdiff gvim; do dirname "$(readlink {}/bin/$b)"; done | sort -u | wc -l'` -- expect 1, all four names from one package. Deduplicating the link targets instead gives 4 whatever the answer, since each name resolves to its own file; it is the one `bin` directory that proves no collision is being resolved by chance.

- [x] 1.9 Remove plain `neovim` from `environment.systemPackages` in
      `common.nix`, leaving `programs.neovim`'s wrapper the only provider of
      `bin/nvim`. Both were in one profile after 1.7, and `buildEnv` resolved
      the collision in favour of the plain one, so `withNodeJs`, `withPython3`
      and `withRuby` reached nothing: the wrapper carrying
      `nvim-host-python3-*-env`, `neovim-ruby-env` and `node-client` was built
      and then not used. The same two-providers-in-one-profile fault as 1.8,
      ten lines away in the same list, and an instance of the class design
      decision 13 names. Both packages ship only `bin/nvim` and `nvim.desktop`,
      so nothing
      is lost by dropping one.
      Validation: `test "$(dirname "$(dirname "$(readlink "$(nix-build '<nixpkgs/nixos>' -A config.system.path -I nixos-config=./hosts/spyridon --no-out-link)/bin/nvim")")")" = "$(nix-build '<nixpkgs/nixos>' -A config.programs.neovim.finalPackage -I nixos-config=./hosts/spyridon --no-out-link)" && echo same` -- the same check task 1.7 now carries, repeated rather than cross-referenced so the list runs from a clone.

## 2. tmux

- [x] 2.1 Move the tmux settings into `config/tmux/tmux.conf` with the dark
      theme inline and a comment naming 021 as what makes it switchable, link
      the directory in `home/dotfiles.nix`, and leave only
      `programs.tmux.plugins` at the NixOS level writing `/etc/tmux.conf`.
      Requires 1.1, the plugin list moving with it.
      Validation: `nix-instantiate --eval --strict '<nixpkgs/nixos>' -A config.environment.etc."tmux.conf".text -I nixos-config=./hosts/spyridon | grep -F 'run-shell'`

## 3. alacritty, zsh, and the end of home-manager

- [x] 3.0 Generate alacritty's configuration into the store and link
      `~/.config/alacritty/alacritty.toml` at it, per design decision 9: its
      search path is `$XDG_CONFIG_HOME` only, so there is no system layer to put
      it in, and after 3.4 nothing else writes into the home directory. Keep
      the `lightMode` interpolation, the font and the padding; this is the one
      file 020 leaves generated.

      Remove `home-manager.users.<name>.programs.alacritty` in the same step.
      Home-manager still generates that exact path until 3.4, and two
      declarations of it abort the switch rather than warning: both backup
      branches in `check-link-targets.sh` are gated on the path not being a
      symlink, so neither `backupFileExtension` nor `backupCommand` can rescue
      a tmpfiles link. This is decision 11's rule arriving four tasks early.

      Two details the implementer should not have to re-derive. The spec
      requires each member of the generated set to carry, where it is declared,
      the reason it is in that set -- `home/alacritty.nix` has that comment
      today and it moves with the declaration. And `home/dotfiles.nix`'s `link`
      helper hardcodes a working-tree directory target and promises in its
      comment that the application's file and the working tree's are one file;
      this rule is a file pointing into the store, so that comment needs
      qualifying. The rule itself goes in `home/alacritty.nix`, not
      `home/dotfiles.nix`: it names a store path only that module can produce,
      and plumbing it across modules would buy nothing. `systemd.user.tmpfiles`
      still finds every link, which is the property that matters.
      Validation: `nix-build '<nixpkgs/nixos>' -A system -I nixos-config=./hosts/spyridon --no-out-link >/dev/null && nix-instantiate --eval --strict '<nixpkgs/nixos>' -A config.systemd.user.tmpfiles.users.malmgrek.rules -I nixos-config=./hosts/spyridon | grep -oE '/nix/store/[a-z0-9]+-alacritty[^ "]*' | head -1 | xargs grep -F 'background = "#282c34"'` -- the build is what realises the target, since `--eval` yields a path string with no derivation registered and `nix-store -r` on it fails with "no substituter can build it". Grep the assignment, not the bare hash: `#282c34` is also `doomOne.light.foreground`, so a naked hash passes for either palette.


- [x] 3.1 Declare the five plugins as nixpkgs packages, each through whichever
      NixOS option it has rather than all through one: `autosuggestions.enable`
      and `syntaxHighlighting.enable` have modules of their own, autopair is a
      plain `source` in `programs.zsh.interactiveShellInit`, pure goes through
      `promptInit`, and `zsh-completions` is a per-user package found on `fpath`
      through `NIX_PROFILES`. So `/etc/zshrc` carries every store path and the
      five `fetchFromGitHub` blocks can go. Syntax-highlighting has to be last
      in the sourcing order and puts itself there with `mkAfter`.
      The prompt goes through `programs.zsh.promptInit`, not
      `interactiveShellInit`: the module renders promptInit later in
      `/etc/zshrc` and its default is `prompt suse`, which replaces pure while
      leaving pure's hooks installed.
      Validation: `nix-instantiate --eval '<nixpkgs/nixos>' -A config.programs.zsh.promptInit -I nixos-config=./hosts/spyridon | grep -F 'prompt pure'` and, on the built system, `grep -c 'prompt suse' $(readlink -f <system>/etc)/zshrc` -- expect 0. Counting plugin names in `interactiveShellInit` proves nothing: `zsh-completions` is a package now and never appears there, so a count passes with plugins missing.

- [x] 3.2 Set `ZDOTDIR` through `programs.zsh.shellInit` per design decision 3,
      so `/etc/zshenv` points zsh at `~/.config/zsh` with no bootstrap file in
      the home directory.
      Validation: `nix-instantiate --eval --strict '<nixpkgs/nixos>' -A config.environment.etc.zshenv.text -I nixos-config=./hosts/spyridon | grep -F 'ZDOTDIR'`

- [x] 3.3 Write `config/zsh/.zshenv` and `config/zsh/.zshrc` carrying what
      `home/zsh.nix` expressed as options -- aliases, history, `viins`,
      `autoload zmv`, the `TERM`/`LS_COLORS`/`KEYTIMEOUT` exports -- and the two
      `home.sessionPath` entries prepended to `path` in `.zshenv`, not `.zshrc`,
      per design decision 4. Prepended because `hm-session-vars.sh` did, so what
      `npm install -g` puts in the prefix still wins over a profile copy; and
      with `typeset -U path`, since nothing in `/etc` declares those arrays
      unique and `.zshenv` runs for every zsh. History is the one value carried
      somewhere else on purpose, to `$XDG_STATE_HOME/zsh/history`, per design
      decision 12.

      Delete the `home-manager.users` blocks they came out of, in
      `home/default.nix` and `home/doom-emacs.nix`, rather than leaving empty
      ones for 3.4 to trip over.
      Validation: `grep -q 'npm-global' config/zsh/.zshenv && grep -q 'emacs/bin' config/zsh/.zshenv`

- [x] 3.4 In one step: link `config/zsh` in `home/dotfiles.nix`, delete the
      home-manager block in `home/zsh.nix` -- not the file, which by now holds
      that module's NixOS replacement -- and remove the `<home-manager/nixos>`
      import,
      `useGlobalPkgs`, `stateVersion` and `xdg.enable`. Design decision 11
      requires these together -- a link placed while home-manager still manages
      that directory reproduces the collision that broke neovim. This is the
      point of no return; it should follow a working rebuild of sections 1
      and 2.

      Remove `home/xsession.nix`'s `home.pointerCursor` block here too, not in
      4.1: the import cannot go while any `home-manager.users` declaration
      remains, or evaluation fails with "option does not exist". The cursor
      falls back to its default between this task and 4.1, which no switch
      observes because section 5 is the only one.

      Add `config/zsh/.gitignore` in the same step. Pointing `ZDOTDIR` at the
      working tree makes `compinit` deposit `.zcompdump` there -- its default is
      `${ZDOTDIR:-$HOME}/.zcompdump` -- and the capability requires churn in a
      live directory to be excluded.
      Validation: `! grep -rnE '^\s*(home-manager\.|<home-manager)' home/ *.nix && nix-instantiate '<nixpkgs/nixos>' -A system -I nixos-config=./hosts/spyridon` -- line-initial declarations only. Six comments across `home/` and `common.nix` name home-manager, five of them required by tasks 1.2, 1.4 and 1.8, and a pattern matching the word anywhere -- or even `home-manager.` anywhere -- forbids them.

## 4. Cursor

- [x] 4.1 Replace `home.pointerCursor` with the four pieces design decision 7
      names: the theme package in the per-user set, `XCURSOR_THEME` and
      `XCURSOR_SIZE` in `environment.sessionVariables`, a derivation providing
      `share/icons/default/index.theme` inheriting the theme, and the
      `Xcursor.theme`/`Xcursor.size` resources in an `xrdb` merge of their own
      in `home/xsession.nix` -- not appended to the one in `options.nix`, which
      is gated on `customParams.dpi` being non-null and would make the cursor
      resources exist on one host only and vanish if that knob were unset.
      `sessionCommands` is lines, so the two merges concatenate. This restores
      the cursor 3.4 left at its default. Then delete
      any module left holding nothing. The directory itself stays: by this point
      its files carry NixOS-level configuration, comments in
      `config/tmux/tmux.conf` and `home/tmux.nix` name paths inside it, and
      nothing in this change decides a destination for them. Only its character
      as a home-manager unit goes.
      Validation: `nix-instantiate --eval --strict '<nixpkgs/nixos>' -A config.environment.sessionVariables.XCURSOR_THEME -I nixos-config=./hosts/spyridon` -- expect the theme name.

- [x] 4.2 Bring `README.md` up to date on four claims it now gets wrong: that
      home-manager manages the user environment and `./home/` "can be disabled
      completely" (line 49), that four directories under `./config/` are live
      (53, now six), that "Alacritty's, tmux's and zsh's" configurations are
      generated (62, now only alacritty's), and the open checklist item "Get rid
      of Home Manager" (110), which this change is. The proposal calls the first
      BREAKING for anyone cloning. Naming home-manager in the past tense is
      fine -- the point is that no claim about the present is false.
      Validation: `! grep -q 'can be disabled completely' README.md && ! grep -q "Alacritty's, tmux's" README.md && ! grep -q 'Four directories' README.md && ! grep -q '\[ \] Get rid of Home Manager' README.md`

## 5. Verification that evaluation cannot cover

- [x] 5.1 After a `nixos-rebuild switch` and a fresh login, confirm from an
      unjailed shell that the layering holds: a new zsh has the plugins, the
      prompt and both `path+=` entries; `vim`, `vi`, `vimdiff` and `gvim` are
      all unconfigured `vim-full`, per design decision 8; tmux has its
      plugins and theme; the cursor is unchanged; and
      `systemctl status home-manager-malmgrek.service` reports the unit gone
      rather than failed. Then check `~/.nix-profile`: removing the module
      removes the activation service, so home-manager's own profile is never
      deactivated, and `$HOME/.nix-profile/bin` stays ahead of
      `/etc/profiles/per-user/<name>/bin` in PATH -- leaving pre-020 copies of
      the packages task 1.1 moved shadowing the new ones indefinitely.

      Record `echo $XCURSOR_PATH | tr : '\n' | grep -n icons` and then delete
      `~/.icons`, `~/.local/share/icons/default` and `~/.Xresources` before
      checking the cursor. Home-manager left all three behind and their contents
      are identical to what 4.1 declares, so "the cursor is unchanged" would
      otherwise pass off the leftovers whether or not the new declaration works.
      The second is easy to miss -- `home.pointerCursor` set only `x11.enable`,
      yet wrote `~/.local/share/icons/default/index.theme` as well, and that
      path precedes the profiles too, so deleting `~/.icons` alone leaves the
      leftover still answering. Recording the path first settles from the
      system, rather than by inference, where each sits relative to the per-user
      profile.

      Before switching, list both `~/.config/mozilla/firefox` and
      `~/.mozilla/firefox`: design decision 6
      records that `profiles.ini` went with the module and that firefox will
      create a fresh profile, leaving any existing one unreferenced rather than
      deleted. Nothing else in this change checks it, and it is the only item
      here whose failure reads as "my bookmarks are gone". Both roots, because a
      firefox predating native XDG support used `~/.mozilla/firefox`, so listing
      only the XDG one can show a lone generated `profiles.ini` and read as "no
      profile to lose" while the real one sits in the other. Afterwards, confirm
      firefox opens on its own profile or that the old directory's path is
      known.

      Open a terminal too: alacritty is the one configuration still generated,
      its delivery changed from a regular file to a link into the store, and
      nothing so far has resolved `~/.config/alacritty/alacritty.toml` in a live
      home. It should start with the dark palette. And `xdg-open` a `.py` file,
      since task 1.4's association now comes from `/etc/xdg/mimeapps.list` and
      any `~/.config/mimeapps.list` overrides it per type.

      Each of these needs a session that started after the switch, which no
      evaluation check can stand in for.
      Validation: none -- requires a display, a login and the operator.

## 6. A privileged surface the tmux module brings

- [x] 6.1 Set `programs.tmux.withUtempter = false` in `home/tmux.nix`. The
      option defaults true and adds a setgid-`utmp` wrapper this system does not
      otherwise have, so that `who` lists tmux panes -- a privileged surface for
      a feature nothing here uses, and no other wrapper on this system is in
      the `utmp` group. This section exists because it is the one thing the
      reconciled ledger asked for work on; its other entries are recorded in
      design decisions 7 and 12, in the two Risks bullets on home-manager's
      profile and on `nix-direnv`, and in the note on tmux's plugins under what
      this makes true of the built system.
      Validation: `nix-instantiate --eval --strict '<nixpkgs/nixos>' -A config.security.wrappers -I nixos-config=./hosts/spyridon | grep -c utmp` -- expect 0. Reading `config.programs.tmux.withUtempter` back as false only restates the assignment; the wrapper set is what the option was adding to.

## Unreconciled
