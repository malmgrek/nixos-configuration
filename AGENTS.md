<!-- Append into the project's AGENTS.md (CLAUDE.md symlinks to it). -->

## Guidance for AI Assistants

- **Stay inside the project directory.** Read and write nothing above it, and run
  nothing that reaches above it. A task that appears to need an outside path is a
  task to stop and ask about, unless the path is listed under Path exceptions
  below.
- **Never read secrets into context.** `.env`, keyfiles, tokens, credentials: not
  read, not copied, not echoed into a file, a diff, or a commit message. Write a
  placeholder and say which value a human has to fill in.
- **Nothing leaves the machine unasked.** No new network calls, no installs from a
  registry, no posting project content to an external service unless the task
  asked for it.
- **A known gap is a thing to fix, not a baseline.** Never cite an existing
  weakness as grounds for introducing another, and do not design down to the
  level an existing gap has set. That a gap is already public makes it no more
  acceptable. If one blocks the task, say so and stop.
- **Keep exploration compact.** Present findings as at most five bullets, then
  one question. Flag the bullet you are least confident in. Detail on request —
  a wall of text costs more to read than it saves to write.
- **Don't hand-edit generated workflow files.** The `openspec-*` skills and
  `.claude/commands/opsx/*` come from the `openspec` CLI; run `openspec update`
  rather than editing them, or the next update silently reverts you. Project
  tuning belongs in `openspec/config.yaml` and the agents under `.claude/agents/`.

### Path exceptions

Paths outside the project the agent may use, and how far. Empty means no
exceptions: the project directory is the whole world.

| Path | Access | Why |
| ---- | ------ | --- |
|      |        |     |

`Access` is `read` or `read+write`. A path absent from this table is forbidden
even if a similar one is present.

<!-- Deliberately no pointer back to the agent-workflow repository. A project's
     AGENTS.md is written for a stranger reading the project; a path to a private
     repo on one machine is unfollowable by them and unactionable by an agent.
     The upstream-first habit is the maintainer's, and it is stated in this
     repository's own README instead. -->
