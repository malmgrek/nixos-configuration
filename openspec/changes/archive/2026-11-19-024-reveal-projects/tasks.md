# Tasks

## 1. Reveal flags

- [x] 1.1 In `mkJailedAgent` in `home/agent-jail.nix`, consume leading
  `--reveal <dir>` and `--reveal-rw <dir>` arguments, stopping at the first
  other argument and passing the rest to the agent. Open each directory as a
  file descriptor, resolve the descriptor's path, and abort with a message
  naming the path unless it is a directory under `$HOME`, not `$HOME` itself,
  has no hidden component relative to `$HOME`, and is neither the launch
  directory nor inside it. Bind each descriptor with `--ro-bind-fd` or
  `--bind-fd` at its resolved path, shallowest first, with the launch
  directory's bind after them all. With no flags the `bwrap` call must be
  unchanged. Add `pkgs.coreutils` to the wrapper's `runtimeInputs` for
  `realpath`, `readlink` and `sort`.
  Validation: `nix-instantiate '<nixpkgs/nixos>' -A system -I nixos-config=./hosts/spyridon`

- [x] 1.2 Add `tests/reveal.sh`, taking the path of a built `jailed-shell`. It
  creates a fixture tree at the fixed path `tests/reveal-fixture` (cleared
  first, removed on exit, so repeated runs leave one parent tree in the state
  directory): a launch project, a sibling for `--reveal`, a sibling for
  `--reveal-rw`, a nested pair with different access, a hidden directory and a
  symlink to it. It asserts with `jailed-shell ... -c '<test>'` that a
  read-only reveal reads but refuses writes, a writable reveal writes through
  to the host, a revealed parent leaves the project writable, the inner nested
  reveal gets its own access whichever order the flags come in, no descriptor
  inside the session refers to a revealed directory (compared with `-ef`), an
  unrevealed sibling is absent, arguments after the flags reach `bash`, and
  that `$HOME`, a path outside it, a missing path, the hidden directory, the
  symlink to it, a path inside the project and a flag with no path each abort
  with no session started and a message naming the path. Absence checks test
  existence only, never list a directory. Exits non-zero on any failure.
  Validation: `tests/reveal.sh "$(nix-build '<nixpkgs/nixos>' -A system -I nixos-config=./hosts/spyridon --no-out-link)/etc/profiles/per-user/malmgrek/bin/jailed-shell"`

- [x] 1.3 Document `--reveal` and `--reveal-rw` in the README's AI development
  tools section: what each binds, what is refused, and that the operator adds
  the directory to the agent afterwards. Then validate on the real system. This
  needs a `nixos-rebuild switch` and the operator at an unjailed terminal, so it
  cannot run unattended or from inside a session: run the check below against
  the installed wrapper, launch `jailed-claude --reveal <dir>` and confirm that
  `/add-dir <dir>` is accepted and the agent can read a file in it, and after
  exiting confirm the parents created inside `~/.local/state/agent-jail/claude`
  are empty directories.
  Validation: `tests/reveal.sh /etc/profiles/per-user/malmgrek/bin/jailed-shell`

## Unreconciled
