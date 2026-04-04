# PM

Story -> Tasks -> Approval -> TDD -> Github

A Claude Code plugin that extends PAUL's Plan-Apply-Unify loop with local Story/Task tracking, GitHub per-task PRs, and strict TDD enforcement.

---

## Installation

### From GitHub

```bash
# Register the marketplace
/plugin marketplace add pengyingxianbryan/claude-pm

# Install the plugin
/plugin install claude-pm
```

### Manual

Clone the repo and point Claude Code at the `pm/` directory.

---

### 1. Local Story/Task Tracking

PM creates a Jira-style hierarchy of markdown files under each phase — no external Jira instance needed. Each phase gets a `STORY.md` (like a Jira Story) and individual `TASK-NN.md` files (like Jira Subtasks). Tasks update their own status independently as work progresses.

```
.pm/phases/01-foundation/
├── STORY.md              # Phase story — status, ACs, scope
├── tasks/
      ├── TASK-01.md        # Task — status, ACs, completion record
│   └── TASK-02.md
├── 01-01-PLAN.md         # Executable plan
└── 01-01-SUMMARY.md      # After completion
```

### 2. GitHub Integration with Per-Task PRs

Every task gets its own branch and Pull Request for review. PM creates a branch from main (`pm/{phase}-task-{N}`), runs TDD, commits, pushes, and opens a PR via `gh pr create`. You review and merge before PM proceeds to the next task. Work is never lost if a session ends unexpectedly.

### 3. Premium Design Enforcement

When tasks involve frontend UI, the `designer-uxui` skill activates automatically during APPLY. It enforces premium design standards: proper animation easing and duration, typographic hierarchy, responsive layouts, accessibility (`prefers-reduced-motion`), and performance (GPU-composited properties only). Stack: Next.js App Router + Tailwind CSS + Motion.

### 4. Superpowers-style TDD Enforcement

Every task in APPLY runs through a strict RED → GREEN → REFACTOR cycle with hard gates:
- **RED:** Write failing test first. If test passes before implementation, STOP.
- **GREEN:** Write minimal implementation. If any existing test breaks, STOP.
- **REFACTOR:** Clean up only. No new behaviour. If tests break, undo.

Implementation code written before a failing test exists is deleted. No exceptions.

### 5. Full Plan Upfront

Unlike PAUL's sequential plan-one-execute-one approach, PM generates plans for ALL phases during `/pm:plan` and presents them for a single APPROVE. Plans can be revised between phases as learnings emerge.

---

## The Loop

```
INIT ──▶ PLAN ALL ──▶ APPROVE ──▶ [per-phase loop]
                                   │
                                   APPLY ──▶ UNIFY
                                   (TDD + PR)
                                   ↕
                                   optional plan revision
```

### Per-Task Workflow

| PM Event | Local Tracking | GitHub Action |
|---|---|---|
| `/pm:plan` approved | STORY.md + TASK-NN.md created (To Do) | — |
| Task starts | TASK-NN.md → In Progress | Branch created from main |
| TDD passes | Completion record filled | Commit + push |
| PR created | — | `gh pr create` |
| PR merged | TASK-NN.md → Done | Back to main, pull |
| All tasks done | STORY.md → In Progress | — |
| `/pm:unify` | STORY.md → In Review | — |
| `/pm:verify` PASS | STORY.md → Done | — |

---

## Setup

On first run in a project, PM's SessionStart hook detects that `.pm/.configured` is missing and directs you to run `/pm:init`.

### `/pm:init` Flow

1. **GitHub** — Checks `gh auth status`, collects repo URL, verifies remote connectivity
2. **Project overview** — Open-ended conversation: what you're building, who it's for, tech stack
3. **Roadmap** — PM proposes a multi-phase roadmap, you refine, approve
4. **Phase directories** — Creates `.pm/phases/01-name/`, `02-name/`, etc.

GitHub authentication is handled by `gh auth login` — no token stored in PM.

---

## Plan Modes

### Mode 1: Plan All (Default)

PM generates plans for all phases at once.

```
/pm:plan

# PM reads ROADMAP.md and generates PLAN.md for every phase
# Presents all plans for review

# User says: APPROVE

# PM automatically creates:
# - STORY.md per phase
# - tasks/TASK-NN.md per task

All plans approved. Local tracking created:
  Phase 1: Foundation
    ├── STORY.md (Highest priority)
    ├── tasks/TASK-01.md [backend]
    └── tasks/TASK-02.md [frontend]

Run /pm:apply to begin Phase 1.
```

### Mode 2: Revise

Update a plan for a specific phase based on learnings from completed phases.

```
/pm:plan --revise 3

# PM reads completed phase summaries
# Revises Phase 3 plan incorporating learnings
# Presents revised plan for APPROVE
# Updates STORY.md and TASK-NN.md files
```

---

## TDD Gate

During `/pm:apply`, every task runs through RED → GREEN → REFACTOR:

### RED — Write Failing Test

- Write test FIRST. Touch ONLY test files.
- Run tests. Confirm new test FAILS.
- **HARD GATE:** If test passes before implementation → STOP. Report to user.

