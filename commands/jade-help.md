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

**JADE** (Jira -> Approval -> Driven Test -> Evaluation) extends PAUL's Plan-Apply-Unify loop with Jira MCP integration, GitHub integration, and Superpowers-style TDD enforcement.

## The Loop

```
┌──────────────────────────────────────────────────────┐
│  PLAN ──▶ APPROVE ──▶ APPLY ──▶ UNIFY ──▶ VERIFY    │
│                                                      │
│  Define    Human       TDD per    Jira +    UAT      │
│  work      gate        task       PR        gate     │
└──────────────────────────────────────────────────────┘
```

**Never skip UNIFY.** Every plan needs a summary, Jira post, and PR.

## Quick Start

1. `/jade:init` - Initialize JADE (creates project + configures Jira/GitHub)
2. `/jade:plan` - Plan your work (auto-creates Jira ticket after APPROVE)
3. `/jade:apply` - Execute with TDD enforcement (commits + pushes per task)
4. `/jade:unify` - Close loop (post to Jira, open PR, create deferred tickets)
5. `/jade:verify` - UAT gate (transitions Jira ticket to Done on pass)

## Commands

| Command | What it does |
|---|---|
| `/jade:init` | Initialize JADE in a project — creates .jade/, configures Jira + GitHub |
| `/jade:plan` | **DEFAULT** — plan conversation -> APPROVE -> Jira ticket auto-created. No ticket number needed. |
| `/jade:plan PROJ-123` | **Jira-first** — fetch existing ticket PROJ-123, pre-populate plan, APPROVE to link. |
| `/jade:apply` | Execute plan with RED/GREEN/REFACTOR TDD gate per task. Verifies GitHub remote. Creates feature branch. Commits and pushes after every task. Updates Jira per task. |
| `/jade:unify` | Close the loop. Post summary to Jira. Transition ticket. Create deferred tickets. Open PR on GitHub. |
| `/jade:progress` | Smart status + ONE next action. Shows Jira/GitHub/TDD status. |
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
| `/jade:plan` approved (plan-first) | Ticket auto-created -> `To Do` | -- |
| `/jade:plan PROJ-123` approved (Jira-first) | Existing ticket linked -> `To Do` | -- |
| `/jade:apply` starts | `To Do` -> `In Progress` | Branch `jade/PROJ-123` created and pushed |
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
2. **TDD enforcement** — RED -> GREEN -> REFACTOR for every task, no exceptions
3. **Jira sync** — Every task posts results to Jira, status always reflects reality
4. **GitHub gate** — Remote must be verified before any code is written
5. **Loop integrity** — PLAN -> APPLY -> UNIFY, never skip UNIFY
6. **Boundaries** — DO NOT CHANGE files in boundaries section are absolute

---

*JADE v1.0 | Built on PAUL (ChristopherKahler/paul) + Superpowers TDD (obra/superpowers)*
</reference>
