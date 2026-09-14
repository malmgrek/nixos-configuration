# AI configuration library

This directory contains reusable project configuration owned in this
repository. The files are ordinary harness-native resources: nothing here is
installed globally or loaded automatically.

Projects copy only the resources they need and commit those copies. The target
project then owns its configuration and may adapt it independently.

Project Nix shells provide executables required by those native files. They do
not generate harness configuration, wrap harness commands, or write into user
configuration directories.

## Copilot CLI

| Library path | Project destination |
| --- | --- |
| `copilot/agents/*.agent.md` | `.github/agents/` |
| `copilot/skills/<name>/SKILL.md` | `.github/skills/<name>/SKILL.md` |
| `copilot/instructions/*.instructions.md` | `.github/instructions/` |
| `copilot/hooks/*.json` | `.github/hooks/` |
| `copilot/mcp.json` | `.github/mcp.json` |
| `copilot/lsp.json` | `.github/lsp.json` |

The MCP and LSP files are complete examples rather than a custom fragment
format. Remove servers that a project does not need.

### Project-shell packages

Native configuration uses executable names resolved from the project shell:

| Resource | Nix package |
| --- | --- |
| RTK instruction and hook | `pkgs.unstable.rtk` |
| Playwright MCP | `pkgs.unstable.playwright-mcp` |
| Python LSP | `pkgs.unstable.pyright` |
| TypeScript and JavaScript LSP | `pkgs.unstable.typescript-language-server` |
| Scala LSP | `pkgs.unstable.metals` |

The nixpkgs Playwright MCP executable supplies its wrapped browser bundle, so
the MCP configuration does not need a machine-specific Chromium path.

### Common combinations

**Custom plan-driven development** consists of the `spar-and-plan` and
`reviewer` agents plus the `plan-executor` skill. The `grilling` and
`doc-audit` skills remain independently reusable.

**RTK** consists of `instructions/rtk.instructions.md` and `hooks/rtk.json`,
with the RTK package available in the project shell.

**Development tools** consists of the Playwright server in `mcp.json` and the
Python, TypeScript, and Scala servers in `lsp.json`. Projects can retain only
the servers relevant to them.

## Claude Code

| Library path | Project destination |
| --- | --- |
| `claude/agents/*.md` | `.claude/agents/` |
| `claude/skills/<name>/SKILL.md` | `.claude/skills/<name>/SKILL.md` |

The Claude and Copilot variants are independent files even where their current
contents match. This keeps each copy native to its harness and allows the
formats to diverge as their conventions evolve.

Custom plan-driven development uses the `spar-and-plan` and `reviewer` agents
with the `plan-executor` skill. The `grilling` and `doc-audit` skills remain
independently reusable.

## Third-party software

OpenSpec owns the project files produced by `openspec init`; install its
executable in the project shell and let the initialized project track those
files. Third-party Copilot plugins remain owned by Copilot's installation and
update mechanisms. This library does not mirror their source code.

See [`MIGRATION.md`](./MIGRATION.md) before removing globally active harness
resources.
