# Roadmap

- [x] Check all tracked files are publishable in Github. Add to AGENTS.md.
- [ ] VirtualBox
- [ ] Color switching without a rebuild: the mode is still a NixOS option, so
      flipping it costs a rebuild and a re-login even though the dotfiles that
      follow it are live
- [ ] Move alacritty to a live dotfile, once colour switching no longer needs
      interpolating -- that and the lack of a system layer are the two reasons
      it is still generated
- [ ] Installation instructions
- [ ] CUDA

### Remove global LD_LIBRARY_PATH (breaks Nix binaries, e.g. Playwright Chromium)

**Problem:** The login environment exports `LD_LIBRARY_PATH` pointing at a Nix store
`alsa-lib-1.2.16.1/lib`. Programs from a different nixpkgs revision load that library
instead of their own and crash on glibc mismatch. Seen with Playwright MCP's Chromium
157 (built on glibc 2.42):
`libm.so.6: version 'GLIBC_2.43' not found (required by …/alsa-lib-1.2.16.1/lib/libasound.so.2)`.
It also leaks into everything started from a shell, including Claude Code and the MCP
servers it spawns.

**Verified:** The same Chromium binary crashes with the variable set and starts with
`env -u LD_LIBRARY_PATH` or with the variable set to empty. The variable is not set by
project dev shells or direnv.

**Todo:**
- [ ] Find where it is exported. Check `environment.variables` / `environment.sessionVariables`,
      Home Manager `home.sessionVariables`, shell rc files, and wrapper scripts, e.g.
      `grep -rn LD_LIBRARY_PATH` over the config repo and `~/.config`, `~/.zshenv`, `~/.zshrc`.
- [ ] Remove it. Whatever needed alsa (probably an audio app or a non-Nix binary) should
      get it through `programs.nix-ld.libraries` (nix-ld is already enabled), a `wrapProgram`
      wrapper, or its own dev shell, not a global variable.
- [ ] After a rebuild and re-login: `echo $LD_LIBRARY_PATH` prints nothing, and Playwright MCP
      launches in a freshly started Claude Code.
- [ ] Afterwards, delete per-project workarounds such as `.claude/settings.local.json` that
      sets `LD_LIBRARY_PATH` to empty (it never reached plugin MCP servers anyway).

### Find out a way to "show" other projects to a jailed agent
- When started in a project, the agent often would benefit in seeing another
  project that might be anywhere in the directory system, typically under
  ~/Code/my/

### Find out a way to manage a global roadmap in my development projects
- There are many of them. How to manage a top-level backlog that sees all
  projects and that I can efficiently use. 
- Use Emacs / Nvim or some desktop or web app? Should also be visible for AI
  agent (client) if requested.
- Often projects development items have priority dependencies that are currently
  only in my head. It is not efficient to list dependencies in each project's
  openspec or ROADMAP.md or such