### GREEN — Minimal Implementation

- Write SIMPLEST code to pass the failing test.
- Run tests. Confirm ALL tests pass (new + existing).
- **HARD GATE:** If any existing test breaks → STOP. Report exactly which tests.

### REFACTOR — Clean Up

- Clean up. No new behaviour.
- Run tests. Confirm still all green.
- **HARD GATE:** If any test fails → STOP. Undo refactor.

### After Each Task

```bash
# Commit
git commit -m "feat: task 1 — create login endpoint

- RED: login.test.ts — 3 tests added, confirmed failing
- GREEN: login.ts — all 3 tests passing
- REFACTOR: cleanup applied

Co-Authored-By: Claude <noreply@anthropic.com>"

# Push and create PR
git push -u origin pm/01-foundation-task-1
gh pr create --title "Task 1: Create login endpoint" ...

# User reviews and merges PR
# TASK-01.md updated to Done with completion record
```

---

## UNIFY — Close the Loop

`/pm:unify` does everything PAUL's unify does, plus:

1. **Creates SUMMARY.md** with reconciliation of plan vs actual
2. **Updates STORY.md** status to `In Review`
3. **Triages deferred issues** — categorizes, logs to ISSUES.md
4. **Lists all merged PRs** from the apply phase

---

## Command Reference — 10 Commands

| Command | What it does |
|---|---|
| `/pm:init` | Set up project — GitHub config, overview, roadmap, phase directories |
| `/pm:plan` | Plan all phases, revise, fix UAT issues, or modify roadmap |
| `/pm:apply` | Execute with TDD (RED/GREEN/REFACTOR), per-task branches + PRs |
| `/pm:unify` | Close loop — summary, reconciliation, triage deferred issues |
| `/pm:verify` | UAT gate — PASS updates to Done, FAIL captures issues |
| `/pm:progress` | Status across all phases + ONE next action |
| `/pm:pause` | Full handoff + session continuity |
| `/pm:resume` | Restore context from STATE.md and handoffs |
| `/pm:research` | Research topic, phase unknowns, or map codebase |
| `/pm:help` | Command reference |

### `/pm:plan` arguments

| Argument | Mode |
|---|---|
| (none) | **Plan All** — generate plans for every phase |
| `--revise N` | **Revise** — update plan for phase N |
| `--fix N` | **Fix** — create fix plan from UAT issues |
| `--add-phase <desc>` | **Add Phase** — append to roadmap |
| `--remove-phase N` | **Remove Phase** — remove future phase |

### `/pm:research` arguments

| Argument | Mode |
|---|---|
| `<topic>` | Research a specific topic |
| `phase N` | Identify and research unknowns for phase N |
| `codebase` | Map the existing codebase |

---

## Repo Structure

```
pm/
├── .claude-plugin/
│   ├── marketplace.json       # Marketplace registration
│   └─��� plugin.json            # Plugin metadata
├── hooks/
│   ├── hooks.json             # SessionStart hook config
│   └── setup.sh               # Thin sentinel check — defers to /pm:init
├── commands/                   # 10 commands total
│   ├── pm-init.md           # Project setup: GitHub config, overview, roadmap, phase dirs
│   ├── pm-plan.md           # Plan all / revise / fix / add-phase / remove-phase
│   ├── pm-apply.md          # TDD execution with per-task branches and PRs
│   ├── pm-unify.md          # Loop closure: summary, reconciliation, deferred issues
│   ├── pm-verify.md         # UAT confirmation gate
│   ├── pm-progress.md       # Smart status with task-level visibility
│   ���── pm-pause.md          # Full handoff
│   ├── pm-resume.md         # Context restoration
│   ├── pm-research.md       # Research topic / phase / codebase
│   └── pm-help.md           # Command reference
├── skills/
│   ├── tdd-gate/
│   │   └── SKILL.md           # RED/GREEN/REFACTOR enforcement
│   └── designer-uxui/
│       └── SKILL.md           # Premium frontend design enforcement
├── templates/
���   ├── PLAN.md                # Plan template (readable markdown)
│   ├── STATE.md               # State template with GitHub/TDD sections
��   ├── STORY.md               # Phase story template (Jira-style)
│   ├── TASK.md                # Individual task template (Jira-style)
│   ├── PROJECT.md             # Project context template
│   ├── ROADMAP.md             # Phase structure template
│   └── SUMMARY.md             # Completion documentation template
├���─ rules/
│   └── pm-rules.md          # 7 hard rules
├── CLAUDE.md                  # Agent instructions
├── LICENSE                    # MIT
└── README.md                  # This file
```

---

## How to Reconfigure

Delete the sentinel file and run init again:

```bash
rm .pm/.configured
/pm:init
```

---

## License

MIT — see [LICENSE](LICENSE).

---

*PM v3.0 — Just Approval → Driven Test → Evaluation*
*Built on [PAUL](https://github.com/ChristopherKahler/paul) (Plan-Apply-Unify Loop) + [Superpowers TDD](https://github.com/nicholasgriffintn/superpowers)*
