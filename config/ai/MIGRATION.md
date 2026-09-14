# Manual migration

Move to project-owned configuration gradually. First copy the required library
resources into one project, add their executables to that project's Nix shell,
and confirm the project behaves correctly. Only then archive equivalent global
resources.

## Behavioral resources to review

Copilot CLI may load behavior from:

- `~/.github/copilot-instructions.md`
- `~/.github/hooks/`
- `~/.copilot/copilot-instructions.md`
- `~/.copilot/agents/`
- `~/.copilot/skills/`
- `~/.copilot/instructions/`
- `~/.copilot/hooks/`
- `~/.copilot/mcp-config.json`
- `~/.copilot/lsp-config.json`
- globally installed or enabled Copilot plugins

Claude Code may load behavior from:

- `~/.claude/CLAUDE.md`
- `~/.claude/agents/`
- `~/.claude/skills/`
- hooks, MCP servers, or plugins declared in `~/.claude/settings.json`
- globally installed or enabled Claude plugins

Review these locations rather than assuming every listed path exists. Preserve
anything reusable in `config/ai/` before archiving it. Do not copy credentials
or secret-bearing MCP values into this repository.

## Runtime state to protect

Do not treat the whole `~/.copilot` or `~/.claude` directory as disposable.
They can also contain:

- authentication and credential files;
- user preferences and permissions;
- installed-plugin state;
- conversation history and session databases;
- logs, caches, downloaded runtimes, and update state.

Deleting either directory can require reauthentication and can destroy local
history. If a clean reset is eventually desired, back up the complete
directory first and understand which state the harness will recreate.

## Deployment checklist

1. Select a project and commit the native Copilot or Claude resources it needs.
2. Add required commands such as `rtk`, `playwright-mcp`, `pyright-langserver`,
   `typescript-language-server`, or `metals` to its Nix shell.
3. Enter a fresh project shell and confirm agents, skills, instructions, hooks,
   MCP servers, and LSP servers that the project selected.
4. Archive only the equivalent global behavioral resources.
5. Start each harness outside configured projects and confirm that no custom
   agents, skills, instructions, hooks, MCP servers, LSP servers, or plugins
   remain active unintentionally.
6. Repeat for other projects before retiring additional global resources.

This repository does not perform any of these home-directory changes.
