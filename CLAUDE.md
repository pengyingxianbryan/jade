# JADE — Agent Instructions

## What JADE is
JADE = Jira -> Approval -> Driven Test -> Evaluation

A Claude Code plugin that extends PAUL's Plan-Apply-Unify loop with:
- Jira as external source of truth alongside local STATE.md (via REST API + curl)
- GitHub as code remote with feature branches, per-task pushes, and auto-PR (via `gh` CLI + native git)
- Hard human approval gate before any execution begins
- Superpowers-style RED/GREEN/REFACTOR TDD enforcement per task
- Premium frontend design enforcement via designer-uxui skill (Next.js, Tailwind, Motion)

## Credentials

All credentials are stored repo-local in `.jade/.env`. Source this file before any API call:
```bash
source .jade/.env
```

**Required variables in `.jade/.env`:**
```bash
JIRA_BASE_URL="https://yourcompany.atlassian.net"
JIRA_PROJECT_KEY="PROJ"
ATLASSIAN_EMAIL="you@yourcompany.com"
ATLASSIAN_API_TOKEN="your_atlassian_token"
```

**GitHub:** Uses `gh` CLI (authenticated via `gh auth login`). No PAT or token stored in JADE.

## Jira REST API patterns

All Jira operations use REST API v3 via `curl`. Always `source .jade/.env` first.

**Auth header (reuse everywhere):**
```bash
AUTH="Authorization: Basic $(echo -n "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" | base64)"
```

### Create issue
```bash
curl -s -X POST \
  -H "$AUTH" -H "Content-Type: application/json" \
  "$JIRA_BASE_URL/rest/api/3/issue" \
  -d '{"fields":{"project":{"key":"'"$JIRA_PROJECT_KEY"'"},"summary":"...","issuetype":{"name":"Story"},"description":{"version":3,"type":"doc","content":[{"type":"paragraph","content":[{"type":"text","text":"..."}]}]}}}'
```
Response: `{"key":"PROJ-123",...}`

### Fetch issue
```bash
curl -s -H "$AUTH" "$JIRA_BASE_URL/rest/api/3/issue/PROJ-123"
```

### Transition issue (2-step)
```bash
# Step 1: Get available transitions
curl -s -H "$AUTH" "$JIRA_BASE_URL/rest/api/3/issue/PROJ-123/transitions" | jq '.transitions[] | {id, name}'

# Step 2: Post the transition using the correct ID
curl -s -X POST \
  -H "$AUTH" -H "Content-Type: application/json" \
  "$JIRA_BASE_URL/rest/api/3/issue/PROJ-123/transitions" \
  -d '{"transition":{"id":"TARGET_ID"}}'
```

### Add comment
```bash
curl -s -X POST \
  -H "$AUTH" -H "Content-Type: application/json" \
  "$JIRA_BASE_URL/rest/api/3/issue/PROJ-123/comment" \
  -d '{"body":{"version":3,"type":"doc","content":[{"type":"paragraph","content":[{"type":"text","text":"..."}]}]}}'
```

### Create subtask under parent Story
```bash
curl -s -X POST \
  -H "$AUTH" -H "Content-Type: application/json" \
  "$JIRA_BASE_URL/rest/api/3/issue" \
  -d '{
    "fields": {
      "project": {"key": "'"$JIRA_PROJECT_KEY"'"},
      "parent": {"key": "PROJ-123"},
      "summary": "Task N: [task name]",
      "issuetype": {"name": "Subtask"},
      "labels": ["jade-managed", "frontend"],
      "description": {
        "version": 3, "type": "doc",
        "content": [
          {"type": "heading", "attrs": {"level": 3}, "content": [{"type": "text", "text": "Implementation"}]},
          {"type": "paragraph", "content": [{"type": "text", "text": "[action details]"}]},
          {"type": "heading", "attrs": {"level": 3}, "content": [{"type": "text", "text": "Acceptance Criteria"}]},
          {"type": "paragraph", "content": [{"type": "text", "text": "[done criteria]"}]},
          {"type": "heading", "attrs": {"level": 3}, "content": [{"type": "text", "text": "Files"}]},
          {"type": "paragraph", "content": [{"type": "text", "text": "[file list]"}]}
        ]
      }
    }
  }'
```
Response: `{"key":"PROJ-124",...}`

