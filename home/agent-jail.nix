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
      runtimeInputs = [ pkgs.bubblewrap pkgs.coreutils ];
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

        # Leading --reveal/--reveal-rw flags bind further directories. Each is
        # judged and bound through one open descriptor, so a path swapped for a
        # symlink after the check cannot change what gets bound.
        refuse() { echo "''${0##*/}: refusing to reveal $1: $2" >&2; exit 1; }
        home=$(realpath -e "$HOME")
        project=$(pwd -P)
        revealFds=(); revealModes=(); revealPaths=(); revealDepths=()
        while [ $# -gt 0 ]; do
          case "$1" in
            --reveal) mode=--ro-bind-fd ;;
            --reveal-rw) mode=--bind-fd ;;
            *) break ;;
          esac
          [ $# -ge 2 ] || refuse "(nothing)" "$1 needs a directory"
          [ -d "$2" ] || refuse "$2" "not an existing directory"
          exec {fd}<"$2"
          path=$(readlink "/proc/$$/fd/$fd")
          [ -d "/proc/$$/fd/$fd" ] || refuse "$2" "not a directory"
          case "$path" in
            "$home"/*) ;;
            *) refuse "$2" "resolves to $path, not inside $home" ;;
          esac
          case "/''${path#"$home"/}" in
            */.*) refuse "$2" "resolves to $path, which has a hidden component" ;;
          esac
          case "$path/" in
            "$project"/*) refuse "$2" "resolves to $path, inside the project" ;;
          esac
          slashes=''${path//[!\/]/}
          revealFds+=("$fd"); revealModes+=("$mode"); revealPaths+=("$path")
          revealDepths+=("''${#slashes}")
          shift 2
        done

        # Shallowest first, so the most specific reveal wins; the project is
        # bound after all of them so it stays writable under a revealed parent.
        revealBinds=()
        for depth in $(printf '%s\n' "''${revealDepths[@]}" | sort -nu); do
          for i in "''${!revealFds[@]}"; do
            if [ "''${revealDepths[$i]}" = "$depth" ]; then
              revealBinds+=("''${revealModes[$i]}" "''${revealFds[$i]}" "''${revealPaths[$i]}")
            fi
          done
        done

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
          "''${revealBinds[@]}" \
          --bind "$PWD" "$PWD" \
          --chdir "$PWD" \
          -- ${lib.getExe' package exe} "$@"
      '';
    };

in

{

  # Declared here, beside the daemon-socket bind it protects: a trusted caller
  # can make the root daemon act for it, so trusting this user would undo the
  # jail. Duplicating the nixpkgs default is deliberate -- a grep now lands on
  # this comment. Neither mkDefault (filtered out by the default) nor mkForce
  # (blocks a legitimate unrelated trusted user) belongs here.
  nix.settings.trusted-users = [ "root" ];

  # Checked by tests/trusted-users.nix, which grants the trust by each route
  # this reads and requires this assertion to be the one that fails.
  #
  # The declaration documents the premise; this enforces it. Both settings are
  # lists that merge rather than conflict, so a grant added elsewhere would
  # otherwise be silent. Scoped to this user, so an unrelated trusted user
  # stays possible.
  assertions = [
    {
      assertion =
        let
          # extra-trusted-users appends without touching trusted-users, so
          # count both. nix.settings is freeform and nix.conf splits these
          # values on whitespace, so a single string may name several users:
          # compare words, not elements.
          words = v: lib.filter (w: w != "") (lib.concatMap
            (e: if lib.isString e
                then lib.filter lib.isString (builtins.split "[[:space:]]+" e)
                else [ ])
            (lib.toList v));
          trusted = words config.nix.settings.trusted-users
            ++ words (config.nix.settings.extra-trusted-users or [ ]);
          user = config.users.users.${userName};
          # Group membership is grantable from either side -- the user's
          # extraGroups or a group's members list (see home/virtualbox.nix) --
          # and neither covers the other, so read both.
          groups = [ user.group ] ++ user.extraGroups
            ++ lib.attrNames
              (lib.filterAttrs (_: g: lib.elem userName g.members)
                config.users.groups);
        in
        !(lib.elem userName trusted)
        && !(lib.any (g: lib.elem "@${g}" trusted) groups);
      message = ''
        ${userName} is a trusted user of the Nix daemon -- named directly,
        through a group, or through a setting that appends to the trusted set.
        That removes the protection home/agent-jail.nix depends on: the jail
        binds the daemon socket, and a trusted caller can make the root daemon
        act for it -- which Nix documents as equivalent to root access.

        This is a change to the agent-jail capability, not a convenience. If you
        need it, decide in openspec/specs/agent-jail what replaces the
        guarantee -- do not reach for this assertion first.
      '';
    }
  ];

  # Additive: `claude`, `copilot` and `opencode` keep their current behaviour,
  # and the jail is opted into per invocation by typing a different name.
  #
  # Importing this module is the on switch; drop it from `home/default.nix` to
  # turn the feature off, as with the other optional modules there.
  users.users.${userName}.packages = [

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
