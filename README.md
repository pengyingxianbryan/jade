# JADE

**J**ira -> **A**pproval -> **D**riven Test -> **E**valuation

A Claude Code plugin that extends PAUL's Plan-Apply-Unify loop with Jira integration, GitHub integration, and strict TDD enforcement.

---

## How JADE Extends PAUL

JADE keeps everything PAUL does and adds four things:

### 1. Jira Integration via REST API

Jira is the external source of truth alongside local STATE.md. JADE creates tickets automatically after plan approval (plan-first mode) or links existing tickets (Jira-first mode). Every task completion posts a structured comment to Jira via REST API (`curl`). Ticket status transitions mirror the JADE loop: To Do -> In Progress -> In Review -> Done.

### 2. GitHub Integration via `gh` CLI

JADE requires a verified GitHub remote before any code is written. It creates a feature branch (`jade/PROJ-123`) at the start of APPLY, commits and pushes after every task (not just at the end), and opens a Pull Request via `gh pr create` during UNIFY. Work is never lost if a session ends unexpectedly.

### 3. Premium Design Enforcement

When tasks involve frontend UI, the `designer-uxui` skill activates automatically during APPLY. It enforces premium design standards: proper animation easing and duration, typographic hierarchy, responsive layouts, accessibility (`prefers-reduced-motion`), and performance (GPU-composited properties only). Stack: Next.js App Router + Tailwind CSS + Motion. Works alongside TDD — correctness AND craft.

### 4. Superpowers-style TDD Enforcement

Every task in APPLY runs through a strict RED -> GREEN -> REFACTOR cycle with hard gates:
- **RED:** Write failing test first. If test passes before implementation, STOP.
- **GREEN:** Write minimal implementation. If any existing test breaks, STOP.
- **REFACTOR:** Clean up only. No new behaviour. If tests break, undo.

Implementation code written before a failing test exists is deleted. No exceptions.

### 5. Full Plan Upfront

Unlike PAUL's sequential plan-one-execute-one approach, JADE generates plans for ALL phases during `/jade:plan` and presents them for a single APPROVE. Plans can be revised between phases as learnings emerge.

---

## The Loop

```
INIT ──▶ PLAN ALL ──▶ APPROVE ──▶ [per-phase loop]
                                   │
                                   APPLY ──▶ UNIFY
                                   (TDD)     (Jira + PR)
                                   ↕
                                   optional plan revision
```

### Jira Status Mapping

| JADE Event | Jira Transition | GitHub Action |
|---|---|---|
| `/jade:plan` approved (plan-first) | Phase 1 ticket created -> `To Do` | -- |
| `/jade:plan PROJ-123` approved (Jira-first) | Existing ticket linked -> `To Do` | -- |
| `/jade:apply` starts | Ticket created (if needed) -> `In Progress` | Branch `jade/PROJ-123` created and pushed |
| Task completes (RED/GREEN/REFACTOR) | Comment posted with test results | Commit + push to `jade/PROJ-123` |
| Task fails TDD gate | Comment: `Blocked: [reason]` | No push until gate passes |
| `/jade:unify` runs | `In Progress` -> `In Review` | PR opened: `jade/PROJ-123` -> `main` |
| `/jade:verify` passes | `In Review` -> `Done` | PR can be merged |

---

## Installation

### From GitHub

```bash
# Register the marketplace
/plugin marketplace add pengyingxianbryan/jade

# Install the plugin
/plugin install jade
```

### Manual

Clone the repo and point Claude Code at the `jade/` directory.

---

## Setup

On first run in a project, JADE's SessionStart hook detects that `.jade/.configured` is missing and directs you to run `/jade:init`.

### `/jade:init` Flow

1. **Credentials** — Checks `gh auth status`, collects Jira URL + project key + email + API token
2. **Project overview** — Open-ended conversation: what you're building, who it's for, tech stack
3. **Roadmap** — JADE proposes a multi-phase roadmap, you refine, approve
4. **Phase directories** — Creates `.jade/phases/01-name/`, `02-name/`, etc.

Credentials are stored in `.jade/.env` (gitignored, repo-local). No global config changes.

---

## Plan Modes

### Mode 1: Plan All (Default)

No ticket number needed. JADE generates plans for all phases at once.

```
/jade:plan

# JADE reads ROADMAP.md and generates PLAN.md for every phase
# Presents all plans for review

# User says: APPROVE

# JADE automatically:
# 1. Creates Jira ticket for Phase 1
# 2. Writes jira key to Phase 1 PLAN.md

✅ All plans approved.
✅ Jira ticket created for Phase 1: PROJ-123
✅ Branch will be: jade/PROJ-123

Run /jade:apply to begin Phase 1.
```

### Mode 2: Revise

Update a plan for a specific phase based on learnings from completed phases.

```
/jade:plan --revise 3

# JADE reads completed phase summaries
# Revises Phase 3 plan incorporating learnings
# Presents revised plan for APPROVE
```

### Mode 3: Jira-First

For teams where a PM has already created the ticket. Pass any existing ticket key — the project prefix comes from your Jira project (e.g., `ENG-42`, `PLAT-7`, `FE-301`).

