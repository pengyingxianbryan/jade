# JADE

**J**ira -> **A**pproval -> **D**riven Test -> **E**valuation

A Claude Code plugin that extends PAUL's Plan-Apply-Unify loop with Jira integration, GitHub integration, and strict TDD enforcement.

---

## How JADE Extends PAUL

JADE keeps everything PAUL does and adds three things:

### 1. Jira Integration via Atlassian MCP

Jira is the external source of truth alongside local STATE.md. JADE creates tickets automatically after plan approval (plan-first mode) or links existing tickets (Jira-first mode). Every task completion posts a structured comment to Jira. Ticket status transitions mirror the JADE loop: To Do -> In Progress -> In Review -> Done.

### 2. GitHub Integration via GitHub MCP

JADE requires a verified GitHub remote before any code is written. It creates a feature branch (`jade/PROJ-123`) at the start of APPLY, commits and pushes after every task (not just at the end), and opens a Pull Request during UNIFY. Work is never lost if a session ends unexpectedly.

### 3. Premium Design Enforcement

When tasks involve frontend UI, the `designer-uxui` skill activates automatically during APPLY. It enforces premium design standards: proper animation easing and duration, typographic hierarchy, responsive layouts, accessibility (`prefers-reduced-motion`), and performance (GPU-composited properties only). Stack: Next.js App Router + Tailwind CSS + Motion. Works alongside TDD — correctness AND craft.

### 4. Superpowers-style TDD Enforcement

Every task in APPLY runs through a strict RED -> GREEN -> REFACTOR cycle with hard gates:
- **RED:** Write failing test first. If test passes before implementation, STOP.
- **GREEN:** Write minimal implementation. If any existing test breaks, STOP.
- **REFACTOR:** Clean up only. No new behaviour. If tests break, undo.

Implementation code written before a failing test exists is deleted. No exceptions.

---

## The Loop

```
PLAN ──▶ APPROVE ──▶ APPLY ──▶ UNIFY ──▶ VERIFY
                      │         │         │
                      TDD per   Jira +    UAT
                      task      PR        gate
```

### Jira Status Mapping

| JADE Event | Jira Transition | GitHub Action |
|---|---|---|
| `/jade:plan` approved (plan-first) | Ticket auto-created -> `To Do` | -- |
| `/jade:plan PROJ-123` approved (Jira-first) | Existing ticket linked -> `To Do` | -- |
| `/jade:apply` starts | `To Do` -> `In Progress` | Branch `jade/PROJ-123` created and pushed |
| Task completes (RED/GREEN/REFACTOR) | Comment posted with test results | Commit + push to `jade/PROJ-123` |
| Task fails TDD gate | Comment: `Blocked: [reason]` | No push until gate passes |
| `/jade:unify` runs | `In Progress` -> `In Review` | PR opened: `jade/PROJ-123` -> `main` |
| `/jade:verify` passes | `In Review` -> `Done` | PR can be merged |

---

## Installation

### From GitHub (after pushing)

```bash
# Register the marketplace
/plugin marketplace add pengyingxianbryan/jade

# Install the plugin
/plugin install jade
```

### Manual

Clone the repo and point Claude Code at the `jade/` directory.

---

## Setup Wizard

On first run, JADE's SessionStart hook runs an interactive 8-step wizard:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  JADE — First-Run Setup
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Step 1 of 8 — Jira base URL
Jira URL: https://yourcompany.atlassian.net

Step 2 of 8 — Jira project key
Project key: ENG

Step 3 of 8 — Atlassian credentials
Atlassian email: you@yourcompany.com
Atlassian API token: your_token_here

Step 4 of 8 — Where to save credentials
[1] Global  — ~/.zshrc
[2] Local   — .env

Step 5 of 8 — GitHub repository URL
Repository URL: https://github.com/yourname/your-repo

Step 6 of 8 — GitHub Personal Access Token
GitHub PAT: ghp_your_token_here

Step 7 of 8 — Default branch name
Default branch: main

Step 8 of 8 — Git identity
Git user name: Your Name
Git user email: you@yourcompany.com

Verifying GitHub remote...
✅ GitHub remote verified.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✅ JADE setup complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Plan Modes

### Mode 1: Plan-First (Default)

No ticket number needed. JADE creates the Jira ticket automatically.

```
/jade:plan

# JADE asks planning questions:
# - Who is this for?
# - What problem does it solve?
# - What does success look like?
# ...

# Drafts complete PLAN.md and presents it.

# User says: APPROVE

# JADE automatically:
# 1. Creates Jira ticket PROJ-123
# 2. Writes jira: PROJ-123 to PLAN.md
# 3. Updates STATE.md

✅ Plan approved.
✅ Jira ticket created: PROJ-123
✅ Branch will be: jade/PROJ-123

Run /jade:apply to begin implementation.
```

### Mode 2: Jira-First

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

1. **Posts SUMMARY.md to Jira** as a structured comment
2. **Transitions ticket** to `In Review`
3. **Opens PR** via GitHub MCP with:
   - Title: `[PROJ-123] Plan objective`
   - Body: Summary, Jira link, TDD results, changes, ACs
4. **Creates child tickets** for any deferred issues
5. Writes PR URL to STATE.md

---

## Command Reference

