# Proposal

## Why

Editor completion and chat run on GitHub Copilot, so buffer contents leave the
machine. The temporary guards making that safer are glue against plugin
internals that an update can silently break. If editor AI can reach only a
server on this machine, nothing is left to guard.

## What Changes

- Inline completion in both editors moves to minuet (`minuet.el`,
  `minuet-ai.nvim`) on the local server's chat endpoint. It is off when the
  editor starts, and one toggle turns automatic suggestions on for the rest of
  the session.
- gptel keeps one backend, the local server. **BREAKING**: the Copilot and
  Ollama backends go, and the OpenAI key reader goes with them.
- CodeCompanion replaces CopilotChat in Neovim, on the same server.
- The server's address and model name are declared once as session variables.
  Its API key is read at runtime from a file outside both the repository and
  the store. The configuration names only the file's path.
- **BREAKING**: copilot.el, copilot.lua, CopilotChat, `copilot-language-server`
  and the temporary guards are removed.

## Capabilities

### New Capabilities

- `editor-llm`: where the editors' AI features may send buffer contents, when
  they send anything at all, and where the credential for that comes from.

### Modified Capabilities

None. The editor configurations stay live under `dotfiles`. The new session
variables are declared options, which `dotfiles` already places outside its
boundary.

## Impact

`config/doom/{config,packages}.el`, `config/nvim/lua/plugins/` and
`config/nvim/lua/config/lazy.lua`, the package list and session variables in
`home/default.nix`, and `lazy-lock.json`.

Out of scope, with reasons:
- Terminal AI tools send only what they are explicitly given.
- The local server runs outside this configuration.
- The Ollama service stays; removing it is a separate decision.
