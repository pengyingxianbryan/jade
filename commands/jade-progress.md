---
name: jade:progress
description: Smart status with Jira/GitHub/TDD context — suggests ONE next action
argument-hint: "[context]"
allowed-tools: [Read]
---

<objective>
Show current progress including Jira ticket status, GitHub branch state, and TDD results across all phases. Route to exactly ONE next action.

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
- Plans approved timestamp
- Per-phase plan status (planned / revised / executing / complete)
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

**Phase Plan Status:**
- Phase 1: [planned / revised / executing / complete]
- Phase 2: [planned / revised / executing / complete]
- ...
</step>

<step name="determine_routing">
Based on state, determine **ONE** next action:

| Situation | Single Suggestion |
|-----------|-------------------|
| No project initialized | `/jade:init` |
| Init done, no plans | `/jade:plan` |
| Plans approved, not executing | `/jade:apply` |
| Phase applied, not unified | `/jade:unify` |
| Unified, more phases remain | `/jade:apply` (next phase) or `/jade:plan --revise N` |
| All phases unified | `/jade:verify` |
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

Plans: approved [date]
  Phase 1: complete
  Phase 2: executing (revised)
  Phase 3: planned

Current Loop: Phase 2, Plan 02-01
┌─────────────────────────────────────┐
│  PLAN ──▶ APPLY ──▶ UNIFY          │
│    ✓        ✓        ○             │
└─────────────────────────────────────┘

Jira: PROJ-123 — In Progress
GitHub: jade/PROJ-123 — last push 10m ago
TDD: 2/3 tasks complete | 14 tests passing
PR: not yet

────────────────────────────────────────
▶ NEXT: /jade:unify .jade/phases/02-features/02-01-PLAN.md
  Close the loop, post summary to Jira, open PR.
────────────────────────────────────────
```
</step>

</process>

<success_criteria>
- [ ] Overall progress displayed visually
- [ ] Per-phase plan status shown (planned/revised/executing/complete)
- [ ] Jira ticket status shown
- [ ] GitHub branch and push status shown
- [ ] TDD progress shown (tasks complete, tests passing)
- [ ] Current loop position shown
- [ ] Exactly ONE next action suggested
</success_criteria>