| Command | What it does |
|---|---|
| `/jade:init` | Initialize JADE — creates .jade/, configures Jira + GitHub |
| `/jade:plan` | Plan conversation -> APPROVE -> Jira ticket auto-created |
| `/jade:plan PROJ-123` | Fetch existing ticket, pre-populate plan, APPROVE to link |
| `/jade:apply` | Execute with TDD gate per task, commits + pushes per task |
| `/jade:unify` | Close loop: Jira summary, ticket transition, PR, deferred tickets |
| `/jade:progress` | Smart status + ONE next action |
| `/jade:resume [path]` | Restore context including Jira/GitHub state |
| `/jade:verify` | UAT gate — PASS transitions to Done |
| `/jade:pause [reason]` | Create handoff, post pause to Jira |
| `/jade:handoff [context]` | Comprehensive handoff with Jira/GitHub/TDD context |
| `/jade:research <topic>` | Deploy research subagents |
| `/jade:research-phase <N>` | Research unknowns for a phase |
| `/jade:discover <topic>` | Explore options before planning |
| `/jade:discuss <phase>` | Articulate phase vision |
| `/jade:assumptions <phase>` | Surface Claude's assumptions |
| `/jade:consider-issues` | Triage deferred issues, create Jira tickets |
| `/jade:plan-fix` | Plan fixes for UAT issues |
| `/jade:milestone <name>` | Create new milestone |
| `/jade:complete-milestone` | Archive and tag milestone |
| `/jade:discuss-milestone` | Explore next milestone vision |
| `/jade:add-phase <desc>` | Add phase to roadmap |
| `/jade:remove-phase <N>` | Remove future phase |
| `/jade:map-codebase` | Generate codebase overview |
| `/jade:flows` | Configure skill requirements |
| `/jade:config` | View/modify JADE settings |
| `/jade:help` | Show command reference |

---

## Repo Structure

```
jade/
├── .claude-plugin/
│   ├── marketplace.json       # Marketplace registration
│   └── plugin.json            # Plugin metadata
├── hooks/
│   ├── hooks.json             # SessionStart hook config
│   └── setup.sh               # 8-step interactive wizard
├── commands/
│   ├── jade-init.md           # Project initialization + credential setup
│   ├── jade-plan.md           # Two-mode planning with approval gate
│   ├── jade-apply.md          # TDD execution with GitHub/Jira integration
│   ├── jade-unify.md          # Loop closure: Jira summary, PR, deferred tickets
│   ├── jade-progress.md       # Smart status with Jira/GitHub/TDD context
│   ├── jade-resume.md         # Context restoration
│   ├── jade-verify.md         # UAT confirmation gate
│   ├── jade-research.md       # Topic research
│   ├── jade-research-phase.md # Phase unknowns research
│   ├── jade-milestone.md      # Milestone creation
│   ├── jade-complete-milestone.md
│   ├── jade-discuss-milestone.md
│   ├── jade-discover.md       # Technical discovery
│   ├── jade-discuss.md        # Phase vision
│   ├── jade-assumptions.md    # Surface assumptions
│   ├── jade-handoff.md        # Comprehensive handoff
│   ├── jade-pause.md          # Session pause with Jira comment
│   ├── jade-config.md         # Configuration management
│   ├── jade-map-codebase.md   # Codebase analysis
│   ├── jade-flows.md          # Skill configuration
│   ├── jade-consider-issues.md # Issue triage with Jira ticket creation
│   ├── jade-plan-fix.md       # UAT fix planning
│   ├── jade-add-phase.md      # Add roadmap phase
│   ├── jade-remove-phase.md   # Remove roadmap phase
│   └── jade-help.md           # Command reference
├── skills/
│   ├── tdd-gate/
│   │   └── SKILL.md           # RED/GREEN/REFACTOR enforcement
│   └── designer-uxui/
│       └── SKILL.md           # Premium frontend design enforcement
├── templates/
│   ├── PLAN.md                # Plan template with jira: field
│   ├── STATE.md               # State template with Jira/GitHub/TDD sections
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

## What Gets Written to ~/.claude.json

The setup wizard merges (does not overwrite) two MCP server entries:

```json
{
  "mcpServers": {
    "atlassian": {
      "type": "http",
      "url": "https://mcp.atlassian.com/v1/mcp",
      "headers": {
        "Authorization": "Basic BASE64_OF_EMAIL_COLON_TOKEN"
      }
    },
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp",
      "headers": {
        "Authorization": "Bearer YOUR_GITHUB_PAT"
      }
    }
  }
}
```

## What Gets Written to Env Scope File

Depending on scope choice (global = ~/.zshrc, local = .env):

```bash
# jade start
export JIRA_PROJECT_KEY="ENG"
export JIRA_BASE_URL="https://yourcompany.atlassian.net"
export ATLASSIAN_API_TOKEN="your_token"
export ATLASSIAN_EMAIL="you@yourcompany.com"
export GITHUB_REPO_URL="https://github.com/yourname/your-repo"
export GITHUB_PAT="ghp_your_token"
export GITHUB_DEFAULT_BRANCH="main"
export GIT_USER_NAME="Your Name"
export GIT_USER_EMAIL="you@yourcompany.com"
# jade end
```

---

## How to Reconfigure

Delete the sentinel file and restart Claude:

```bash
rm ~/.claude/.jade-configured
claude
```

The setup wizard will run again on next session start.

---

## License

MIT — see [LICENSE](LICENSE).

---

*JADE — Jira -> Approval -> Driven Test -> Evaluation*
*Built on [PAUL](https://github.com/ChristopherKahler/paul) (Plan-Apply-Unify Loop) + [Superpowers TDD](https://github.com/obra/superpowers)*
