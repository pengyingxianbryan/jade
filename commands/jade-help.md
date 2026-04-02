---
name: jade:help
description: Show available JADE commands and usage guide
---

<objective>
Display the complete JADE command reference.

Output ONLY the reference content below. Do NOT add project-specific analysis, git status, or commentary.
</objective>

<reference>
# JADE Command Reference

**JADE** (Jira -> Approval -> Driven Test -> Evaluation) extends PAUL's Plan-Apply-Unify loop with Jira REST API integration, GitHub `gh` CLI integration, and Superpowers-style TDD enforcement.

## The Loop

```
┌──────────────────────────────────────────────────────────────┐
│  INIT ──▶ PLAN ALL ──▶ APPROVE ──▶ [per-phase loop]         │
│                                                              │
│  Setup     Full         Human       APPLY ──▶ UNIFY          │
│  project   roadmap      gate        (TDD)     (Jira + PR)    │
│                                     ↕                        │
│                                     optional plan revision    │
└──────────────────────────────────────────────────────────────┘
```

**Never skip UNIFY.** Every phase needs a summary, Jira post, and PR.

## Quick Start

1. `/jade:init` - Set up project (credentials, overview, roadmap, phase directories)
2. `/jade:plan` - Generate ALL phase plans → APPROVE
3. `/jade:apply` - Execute current phase with TDD (commits + pushes per task)
4. `/jade:unify` - Close phase loop (post to Jira, open PR)
5. `/jade:verify` - UAT gate (transitions Jira ticket to Done on pass)

## Commands

| Command | What it does |
|---|---|
| `/jade:init` | Initialize JADE — credentials, project overview, roadmap, phase directories |
| `/jade:plan` | **Plan All** — generate plans for every phase, present for APPROVE |
| `/jade:plan --revise N` | **Revise** — update plan for phase N based on learnings |
| `/jade:plan PROJ-123` | **Jira-first** — fetch existing ticket, pre-populate plan, APPROVE to link |
| `/jade:apply` | Execute phase with RED/GREEN/REFACTOR TDD gate per task. Creates Jira ticket if needed. Commits and pushes after every task. |
| `/jade:unify` | Close the loop. Post summary to Jira. Transition ticket. Create deferred tickets. Open PR via `gh`. |
| `/jade:progress` | Smart status + ONE next action. Shows Jira/GitHub/TDD status across all phases. |
| `/jade:resume [path]` | Restore context from STATE.md and handoffs. Shows Jira/GitHub state. |
| `/jade:verify` | Simple UAT gate. Type PASS to transition ticket to Done. |
| `/jade:pause [reason]` | Create handoff, post pause comment to Jira. |
| `/jade:handoff [context]` | Generate comprehensive handoff with Jira/GitHub/TDD context. |
| `/jade:research <topic>` | Deploy research subagents. |
| `/jade:research-phase <N>` | Research unknowns for a phase. |
| `/jade:discover <topic>` | Explore options before planning. |
| `/jade:discuss <phase>` | Capture decisions before planning. |
| `/jade:assumptions <phase>` | See Claude's intended approach. |
| `/jade:consider-issues` | Triage deferred issues. Optionally create Jira tickets. |
| `/jade:plan-fix` | Plan fixes for UAT issues. |
| `/jade:milestone <n>` | Create new milestone. |
| `/jade:complete-milestone` | Archive and tag milestone. |
| `/jade:discuss-milestone` | Articulate vision before starting. |
| `/jade:add-phase <desc>` | Append phase to roadmap. |
| `/jade:remove-phase <N>` | Remove future phase. |
| `/jade:map-codebase` | Generate codebase overview. |
| `/jade:flows` | Configure skill requirements. |
| `/jade:config` | View/modify JADE settings (Jira, GitHub, integrations). |
| `/jade:help` | Show this reference. |

## Jira Ticket Status Mapping

| JADE event | Jira transition | GitHub action |
|---|---|---|
| `/jade:plan` approved (plan-first) | Phase 1 ticket created -> `To Do` | -- |
| `/jade:plan PROJ-123` approved (Jira-first) | Existing ticket linked -> `To Do` | -- |
| `/jade:apply` starts | Ticket created (if needed) -> `In Progress` | Branch `jade/PROJ-123` created and pushed |
| Task completes (RED/GREEN/REFACTOR) | Comment posted with test results | Commit + push to `jade/PROJ-123` |
| Task fails TDD gate | Comment posted: `Blocked: [reason]` | No push until gate passes |
| `/jade:unify` runs | `In Progress` -> `In Review` | PR opened: `jade/PROJ-123` -> `main` |
| `/jade:verify` passes | `In Review` -> `Done` | PR can be merged |

## TDD Gate (per task in /jade:apply)

```
RED    — Write failing test. Confirm it FAILS.
         GATE: If test passes -> STOP. Feature exists or test is wrong.

GREEN  — Write minimal implementation. Confirm ALL tests pass.
         GATE: If existing test breaks -> STOP. Report which tests.

REFACTOR — Clean up. No new behaviour. Confirm still green.
           GATE: If any test fails -> STOP. Undo refactor.
```

## Files & Structure

```
.jade/
├── PROJECT.md
├── ROADMAP.md
├── STATE.md          (includes Jira, GitHub, TDD Results sections)
├── .env              (Jira credentials — gitignored)
├── .configured       (sentinel)
├── config.md         (optional)
├── SPECIAL-FLOWS.md  (optional)
└── phases/
    ├── 01-phase-name/
    │   ├── 01-01-PLAN.md    (includes jira: field in frontmatter)
    │   └── 01-01-SUMMARY.md
    └── 02-phase-name/
        └── ...
```

## Key Principles

1. **Approval gate** — NEVER begin APPLY without user APPROVE
2. **Full plan upfront** — Generate all phase plans at once, revise between phases as needed
3. **TDD enforcement** — RED -> GREEN -> REFACTOR for every task, no exceptions
4. **Jira sync** — Every task posts results to Jira (via curl), status always reflects reality
5. **GitHub gate** — Remote must be verified before any code is written
6. **Loop integrity** — Per-phase: APPLY -> UNIFY, never skip UNIFY
7. **Boundaries** — DO NOT CHANGE files in boundaries section are absolute

---

*JADE v2.0 | Built on PAUL (ChristopherKahler/paul) + Superpowers TDD (obra/superpowers)*
</reference>
