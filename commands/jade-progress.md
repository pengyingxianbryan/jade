---
name: jade:progress
description: Smart status with Jira/GitHub/TDD context — suggests ONE next action
argument-hint: "[context]"
allowed-tools: [Read]
---

<objective>
Show current progress including Jira ticket status, GitHub branch state, and TDD results. Route to exactly ONE next action.

**When to use:**
- Mid-session check on progress
- After `/jade:resume` for more context
- When unsure what to do next
</objective>

<context>
$ARGUMENTS

@.jade/STATE.md
@.jade/ROADMAP.md
</context>

<process>

<step name="load_state">
Read `.jade/STATE.md` and `.jade/ROADMAP.md`:
- Current phase and total phases
- Current plan (if any)
- Loop position (PLAN/APPLY/UNIFY markers)
- Jira section: ticket key, status, last synced
- GitHub section: branch, remote verified, last push, PR URL
- TDD Results: per-task RED/GREEN/REFACTOR status
- Performance metrics
- Blockers or concerns
</step>

<step name="calculate_progress">
**Milestone Progress:**
- Phases complete: X of Y
- Current phase progress: Z%

**Current Loop:**
- Position: PLAN/APPLY/UNIFY
- Status: [what's happening]

**Jira Status:**
- Ticket: [key] — [status]
- Last synced: [timestamp]

**GitHub Status:**
- Branch: jade/[key]
- Last push: [timestamp]
- PR: [URL or "not yet"]

**TDD Progress:**
- Tasks complete: X of Y
- Total tests: N passing
</step>

<step name="determine_routing">
Based on state, determine **ONE** next action:

| Situation | Single Suggestion |
|-----------|-------------------|
| No plan exists | `/jade:plan` |
| Plan awaiting approval | "Review and APPROVE plan to proceed" |
| Plan approved, not executed | `/jade:apply [path]` |
| Applied, not unified | `/jade:unify [path]` |
| Unified, not verified | `/jade:verify` |
| Loop complete, more phases | `/jade:plan` (next phase) |
| TDD gate failed (task blocked) | "Fix failing test and continue /jade:apply" |
| GitHub remote unreachable | "Fix GitHub remote before /jade:apply" |
| Blockers present | "Address blocker: [specific]" |

**IMPORTANT:** Suggest exactly ONE action. Not multiple options.
</step>

<step name="display_progress">
```
════════════════════════════════════════
JADE PROGRESS
════════════════════════════════════════

Milestone: [name] - [X]% complete
├── Phase 1: [name] ████████████ Done
├── Phase 2: [name] ████████░░░░ 70%
└── Phase 3: [name] ░░░░░░░░░░░░ Pending

Current Loop: Phase 2, Plan 02-03
┌─────────────────────────────────────┐
│  PLAN ──▶ APPLY ──▶ UNIFY          │
│    ✓        ✓        ○             │
└─────────────────────────────────────┘

Jira: PROJ-123 — In Progress
GitHub: jade/PROJ-123 — last push 10m ago
TDD: 2/3 tasks complete | 14 tests passing
PR: not yet

────────────────────────────────────────
▶ NEXT: /jade:unify .jade/phases/02-features/02-03-PLAN.md
  Close the loop, post summary to Jira, open PR.
────────────────────────────────────────
```
</step>

</process>

<success_criteria>
- [ ] Overall progress displayed visually
- [ ] Jira ticket status shown
- [ ] GitHub branch and push status shown
- [ ] TDD progress shown (tasks complete, tests passing)
- [ ] Current loop position shown
- [ ] Exactly ONE next action suggested
</success_criteria>