### Create linked issue (relates-to)
Use `issuelinks` field for non-parent relationships.

## GitHub patterns

**PR creation (via `gh` CLI):**
```bash
gh pr create \
  --title "[PROJ-123] Plan objective" \
  --body "$(cat <<'EOF'
## Summary
...
## Jira ticket
$JIRA_BASE_URL/browse/PROJ-123
## TDD Results
...
EOF
)" \
  --base main \
  --head jade/PROJ-123
```

**All other git ops:** Native `git` CLI (branch, commit, push, status, remote). No wrapper needed.

## Mandatory workflow — always in this order

1. `/jade:init` — Project setup
   Collect credentials (stored in `.jade/.env`)
   Conversational project overview
   JADE recommends full multi-phase roadmap
   User refines → JADE creates phase directories

2. `/jade:plan` — Generate ALL phase plans
   Draft PLAN.md for every phase in the roadmap (each task tagged with discipline: frontend|backend|fullstack|devops)
   Present complete set → wait for APPROVE
   After APPROVE: create Jira ticket hierarchy for ALL phases upfront:
     - Parent Story per phase (rich description: objective, ACs in Given/When/Then, scope)
     - Subtask per task (description: implementation, files, ACs, verification + discipline label)
   Full backlog with proper hierarchy visible in Jira immediately

   OR `/jade:plan PROJ-123` — Jira-first mode for team workflows
   Fetch existing ticket → pre-populate PLAN.md → APPROVE → link ticket

   OR `/jade:plan --revise N` — Revise a single phase plan
   Incorporate learnings from completed phases → APPROVE update

3. For each phase:
   a. `/jade:apply`
      Verify GitHub remote is reachable (HARD GATE)
      Jira parent Story + subtasks already exist from plan phase (fallback: create if missing)
      Create feature branch: jade/[jira_key]
      For each task: RED -> GREEN -> REFACTOR
      Commit and push after every task
      Transition subtask to Done + post comment to parent Story after each task
      Transition parent ticket: To Do -> In Progress

   b. `/jade:unify`
      Write SUMMARY.md
      Post summary to Jira as structured comment
      Transition ticket: In Progress -> In Review
      Create child tickets for deferred issues
      Open PR via `gh pr create`

   c. (Optional) Revise next phase plan if earlier phases revealed new information

4. `/jade:verify` (when ready for UAT)
   Show summary and PR link
   User types PASS or FAIL
   On PASS: transition ticket In Review -> Done

## 10 commands — that's it

| Command | What it does |
|---|---|
| `/jade:init` | Credentials, project overview, roadmap, phase directories |
| `/jade:plan` | Plan all / revise / fix / add-phase / remove-phase / Jira-first |
| `/jade:apply` | Execute with TDD, Jira ticket creation, git push per task |
| `/jade:unify` | Summary, Jira post, PR, triage deferred issues |
| `/jade:verify` | UAT gate — PASS or FAIL |
| `/jade:progress` | Status + one next action |
| `/jade:pause` | Full handoff + Jira comment |
| `/jade:resume` | Restore context |
| `/jade:research` | Research topic / phase N / codebase |
| `/jade:help` | Command reference |

## Hard rules — no exceptions

- NEVER begin APPLY without user saying APPROVE
- NEVER write a single line of implementation before the GitHub remote is verified reachable
- NEVER write implementation before a failing test exists for that task
- NEVER skip UNIFY — every phase must close with a summary
- ALWAYS create a feature branch `jade/[jira_key]` before the first task in APPLY
- ALWAYS push to the feature branch after every task — not just at UNIFY
- ALWAYS post task results as Jira comments during APPLY (via curl)
- ALWAYS reference Jira ticket key in commit messages (e.g. feat(PROJ-123): task name)
- ALWAYS open a PR via `gh pr create` during UNIFY
- ALWAYS `source .jade/.env` before any Jira API call
- NEVER modify files listed in PLAN.md <boundaries> section
- NEVER batch multiple tasks through RED phase together
