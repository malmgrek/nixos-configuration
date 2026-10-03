---
name: spot-fix
description: 'Make a small fix without the review loop and record it as unreviewed. Use for polish found by manual testing — layout, padding, wording, a visibly wrong value — where your eyes were the validation and a cold reviewer could add nothing. Triggers: "spot-fix", "just fix this", "fix this without review", "no review, just fix".'
---

Make the fix the user asked for, and nothing else.

- **Do not invoke the reviewer subagent.** Not after the fix, not for a
  verification round.
- **Do not touch proposal.md, design.md, the tasks in tasks.md, or any spec.**
- Run the narrowest validation that actually covers the change and show its
  output. If nothing runnable covers it -- a layout or styling change the user is
  looking at right now -- say so plainly rather than running a broad suite. Their
  eyes were the validation.
- Append one line to the `## Unreconciled` section of the active change's
  `tasks.md`: what changed, marked `Visual only.` or `Behaviour -- spec.` Create
  the section if it is missing.
- If the fix turns out to need more than was asked -- it is a real requirement
  gap, not polish -- say so in one sentence and stop. Do not quietly widen it into
  a task, and do not start reviewing it.
- Report in one sentence. Do not offer to review, reconcile, or continue with the
  task list.
