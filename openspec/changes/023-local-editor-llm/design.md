# Design

## Decisions

| # | Decision | Why |
| - | -------- | --- |
| 1 | Three session variables: `LOCAL_LLM_BASE_URL`, `LOCAL_LLM_MODEL`, `LOCAL_LLM_API_KEY_FILE` | One declaration for both editors. Session variables are read before any shell, so editors started from the desktop see them too. |
| 2 | The base URL keeps the OpenAI form, ending in `/v1` | Every client takes that form, or splits it in one line. A variable cut to suit one client would need re-joining in the others. |
| 3 | The key is read from its file on each request, never exported | A key in the environment is visible to every process the session starts. Reading per request also means replacing the key file needs no restart. |
| 4 | Completion uses minuet in both editors, on the chat endpoint | The two minuet ports share one configuration model. The server offers chat and no fill-in-the-middle endpoint, and minuet supports chat-based completion. |
| 5 | Completion is off by default, with one session-wide toggle | This meets the spec with no attach logic of our own. In Neovim the plugin is not loaded until the toggle, so an idle session runs none of its code. |
| 6 | gptel has one backend and `gptel-use-tools nil` | gptel defaults tools on. Without a tools setting, a tool added later by any package would reach the model. |
| 7 | CodeCompanion replaces CopilotChat, with its tools disabled | It is the chat plugin with an OpenAI-compatible adapter, and its tools are opt-in. With them disabled, chat matches gptel's no-tools behaviour. |
| 8 | All GitHub Copilot editor code goes, including the temporary guards | Nothing left can send to Copilot, so the guards protect nothing and become dead code waiting to break on update. |

## Context

See `proposal.md` -- Why. The constraints that shape the approach:

- The server is OpenAI-compatible and offers `/v1/chat/completions` and
  `/v1/responses`, with no fill-in-the-middle endpoint. It requires an API key.
- `config/doom` and `config/nvim` are live directories under `dotfiles`. Their
  edits take effect on the editor's next start, without a rebuild.
- Session variables are already declared in `home/default.nix` through
  `environment.sessionVariables`. pam_env reads them at login, so a change needs
  a new login, not only a rebuild.

## Goals / Non-Goals

**Goals:**

- No editor configuration names a host, a model or a key.
- An idle editor makes no requests at all, whether or not the server is up.

**Non-Goals:**

- Checking whether the server is reachable before loading anything. A request to
  a closed port on the loopback interface fails at once, and requests happen
  only after the operator turns a feature on. A check would cost more than the
  failure it avoids.
- Per-buffer opt-in. Everything stays on this machine, so session scope is a
  convenience choice, not a security one.

## Where it reaches the built system

- `home/default.nix` declares the three variables in
  `environment.sessionVariables`. Grep `LOCAL_LLM_` to find them and every
  consumer. If that block were removed, the editors would still start, and every
  AI request would fail visibly for lack of an address. Nothing would fall back
  to another host, because no other host is configured.
- `copilot-language-server` leaves the package list in `home/default.nix`. After
  a rebuild, `command -v copilot-language-server` finds nothing.
- The editor decisions live in `config/doom/config.el`, `config/doom/packages.el`
  and `config/nvim/lua/plugins/`. Without them, a reader would find gptel or
  minuet pointed at a hard-coded address or at a cloud default.

## Risks / Trade-offs

- [A GUI editor started before the next login lacks the variables] -> The tasks
  check the variables inside a desktop-launched editor, after logging out and
  back in.
- [minuet's session-wide toggle may not be a single built-in command in one of
  the ports] -> If it is not, the fallback is a few lines turning the per-buffer
  mode on for buffers opened while the toggle is set. The spec does not change
  either way.
- [A local model completes worse and slower than Copilot] -> Accepted. It is the
  price of the boundary in the spec.
- [The server forwards requests elsewhere] -> Outside the editors' sight; the
  spec states where the boundary stops.

## Migration Plan

1. The operator creates the key file, readable only by them, at the path
   `LOCAL_LLM_API_KEY_FILE` names.
2. Rebuild, log out and back in, run `doom sync`, and let lazy.nvim install the
   new plugins and clean the removed ones.
3. Rollback: revert the branch, rebuild, and run `doom sync`. The key file
   stays and harms nothing.

## Open Questions

- The exact name of each minuet port's session toggle, and of CodeCompanion's
  setting that disables tools. Confirm both against the installed plugin
  versions during implementation. Neither changes the spec or the tasks.
