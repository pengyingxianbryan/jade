---
name: jade:init
description: Initialize JADE in a project with conversational setup, Jira and GitHub configuration
argument-hint:
allowed-tools: [Read, Write, Bash, Glob, AskUserQuestion]
---

<objective>
Initialize the `.jade/` structure in a project directory through conversational setup.

**When to use:** Starting a new project with JADE, or adding JADE to an existing codebase.

Creates PROJECT.md, STATE.md, and ROADMAP.md populated from conversation. Verifies Jira and GitHub credentials are configured. If not, triggers credential setup before proceeding.
</objective>

<context>
Current directory state (check for existing .jade/)
</context>

<process>

<step name="check_credentials" priority="first">
Verify JADE prerequisites are met before project setup:

1. Check if `~/.claude/.jade-configured` exists
2. If NOT configured:
   - Print: "JADE requires Jira and GitHub to be configured first."
   - Print: "Running first-time setup..."
   - Prompt for Jira credentials (base URL, project key, email, API token)
   - Prompt for GitHub credentials (repo URL, PAT, default branch, git identity)
   - Write MCP config to ~/.claude.json (Atlassian + GitHub)
   - Write env vars to chosen scope file
   - Touch ~/.claude/.jade-configured sentinel
3. If configured: verify env vars are set (JIRA_PROJECT_KEY, GITHUB_REPO_URL)
</step>

<step name="check_existing">
1. Check for existing .jade/ directory
2. If exists: route to `/jade:resume` — do not re-initialize
3. If not: proceed with setup
</step>

<step name="create_structure">
Create directory structure:
```
.jade/
├── PROJECT.md
├── ROADMAP.md
└── STATE.md
```
</step>

<step name="conversational_setup">
Ask ONE question at a time. Wait for response before next question.

1. Ask: "What's the core value this project delivers?"
2. Ask: "What are you building?" (get specific product/feature description)
3. Confirm project name (infer from directory name)
4. Ask: "What type of project?" (Application / Campaign / Workflow / Other)
5. Ask: "What are the 3-5 core features or deliverables?"
6. Ask: "What's the tech stack?"
</step>

<step name="populate_files">
Populate files from answers:
- PROJECT.md: core value, description, type, features, tech stack
- STATE.md: initialize with correct loop position, Jira section (empty), GitHub section (from env), TDD Results section (empty)
- ROADMAP.md: initialize with project name, placeholder phases
</step>

<step name="verify_github">
Verify GitHub remote is reachable:
1. Run `git remote -v` — check if origin is set
2. Run `git ls-remote origin HEAD` — confirm reachable
3. If fails: warn but don't block init
4. Update STATE.md GitHub section with verification result
</step>

<step name="complete">
Display ONE next action: `/jade:plan`

```
════════════════════════════════════════
JADE INITIALIZED
════════════════════════════════════════

Project: [name]
Directory: .jade/

Files created:
  .jade/PROJECT.md
  .jade/ROADMAP.md
  .jade/STATE.md

Jira project: [JIRA_PROJECT_KEY]
GitHub repo: [GITHUB_REPO_URL]
GitHub remote: [verified/unverified]

────────────────────────────────────────
▶ NEXT: /jade:plan
  Describe your first feature or task.
────────────────────────────────────────
```
</step>

</process>

<success_criteria>
- [ ] Jira and GitHub credentials verified or collected
- [ ] .jade/ directory created
- [ ] PROJECT.md populated with core value and description from conversation
- [ ] STATE.md initialized with correct loop position and Jira/GitHub/TDD sections
- [ ] ROADMAP.md initialized
- [ ] GitHub remote verified (or warned)
- [ ] User presented with ONE clear next action
</success_criteria>
