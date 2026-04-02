---
name: jade:config
description: View or modify JADE configuration including Jira and GitHub settings
allowed-tools: [Read, Write, Bash, AskUserQuestion]
---

<objective>
Manage JADE project configuration, including Jira and GitHub integration settings.

**When to use:**
- View current Jira/GitHub configuration
- Enable/disable integrations
- Change project settings
- Reconfigure credentials
</objective>

<context>
@.jade/STATE.md
</context>

<process>

<step name="display_config">
Display current configuration:

```
════════════════════════════════════════
JADE CONFIGURATION
════════════════════════════════════════

Jira
─────────────────────────────────────
  Base URL:     [JIRA_BASE_URL or "not set"]
  Project key:  [JIRA_PROJECT_KEY or "not set"]
  Email:        [ATLASSIAN_EMAIL or "not set"]
  MCP server:   [configured/not configured in ~/.claude.json]

GitHub
─────────────────────────────────────
  Repository:   [GITHUB_REPO_URL or "not set"]
  Default branch: [GITHUB_DEFAULT_BRANCH or "main"]
  Remote verified: [yes/no]
  MCP server:   [configured/not configured in ~/.claude.json]
  Git identity: [GIT_USER_NAME] <[GIT_USER_EMAIL]>

Project
─────────────────────────────────────
  JADE directory: [.jade/ exists/missing]
  Setup marker:   [~/.claude/.jade-configured exists/missing]

════════════════════════════════════════

What would you like to do?
[1] View full config
[2] Reconfigure (removes ~/.claude/.jade-configured)
[3] Done
```
</step>

<step name="handle_reconfigure">
If user wants to reconfigure:
1. Remove `~/.claude/.jade-configured`
2. Print: "Configuration cleared. Run `/jade:init` to reconfigure."
</step>

</process>

<success_criteria>
- [ ] Current Jira config displayed
- [ ] Current GitHub config displayed
- [ ] User can reconfigure if needed
</success_criteria>
