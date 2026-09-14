---
name: plan-executor
description: Guide for implementing a plan produced by the spar-and-plan agent — a plans/NNN-short-name/ folder containing plan.md and task-NN.md files. Use this whenever asked to implement, execute, continue, or work through a plan folder or a specific task file within one (e.g. "Implement @plans/117", "do task-03 of plans/042-...").
---

# Plan Executor

You are implementing work from a structured plan folder (`plans/NNN-short-name/`,
containing `plan.md` and one `task-NN.md` file per task). Work directly in this
session — do not delegate implementation to a subagent. You already have `Edit`,
`Write` and `Bash`; use them.

## Scope

Figure out from the request whether you're doing:

- **A single task** (e.g. "implement task-03") — do just that task, then stop
  after the review gate below.
- **The whole plan, sequentially** (e.g. "implement @plans/117") — work through
  every task in `plan.md`'s dependency order, running the full loop below for
  each one before moving to the next.

If it's ambiguous, ask.

## Per-task loop

For each task:

### 1. Read

Read only `task-NN.md` for the task you're about to start (don't pre-read every
task file up front for a whole-plan run — read lazily). Note its `Validation
Commands` and `Review Level` (`trivial` or `standard`).

### 2. Implement

Make the edits described in the task's `Description` / `Acceptance Criteria`.
Stay within the task's boundary — no unrelated refactors or scope creep.

### 3. Verify (fast pass, by you)

Run the commands listed under `Validation Commands` in the task file. If that
section says `none`, run nothing — the plan decided this task is verified by
review alone. Fix failures before moving on. This is your own quick feedback
loop — don't rely on the reviewer to catch build breakage.

### 4. Review gate

- **`trivial` tasks**: no review needed. Mark the checkbox done in `plan.md`
  and continue.
- **`standard` tasks**: invoke the `reviewer` subagent (the Agent tool with
  `subagent_type: "reviewer"`). Always hand it:
  - the task spec (the full contents of `task-NN.md`)
  - the raw diff (`git diff` for this task's changes)
  - the same `Validation Commands` you ran

  Do **not** hand it a narrative summary of what you believe you changed or
  why it works — let it read the diff and re-run verification itself. This
  matters: reviewer must reach its own conclusion from evidence, not from your
  self-report.

  Reviewer will independently re-run the validation commands as part of its
  review — this is intentional, even though you already ran them. Don't skip
  this step to save time; a re-run by an independent pass is what catches
  mistakes a shared context could rationalize away.

### 5. Handle the verdict

- **Approved** — mark the task's checkbox done in `plan.md`, move to the next
  task (or stop, if this was a single-task request).
- **Changes requested** — fix the findings yourself, then re-invoke the
  `reviewer` subagent with the same spec + updated diff. Repeat until approved,
  up to 2 cycles. If still not approved after 2 cycles, stop and report the
  remaining issues to the user rather than looping further.

## Whole-plan runs

When doing multiple tasks in one go, after each task's checkbox is marked
done, immediately continue to the next ready task (respecting `plan.md`'s
stated dependencies) without waiting for confirmation, unless the user asked
you to pause between tasks. If a task's `Description` is unclear or contradicts
`plan.md`, stop and ask rather than guessing.

## Finishing

After the last task (or the single requested task) is handled, report a short
summary: tasks completed, any skipped/blocked items, and the final state of
`plan.md`.
