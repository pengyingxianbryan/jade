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

**JADE** (Jira -> Approval -> Driven Test -> Evaluation) extends PAUL's Plan-Apply-Unify loop with Jira REST API, GitHub `gh` CLI, full-plan-upfront workflow, and Superpowers-style TDD enforcement.

## The Loop

```
INIT ──▶ PLAN ALL ──▶ APPROVE ──▶ [per-phase loop]
                                   APPLY ──▶ UNIFY
                                   ↕
                                   optional revision
```

## 10 Commands

| Command | What it does |
|---|---|
| `/jade:init` | Set up project — credentials, overview, roadmap, phase directories |
| `/jade:plan` | Plan all phases, revise, fix UAT issues, or modify roadmap |
| `/jade:apply` | Execute with TDD (RED/GREEN/REFACTOR), commits + pushes per task |
| `/jade:unify` | Close loop — Jira summary, PR, triage deferred issues |
| `/jade:verify` | UAT gate — PASS transitions to Done, FAIL captures issues |
| `/jade:progress` | Status across all phases + ONE next action |
| `/jade:pause` | Full handoff + Jira comment + session continuity |
| `/jade:resume` | Restore context from STATE.md and handoffs |
| `/jade:research` | Research topic, phase unknowns, or map codebase |
| `/jade:help` | This reference |

## `/jade:plan` Arguments

| Argument | Mode |
|---|---|
| (none) | **Plan All** — generate plans for every phase |
| `--revise N` | **Revise** — update plan for phase N |
| `--fix N` | **Fix** — create fix plan from UAT issues |
| `--add-phase <desc>` | **Add Phase** — append to roadmap |
| `--remove-phase N` | **Remove Phase** — remove future phase |
| `PROJ-123` | **Jira-first** — link existing ticket |

## `/jade:research` Arguments

| Argument | Mode |
|---|---|
| `<topic>` | Research a specific topic |
| `phase N` | Identify and research unknowns for phase N |
| `codebase` | Map the existing codebase |

## Jira Status Mapping

| JADE event | Jira transition | GitHub action |
|---|---|---|
| Plans approved | Phase 1 ticket created -> `To Do` | -- |
| `/jade:apply` starts | Ticket created -> `In Progress` | Branch created |
| Task completes | Comment posted | Commit + push |
| `/jade:unify` runs | `In Progress` -> `In Review` | PR opened |
| `/jade:verify` passes | `In Review` -> `Done` | PR ready to merge |

## TDD Gate (per task)

```
RED    — Write failing test → GATE: passes early? STOP.
GREEN  — Minimal implementation → GATE: breaks existing? STOP.
REFACTOR — Clean up only → GATE: breaks anything? Undo.
```

## Key Principles

1. **APPROVE before execution** — no code without explicit approval
2. **Full plan upfront** — all phases planned at once, revised as needed
3. **TDD per task** — RED → GREEN → REFACTOR, no exceptions
4. **Jira sync** — every task posts results, status mirrors reality
5. **GitHub gate** — remote verified before any code
6. **UNIFY every phase** — no orphan phases
7. **Boundaries are absolute** — DO NOT CHANGE means DO NOT CHANGE

---

*JADE v2.0 | Built on PAUL + Superpowers TDD*
</reference>
