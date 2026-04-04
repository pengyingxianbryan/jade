---
name: pm:init
description: Initialize PM in a project with GitHub configuration and project setup
argument-hint:
allowed-tools: [Read, Write, Bash, Glob, AskUserQuestion]
---

<objective>
Initialize PM for a project: verify GitHub access, understand the project, generate a roadmap, and create phase directories.

**When to use:** Starting a new project with PM, or adding PM to an existing codebase.
</objective>

<context>
Current directory state (check for existing .pm/)
</context>

<process>

<!-- ════════════════════════════════════════════════ -->
<!-- STEP 1 — GITHUB SETUP                            -->
<!-- ════════════════════════════════════════════════ -->

<step name="check_credentials" priority="first">
1. Check if `.pm/.configured` exists
2. If configured: verify:
   - Run `gh auth status` — confirm GitHub CLI is authenticated
   - Verify git remote: `git ls-remote origin HEAD` — confirm repo is reachable
   - If both pass: skip to Step 2
   - If either fails: warn and offer to reconfigure

3. If NOT configured:
   a. Check `gh auth status` — if not authenticated, instruct: "Run `gh auth login` first, then re-run `/pm:init`." STOP.
   b. Collect GitHub repo:
      - Ask for GitHub repo URL (e.g., `https://github.com/org/repo` or `git@github.com:org/repo.git`)
      - Check current `git remote -v` — if `origin` already exists and matches, confirm and skip
      - If `origin` exists but differs: ask if they want to update it
      - If no `origin`: run `git remote add origin <repo_url>`
      - Verify connectivity: `git ls-remote origin HEAD`
        If fails: warn but allow retry or continue
   c. Create `.pm/` directory
   d. Write `.pm/.env`:
      ```
      GITHUB_REPO="https://github.com/org/repo"
      ```
   e. Add `.pm/.env` to `.gitignore` (if not already present)
   f. Touch `.pm/.configured`
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- STEP 2 — PROJECT OVERVIEW                        -->
<!-- ════════════════════════════════════════════════ -->

<step name="check_existing">
1. Check for existing `.pm/PROJECT.md`
2. If exists: route to `/pm:resume` — do not re-initialize
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
.pm/
├── PROJECT.md          (populated from conversation)
├── ROADMAP.md          (populated from roadmap)
├── STATE.md            (initialized)
├── .env                (GitHub repo URL)
├── .configured         (sentinel)
└── phases/
    ├── 01-[phase-name]/
    ├── 02-[phase-name]/
    ├── 03-[phase-name]/
    └── ...
```

Write ROADMAP.md with full phase details (goals, dependencies, scope).
Write STATE.md with initialized loop position.
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- COMPLETION                                       -->
<!-- ════════════════════════════════════════════════ -->

<step name="complete">
Display:

```
════════════════════════════════════════
PM INITIALIZED
════════════════════════════════════════

Project: [name]
Phases: [N] created

  .pm/phases/
  ├── 01-[name]/
  ├── 02-[name]/
  └── 03-[name]/

GitHub: [GITHUB_REPO] (gh authenticated)
Remote: [verified/unverified]

────────────────────────────────────────
▶ NEXT: /pm:plan
  Generate plans for all phases.
────────────────────────────────────────
```
</step>

</process>

<success_criteria>
- [ ] gh CLI authenticated (or user directed to authenticate)
- [ ] GitHub repo collected, origin remote configured, and connectivity verified
- [ ] .pm/.env created with GITHUB_REPO
- [ ] .pm/.env added to .gitignore
- [ ] .pm/.configured sentinel created
- [ ] Project conversation completed — PROJECT.md populated
- [ ] Roadmap proposed, refined, and approved
- [ ] ROADMAP.md written with all phase details
- [ ] Phase directories created under .pm/phases/
- [ ] STATE.md initialized
- [ ] User presented with ONE clear next action: /pm:plan
</success_criteria>
