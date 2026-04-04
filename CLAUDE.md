# PM — Agent Instructions

## What PM is

PM = **J**ust **A**pproval → **D**riven Test → **E**valuation

A Claude Code plugin that extends PAUL's Plan-Apply-Unify loop with:
- Local Story/Task tracking in Jira-style markdown (no external Jira needed)
- GitHub as code remote with per-task branches, PRs, and review gates (via `gh` CLI + native git)
- Hard human approval gate before any execution begins
- Superpowers-style RED/GREEN/REFACTOR TDD enforcement per task
- Premium frontend design enforcement via designer-uxui skill (Next.js, Tailwind, Motion)

## Local Tracking — Story/Task Hierarchy

PM creates a local Jira-style hierarchy under each phase directory:

```
.pm/phases/01-foundation/
├── STORY.md                    # Phase-level story (like a Jira Story)
├── 01-01-PLAN.md               # Executable plan
├── tasks/
│   ├── TASK-01.md              # Individual task (like a Jira Subtask)
│   ├── TASK-02.md
│   └── TASK-03.md
└── 01-01-SUMMARY.md            # After completion
```

**STORY.md** — Phase-level summary with acceptance criteria, priority, scope.
**TASK-NN.md** — Individual task with status, discipline, acceptance criteria, files, verification, and completion record.

Each task updates its own status independently:
- `To Do` → `In Progress` → `Done`

Status updates happen per-task, not after the whole story completes.

## GitHub Patterns

**Per-task branching and PRs:**
Each task gets its own branch and PR for review:

```bash
# Branch naming: pm/{phase}-task-{N}
git checkout -b pm/01-foundation-task-1 main

# After TDD passes, commit and push
git add -A
git commit -m "feat: task 1 — [task name]

- RED: [test file] — X tests added, confirmed failing
- GREEN: [impl file] — all X tests passing
- REFACTOR: cleanup applied

Co-Authored-By: Claude <noreply@anthropic.com>"

git push -u origin pm/01-foundation-task-1
```

**PR creation per task (via `gh` CLI):**
```bash
gh pr create \
  --title "Task 1: [task name]" \
  --body "$(cat <<'EOF'
## Summary
[What this task delivers]

## TDD Results
- RED: X tests added, confirmed failing
- GREEN: all tests passing
- REFACTOR: cleanup applied

## Changes
[Files changed]

## Acceptance Criteria
[From TASK-NN.md]
EOF
)" \
  --base main \
  --head pm/01-foundation-task-1
```

After PR is created, ask the user to review and merge before proceeding to the next task.

**All other git ops:** Native `git` CLI (branch, commit, push, status, remote). No wrapper needed.

## Mandatory workflow — always in this order

1. `/pm:init` — Project setup
   Verify GitHub CLI authenticated
   Configure GitHub remote
   Conversational project overview
   PM recommends full multi-phase roadmap
   User refines → PM creates phase directories

2. `/pm:plan` — Generate ALL phase plans
   Draft PLAN.md for every phase (readable markdown, each task tagged with discipline: frontend|backend|fullstack|devops)
   Present complete set → wait for APPROVE
   After APPROVE: create local Story/Task hierarchy for ALL phases:
     - STORY.md per phase (objective, ACs, scope, task summary)
     - TASK-NN.md per task (description, ACs, files, verification, status)
   Full backlog visible locally immediately

   OR `/pm:plan --revise N` — Revise a single phase plan
   Incorporate learnings from completed phases → APPROVE update → sync local files

3. For each phase:
   a. `/pm:apply`
      Verify GitHub remote is reachable (HARD GATE)
      STORY.md + TASK files already exist from plan phase
      For each task:
        - Update TASK-NN.md status: `In Progress`
        - Create task branch: `pm/{phase}-task-{N}`
        - TDD: RED → GREEN → REFACTOR
        - Commit and push
        - Create PR via `gh pr create`
        - Ask user to review/merge PR
        - Update TASK-NN.md status: `Done` with completion record
        - Checkout main, pull latest
      Update STORY.md status: `In Progress` → track task completion

   b. `/pm:unify`
      Write SUMMARY.md
      Update STORY.md status: `In Review`
      Reconcile plan vs actual
      Triage deferred issues (create local issue files)

   c. (Optional) Revise next phase plan if earlier phases revealed new information

4. `/pm:verify` (when ready for UAT)
   Show summary and list of merged PRs
   User types PASS or FAIL
   On PASS: update STORY.md status: `Done`

## 10 commands — that's it

| Command | What it does |
|---|---|
| `/pm:init` | GitHub setup, project overview, roadmap, phase directories |
| `/pm:plan` | Plan all / revise / fix / add-phase / remove-phase |
| `/pm:apply` | Execute with TDD, per-task branches + PRs, local status updates |
| `/pm:unify` | Summary, reconciliation, triage deferred issues |
| `/pm:verify` | UAT gate — PASS or FAIL |
| `/pm:progress` | Status + one next action |
| `/pm:pause` | Full handoff + session continuity |
| `/pm:resume` | Restore context |
| `/pm:research` | Research topic / phase N / codebase |
| `/pm:help` | Command reference |

## Hard rules — no exceptions

- NEVER begin APPLY without user saying APPROVE
- NEVER write a single line of implementation before the GitHub remote is verified reachable
- NEVER write implementation before a failing test exists for that task
- NEVER skip UNIFY — every phase must close with a summary
- ALWAYS create a task branch before writing code for that task
- ALWAYS push and create a PR after every task — not batched at UNIFY
- ALWAYS ask user to review/merge PR before proceeding to next task
- ALWAYS update TASK-NN.md status after each task completes (not after whole story)
- ALWAYS reference phase and task in commit messages
- NEVER modify files listed in PLAN.md boundaries section
- NEVER batch multiple tasks through RED phase together