```
/jade:plan PROJ-123

# JADE fetches PROJ-123 from Jira
# Pre-populates PLAN.md from ticket content
# Presents plan for review

# User says: APPROVE

✅ Plan approved.
✅ Jira ticket PROJ-123 linked.
✅ Branch will be: jade/PROJ-123

Run /jade:apply to begin implementation.
```

---

## TDD Gate

During `/jade:apply`, every task runs through RED -> GREEN -> REFACTOR:

### RED — Write Failing Test

- Write test FIRST. Touch ONLY test files.
- Run tests. Confirm new test FAILS.
- **HARD GATE:** If test passes before implementation -> STOP. Report to user.

### GREEN — Minimal Implementation

- Write SIMPLEST code to pass the failing test.
- Run tests. Confirm ALL tests pass (new + existing).
- **HARD GATE:** If any existing test breaks -> STOP. Report exactly which tests.

### REFACTOR — Clean Up

- Clean up. No new behaviour.
- Run tests. Confirm still all green.
- **HARD GATE:** If any test fails -> STOP. Undo refactor.

### After Each Task

```
git commit -m "feat(PROJ-123): task 1 — create login endpoint

- RED: login.test.ts — 3 tests added, confirmed failing
- GREEN: login.ts — all 3 tests passing
- REFACTOR: cleanup applied

Refs: PROJ-123"

git push origin jade/PROJ-123
```

Jira comment posted with test results. STATE.md updated.

---

## UNIFY — Close the Loop

`/jade:unify` does everything PAUL's unify does, plus:

1. **Posts SUMMARY.md to Jira** as a structured comment (via curl)
2. **Transitions ticket** to `In Review` (via curl)
3. **Opens PR** via `gh pr create` with:
   - Title: `[PROJ-123] Plan objective`
   - Body: Summary, Jira link, TDD results, changes, ACs
4. **Creates child tickets** for any deferred issues (via curl)
5. Writes PR URL to STATE.md

---

## Command Reference — 10 Commands

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
| `/jade:help` | Command reference |

### `/jade:plan` arguments

| Argument | Mode |
|---|---|
| (none) | **Plan All** — generate plans for every phase |
| `--revise N` | **Revise** — update plan for phase N |
| `--fix N` | **Fix** — create fix plan from UAT issues |
| `--add-phase <desc>` | **Add Phase** — append to roadmap |
| `--remove-phase N` | **Remove Phase** — remove future phase |
| `PROJ-123` | **Jira-first** — link existing ticket |

### `/jade:research` arguments

| Argument | Mode |
|---|---|
| `<topic>` | Research a specific topic |
| `phase N` | Identify and research unknowns for phase N |
| `codebase` | Map the existing codebase |

---

## Repo Structure

```
jade/
├── .claude-plugin/
│   ├── marketplace.json       # Marketplace registration
│   └── plugin.json            # Plugin metadata
├── hooks/
│   ├── hooks.json             # SessionStart hook config
│   └── setup.sh               # Thin sentinel check — defers to /jade:init
├── commands/                   # 10 commands total
│   ├── jade-init.md           # Project setup: credentials, overview, roadmap, phase dirs
│   ├── jade-plan.md           # Plan all / revise / fix / add-phase / remove-phase / Jira-first
│   ├── jade-apply.md          # TDD execution with GitHub/Jira integration
│   ├── jade-unify.md          # Loop closure: Jira summary, PR, triage deferred issues
│   ├── jade-verify.md         # UAT confirmation gate
│   ├── jade-progress.md       # Smart status with multi-phase visibility
│   ├── jade-pause.md          # Full handoff + Jira comment
│   ├── jade-resume.md         # Context restoration
│   ├── jade-research.md       # Research topic / phase / codebase
│   └── jade-help.md           # Command reference
├── skills/
│   ├── tdd-gate/
│   │   └── SKILL.md           # RED/GREEN/REFACTOR enforcement
│   └── designer-uxui/
│       └── SKILL.md           # Premium frontend design enforcement
├── templates/
│   ├── PLAN.md                # Plan template with jira: field
│   ├── STATE.md               # State template with Jira/GitHub/TDD/Plan Status sections
│   ├── PROJECT.md             # Project context template
│   ├── ROADMAP.md             # Phase structure template
│   └── SUMMARY.md             # Completion documentation template
├── rules/
│   └── jade-rules.md          # 6 hard rules
├── CLAUDE.md                  # Agent instructions
├── LICENSE                    # MIT
└── README.md                  # This file
```

---

## What Gets Written to `.jade/.env`

Credentials are stored repo-local, never globally:

```bash
JIRA_BASE_URL="https://yourcompany.atlassian.net"
JIRA_PROJECT_KEY="ENG"
ATLASSIAN_EMAIL="you@yourcompany.com"
ATLASSIAN_API_TOKEN="your_token"
```

`.jade/.env` is automatically added to `.gitignore` during init.

GitHub authentication is handled by `gh auth login` — no token stored in JADE.

## How to Reconfigure

Delete the sentinel file and run init again:

```bash
rm .jade/.configured
/jade:init
```

---

## License

MIT — see [LICENSE](LICENSE).

---

*JADE v2.0 — Jira -> Approval -> Driven Test -> Evaluation*
*Built on [PAUL](https://github.com/ChristopherKahler/paul) (Plan-Apply-Unify Loop) + [Superpowers TDD](https://github.com/obra/superpowers)*
