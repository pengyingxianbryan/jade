---
paths:
  - "**/*.md"
---

# JADE Rules

Domain rules for JADE — enforced at all times during JADE operations.

## Rule 1 — Approval Gate

JADE must never create a Jira ticket, never begin APPLY, and never write implementation code without the user explicitly saying APPROVE after reviewing the complete plan. The word APPROVE (or clear equivalent) must appear in the conversation before any of these actions occur.

After APPROVE is received in plan-first mode, JADE must immediately and automatically:
1. Create the Jira ticket via Atlassian MCP — no further user input required
2. Write the returned ticket key to PLAN.md frontmatter and STATE.md
3. Confirm the ticket key to the user

The user must never be asked to provide a ticket number in plan-first mode. JADE creates the ticket and handles the key internally.

## Rule 2 — TDD Sequence

For every task in APPLY, tests must be written and confirmed FAILING before any implementation file is touched. Implementation code written before a failing test exists must be deleted. This rule has no exceptions.

The sequence is always: RED (failing test) → GREEN (minimal implementation) → REFACTOR (cleanup only).

If a test passes before implementation is written, STOP. Report to user. Do not rationalise past this gate.

If any existing test breaks during GREEN phase, STOP. Report exactly which tests broke. Do not proceed to the next task.

## Rule 3 — Jira Sync

Every task completion during APPLY must result in a comment posted to the Jira ticket via Atlassian MCP. The comment must include: task name, TDD phase results (RED/GREEN/REFACTOR), tests added, total tests passing, files changed, and commit SHA.

Jira ticket status must reflect the actual JADE loop position at all times:
- After PLAN APPROVE: `To Do` (or ticket just created)
- After APPLY starts: `In Progress`
- After UNIFY: `In Review`
- After VERIFY passes: `Done`

## Rule 4 — Loop Integrity

UNIFY is mandatory. No plan is complete without a SUMMARY.md, a structured Jira comment, and a Pull Request. A session that ends without UNIFY is an orphan — STATE.md must record this and `/jade:resume` must surface it as the first action.

The loop is: PLAN → APPLY → UNIFY. There are no shortcuts.

## Rule 5 — Boundary Protection

The `<boundaries>` section of PLAN.md listing DO NOT CHANGE items is enforced absolutely. No file listed in boundaries may be modified during APPLY under any circumstances. Before writing to any file, check it against the boundaries list. If it appears, STOP and report — do not modify.

## Rule 6 — GitHub Gate

`/jade:apply` must verify the GitHub remote is reachable before writing any code. The verification sequence:
1. `git remote -v` — confirm origin is set
2. `git ls-remote origin HEAD` — confirm remote is reachable
3. `git status` — confirm clean working tree

If any check fails for any reason, APPLY must stop immediately and report the failure to the user. No code is written until the remote is confirmed reachable.

Every task completion must result in a `git push` to the feature branch. A task is not considered complete until BOTH the Jira comment is posted AND the push succeeds.

The feature branch naming convention is `jade/[jira_key]` (e.g., `jade/PROJ-123`). This branch is created at the start of APPLY and all commits during APPLY go to this branch.
