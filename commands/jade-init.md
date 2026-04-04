---
name: jade:init
description: Initialize JADE in a project with conversational setup, Jira and GitHub configuration
argument-hint:
allowed-tools: [Read, Write, Bash, Glob, AskUserQuestion]
---

<objective>
Initialize JADE for a project: collect credentials, understand the project, generate a roadmap, and create phase directories.

**When to use:** Starting a new project with JADE, or adding JADE to an existing codebase.
</objective>

<context>
Current directory state (check for existing .jade/)
</context>

<process>

<!-- ════════════════════════════════════════════════ -->
<!-- STEP 1 — CREDENTIALS                             -->
<!-- ════════════════════════════════════════════════ -->

<step name="check_credentials" priority="first">
1. Check if `.jade/.configured` exists
2. If configured: source `.jade/.env` and verify:
   - Run `gh auth status` — confirm GitHub CLI is authenticated
   - Verify git remote: `git ls-remote origin HEAD` — confirm repo is reachable
   - Run a Jira connectivity test:
     ```bash
     source .jade/.env
     AUTH="Authorization: Basic $(echo -n "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" | base64)"
     curl -s -o /dev/null -w "%{http_code}" -H "$AUTH" "$JIRA_BASE_URL/rest/api/3/myself"
     ```
   - If both pass: skip to Step 2
   - If either fails: warn and offer to reconfigure

3. If NOT configured:
   a. Check `gh auth status` — if not authenticated, instruct: "Run `gh auth login` first, then re-run `/jade:init`." STOP.
   b. Collect GitHub repo (ask before Jira credentials):
      - Ask for GitHub repo URL (e.g., `https://github.com/org/repo` or `git@github.com:org/repo.git`)
      - Check current `git remote -v` — if `origin` already exists and matches, confirm and skip
      - If `origin` exists but differs: ask if they want to update it
      - If no `origin`: run `git remote add origin <repo_url>`
      - Verify connectivity: `git ls-remote origin HEAD`
        If fails: warn but allow retry or continue
   c. Collect Jira credentials ONE question at a time:
      - Jira base URL (e.g., `https://yourcompany.atlassian.net`)
      - Jira project key (e.g., `ENG`)
      - Atlassian email
      - Atlassian API token (link: https://id.atlassian.com/manage-profile/security/api-tokens)
   d. Create `.jade/` directory
   e. Write `.jade/.env`:
      ```
      JIRA_BASE_URL="https://yourcompany.atlassian.net"
      JIRA_PROJECT_KEY="ENG"
      ATLASSIAN_EMAIL="you@yourcompany.com"
      ATLASSIAN_API_TOKEN="your_token"
      GITHUB_REPO="https://github.com/org/repo"
      ```
   f. Add `.jade/.env` to `.gitignore` (if not already present)
   g. Verify Jira connectivity:
      ```bash
      source .jade/.env
      AUTH="Authorization: Basic $(echo -n "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" | base64)"
      curl -s -H "$AUTH" "$JIRA_BASE_URL/rest/api/3/myself"
      ```
      If fails: warn but allow retry or continue
   h. Touch `.jade/.configured`
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- STEP 2 — PROJECT OVERVIEW                        -->
<!-- ════════════════════════════════════════════════ -->

<step name="check_existing">
1. Check for existing `.jade/PROJECT.md`
2. If exists: route to `/jade:resume` — do not re-initialize
3. If not: proceed with project conversation
</step>

<step name="project_conversation">
Have an open-ended conversation to understand the project. Ask follow-up questions as needed.

Start with: **"What are you building?"**

Through conversation, establish:
- What the product/feature is
- Who it's for (target users)
- Core value proposition
- Tech stack and constraints
- Key features / deliverables (3-5)
- What's explicitly out of scope

Do NOT use a rigid question script. Adapt to what the user shares. If they give a comprehensive overview upfront, don't re-ask what they've already covered.

Populate PROJECT.md from the conversation:
- Core value, description, type, features, tech stack, constraints, target users
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- STEP 3 — ROADMAP RECOMMENDATION                  -->
<!-- ════════════════════════════════════════════════ -->

<step name="recommend_roadmap">
Based on the project overview, propose a full multi-phase roadmap:

1. Analyze the project scope, dependencies, and complexity
2. Break into phases (typically 3-8 phases):
   - Phase 1 is always foundation/setup
   - Middle phases deliver core features (vertical slices preferred)
   - Final phase is polish/deployment
3. For each phase, define:
   - Name and goal
   - Key deliverables
   - Dependencies on other phases
   - Estimated scope (number of plans)

Present the roadmap:
```
════════════════════════════════════════
PROPOSED ROADMAP — [project name]
════════════════════════════════════════

Phase 1: [name]
  Goal: [what this delivers]
  Scope: [deliverables]

Phase 2: [name]
  Goal: [what this delivers]
  Depends on: Phase 1
  Scope: [deliverables]

[... all phases ...]

════════════════════════════════════════
```

Ask: "Does this roadmap look right? Adjust anything, or say **APPROVE** to proceed."

If user requests changes: revise and re-present. Loop until approved.
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- STEP 4 — CREATE PHASE DIRECTORIES                -->
<!-- ════════════════════════════════════════════════ -->

<step name="create_structure">
After roadmap is approved, create the full directory structure:

```
.jade/
├── PROJECT.md          (populated from conversation)
├── ROADMAP.md          (populated from roadmap)
├── STATE.md            (initialized)
├── .env                (credentials — already created)
├── .configured         (sentinel — already created)
└── phases/
    ├── 01-[phase-name]/
    ├── 02-[phase-name]/
    ├── 03-[phase-name]/
    └── ...
```

Write ROADMAP.md with full phase details (goals, dependencies, scope).
Write STATE.md with initialized loop position, empty Jira/GitHub/TDD sections.
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- COMPLETION                                       -->
<!-- ════════════════════════════════════════════════ -->

<step name="complete">
Display:

```
════════════════════════════════════════
JADE INITIALIZED
════════════════════════════════════════

Project: [name]
Phases: [N] created

  .jade/phases/
  ├── 01-[name]/
  ├── 02-[name]/
  └── 03-[name]/

Jira: [JIRA_PROJECT_KEY] @ [JIRA_BASE_URL]
GitHub: [GITHUB_REPO] (gh authenticated ✅)
Remote: [verified/unverified]

────────────────────────────────────────
▶ NEXT: /jade:plan
  Generate plans for all phases.
────────────────────────────────────────
```
</step>

</process>

<success_criteria>
- [ ] gh CLI authenticated (or user directed to authenticate)
- [ ] GitHub repo collected, origin remote configured, and connectivity verified
- [ ] Jira credentials collected and verified
- [ ] .jade/.env created with credentials (including GITHUB_REPO)
- [ ] .jade/.env added to .gitignore
- [ ] .jade/.configured sentinel created
- [ ] Project conversation completed — PROJECT.md populated
- [ ] Roadmap proposed, refined, and approved
- [ ] ROADMAP.md written with all phase details
- [ ] Phase directories created under .jade/phases/
- [ ] STATE.md initialized
- [ ] User presented with ONE clear next action: /jade:plan
</success_criteria>
