{ config, lib, pkgs, ... }:

let

  userName = config.customParams.userName;

  # Wrap an agent harness in a bubblewrap mount namespace. A session sees the
  # project directory it was launched from, the Nix store and its own state;
  # the rest of the home directory is absent rather than denied, so secret
  # directories are excluded by default rather than by a blocklist that would
  # need maintaining.
  #
  # The namespace is inherited by every child process, which is what makes
  # ad-hoc `bash`, `npx` and MCP server commands safe without enumerating them.
  #
  # `state` is deliberately separate from `name`: a variant wrapper can keep a
  # sensitive project's history and caches apart by passing a different value.
  mkJailedAgent =
    { name, package, exe, state }:
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = [ pkgs.bubblewrap ];
      text = ''
        stateDir="$HOME/.local/state/agent-jail/${state}"
        mkdir -p "$stateDir"

        # uv's managed interpreters live outside the project, so a venv's
        # bin/python dangles once $HOME is the state directory. Bind that
        # subdirectory alone, keeping the sibling `credentials` out, and skip it
        # when absent: a missing bind source aborts bwrap for every agent.
        uvPythonDir="$HOME/.local/share/uv/python"
        uvPythonBind=()
        if [ -d "$uvPythonDir" ]; then
          uvPythonBind=(--ro-bind "$uvPythonDir" "$uvPythonDir")
        fi

        # /bin, /usr and /lib64 are NixOS's FHS shims, which imperative projects
        # need: `#!/usr/bin/env` and `#!/bin/sh` shebangs, and the nix-ld loader
        # that lets prebuilt non-Nix binaries start at all. Each is a lone
        # symlink into the already-bound store, so nothing new becomes readable.
        exec bwrap \
          --unshare-all --share-net --die-with-parent \
          --ro-bind /nix/store /nix/store \
          --ro-bind /run/current-system /run/current-system \
          --ro-bind /etc /etc \
          --ro-bind /bin /bin \
          --ro-bind /usr /usr \
          --ro-bind /lib64 /lib64 \
          --ro-bind /run/systemd/resolve /run/systemd/resolve \
          --ro-bind /nix/var/nix/daemon-socket/socket /nix/var/nix/daemon-socket/socket \
          --ro-bind /nix/var/nix/profiles /nix/var/nix/profiles \
          --proc /proc \
          --dev /dev \
          --size 2147483648 --tmpfs /dev/shm \
          --tmpfs /tmp \
          --bind "$stateDir" "$HOME" \
          --ro-bind "$HOME/.nix-profile" "$HOME/.nix-profile" \
          --ro-bind "$HOME/.local/state/nix/profile" "$HOME/.local/state/nix/profile" \
          "''${uvPythonBind[@]}" \
          --setenv NIX_REMOTE daemon \
          --bind "$PWD" "$PWD" \
          --chdir "$PWD" \
          -- ${lib.getExe' package exe} "$@"
      '';
    };

in

{

  # Additive: `claude`, `copilot` and `opencode` keep their current behaviour,
  # and the jail is opted into per invocation by typing a different name.
  #
  # Importing this module is the on switch; drop it from `home/default.nix` to
  # turn the feature off, as with the other optional modules there.
  home-manager.users.${userName}.home.packages = [

    (mkJailedAgent {
      name = "jailed-claude";
      package = pkgs.unstable.claude-code;
      exe = "claude";
      state = "claude";
    })

    (mkJailedAgent {
      name = "jailed-copilot";
      package = pkgs.unstable.github-copilot-cli;
      exe = "copilot";
      state = "copilot";
    })

    (mkJailedAgent {
      name = "jailed-opencode";
      package = pkgs.unstable.opencode;
      exe = "opencode";
      state = "opencode";
    })

    # Verification surface: the same code path as the agents, driven by plain
    # shell commands.
    (mkJailedAgent {
      name = "jailed-shell";
      package = pkgs.bashInteractive;
      exe = "bash";
      state = "shell";
    })

  ];

}
