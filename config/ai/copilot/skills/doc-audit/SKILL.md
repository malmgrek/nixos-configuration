---
name: doc-audit
description: Sweep a codebase's comments and markdown docs (excluding plans/ or another planning/decision-log folder) for duplication, plan/task references, dev-diary narration, and other violations of durable-comment conventions; fix them directly and report a summary. Use when asked to clean up, audit, or streamline comments/documentation, or to remove stale/redundant natural-language content after a feature push or before a history rewrite.
---

# Doc Audit

A mechanical cleanup pass over a repo's natural-language content — code comments,
docstrings, and markdown docs — checking it against the durable-comment conventions
most CLAUDE.md files already state (short, essential, timeless; no duplication; no
development-diary narration; no comments substituting for documentation). This is not
a rewrite: preserve every genuine fact, only remove noise, duplication and
non-timeless framing.

## Scope

- Default to the whole repo. If the user names a path, scope to that.
- **Exclude** the project's planning/decision-log folder if it has one (commonly
  `plans/`) — those are historical records by design and are expected to name
  specific tasks and decisions. Check the project's own CLAUDE.md for the actual
  folder name and any other stated exception before assuming `plans/`.
- **Exclude** vendored/generated noise: `node_modules`, `.venv`, `dist`, `build`,
  lockfiles, `.git`.
- **Include** migration files' comments (they're committed, real prose) but never
  touch migration *logic* — comment-only edits there.
- Candidate files: every markdown file in scope, plus every source file containing
  comments/docstrings (language-agnostic — infer extensions from the repo).

## What counts as a violation

1. **Plan/task/decision citations as justification** — e.g. `"(plan 017 Decision
   13)"`, `"Task 09 makes X derive Y"`, `"Correction (found during Task 17's
   implementation)"`. Strip the citation, keep the substantive rule as a standalone
   timeless statement. When the citation is grammatically load-bearing (the sentence's
   subject, not just an appended parenthetical), rewrite the sentence as a plain
   declarative statement about current behavior — don't just delete words and leave a
   dangling clause. This was confirmed as the intended policy for this project even
   though the pattern is large-scale and clearly deliberate (design citations, not
   accidental drift) — the rule should stand on its own without requiring a reader to
   dig up an old planning doc.
2. **Duplicated content** — the same fact explained in two or more places. Keep the
   single most appropriate location. A short summary in one doc that explicitly
   points to a fuller canonical explanation elsewhere (e.g. "see deploy/README.md for
   the full runbook") is *not* a violation — that's a single source of truth with a
   pointer. Two independent, driftable explanations of the same fact *is* one.
3. **Dev-diary narration** — describing what *changed* rather than what *is true now*
   ("previously this used X", "this was fixed because...", "reversed from the earlier
   design"). Keep only the invariant that matters going forward; drop the history
   unless the history itself is the non-obvious fact worth keeping (a workaround for a
   specific external bug is timeless even though it reads as "why", not "what changed").
4. **Redundant WHAT-comments** — restating a well-named function/variable/line with no
   added information. Delete.
5. **Comments substituting for documentation** — long blocks that belong in a doc file
   instead of inline, or multi-paragraph docstrings where a short one would do.

## What is NOT a violation — leave it alone

- A comment capturing a genuinely non-obvious WHY: a hidden constraint, a workaround
  for an external bug, a subtle invariant, a correctness-critical relationship between
  two pieces of code not visible from either alone.
- License headers, type annotations, standard boilerplate.
- A short summary-plus-pointer to a canonical doc (see #2 above).

## Process

1. Read the project's own CLAUDE.md (and CONTRIBUTING.md if present) first, for its
   stated conventions and its planning-folder exclusion.
2. Build the file inventory. Run targeted greps first to size the problem before
   touching anything — plan/task/decision citation patterns, "TODO"/"FIXME", and
   diary language (`previously`, `used to`, `no longer applies`, `was changed`,
   `reversed`, `superseded`, `this fix`, `correction:`) are cheap to find and usually
   reveal the shape of the work before a full read of every file.
3. For a small repo (roughly under 30 files touched), do the sweep directly in this
   session. For a larger one, split by directory or module and dispatch each batch to
   a `fork` (inherits context, keeps the mechanical edit noise out of the main
   conversation) — each fork edits comments/docstrings only, never code logic, and
   runs that module's own test/typecheck command afterward to confirm nothing broke.
4. If a finding is large in scope (many files, an established pattern rather than
   incidental drift) or genuinely ambiguous (could be a deliberate design choice, e.g.
   ADR-style traceability citations), surface it to the user with a concrete count and
   a recommendation before fixing everywhere — don't silently commit to one
   interpretation of the project's own conventions when the two readings diverge this
   much. Small, unambiguous fixes (a stray duplicate line, an obvious dev-diary
   comment) don't need this — just fix them.
5. After edits, verify: re-run each touched area's test suite / typecheck — comment
   edits should never change behavior, and a red run means something was cut
   incorrectly (e.g. a docstring's closing quote).
6. Report a summary grouped by file/category (not a huge diff dump): what was
   removed, what was rewritten, and anything flagged but deliberately left alone
   because it's outside this pass's scope.

## Notes

- Never commit — that's the human's call, same as any other change.
- This is inherently a large-diff task by nature (many small edits across many
  files); that's expected, not a sign of scope creep, as long as every edit is
  actually mechanical (citation-stripping, duplicate removal) rather than a rewrite
  of meaning.
