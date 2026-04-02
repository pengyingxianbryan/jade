# JADE — Agent Instructions

## What JADE is
JADE = Jira -> Approval -> Driven Test -> Evaluation

A Claude Code plugin that extends PAUL's Plan-Apply-Unify loop with:
- Jira as external source of truth alongside local STATE.md (via Atlassian MCP)
- GitHub as code remote with feature branches, per-task pushes, and auto-PR (via GitHub MCP)
- Hard human approval gate before any execution begins
- Superpowers-style RED/GREEN/REFACTOR TDD enforcement per task
- Premium frontend design enforcement via designer-uxui skill (Next.js, Tailwind, Motion)

## Jira configuration
- MCP endpoint: https://mcp.atlassian.com/v1/mcp
- Auth: Basic (base64 of email:api_token)
- Project key: set in JIRA_PROJECT_KEY env var
- Credentials: set in ATLASSIAN_API_TOKEN and ATLASSIAN_EMAIL env vars

## GitHub configuration
- MCP endpoint: https://api.githubcopilot.com/mcp
- Auth: Bearer (GitHub PAT)
- Repository: set in GITHUB_REPO_URL env var
- Default branch: set in GITHUB_DEFAULT_BRANCH env var

## Mandatory workflow — always in this order

1. `/jade:plan` — DEFAULT, no ticket number needed
   Have planning conversation with user
   Draft PLAN.md (objective, ACs, tasks, boundaries)
   Present complete plan -> wait for APPROVE
   **Auto-create Jira ticket after APPROVE** -> write key to PLAN.md and STATE.md automatically
   User never types a ticket number

   OR `/jade:plan PROJ-123` — Jira-first mode for team workflows
   Fetch existing ticket -> pre-populate PLAN.md -> APPROVE -> link ticket

2. `/jade:apply`
   Verify GitHub remote is reachable (HARD GATE)
   Create feature branch: jade/[jira_key]
   For each task: RED -> GREEN -> REFACTOR
   Commit and push after every task
   Post task result to Jira after each task
   Transition ticket: To Do -> In Progress

3. `/jade:unify`
   Write SUMMARY.md
   Post summary to Jira as structured comment
   Transition ticket: In Progress -> In Review
   Create child tickets for deferred issues
   Open PR via GitHub MCP

4. `/jade:verify` (when ready for UAT)
   Show summary and PR link
   User types PASS or FAIL
   On PASS: transition ticket In Review -> Done

## Hard rules — no exceptions

- NEVER begin APPLY without user saying APPROVE
- NEVER write a single line of implementation before the GitHub remote is verified reachable
- NEVER write implementation before a failing test exists for that task
- NEVER skip UNIFY — every plan must close with a summary
- ALWAYS create a feature branch `jade/[jira_key]` before the first task in APPLY
- ALWAYS push to the feature branch after every task — not just at UNIFY
- ALWAYS post task results as Jira comments during APPLY
- ALWAYS reference Jira ticket key in commit messages (e.g. feat(PROJ-123): task name)
- ALWAYS open a PR via GitHub MCP during UNIFY
- NEVER modify files listed in PLAN.md <boundaries> section
- NEVER batch multiple tasks through RED phase together
