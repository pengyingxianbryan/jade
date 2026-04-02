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
  Base URL:     [JIRA_BASE_URL from .jade/.env or "not set"]
  Project key:  [JIRA_PROJECT_KEY from .jade/.env or "not set"]
  Email:        [ATLASSIAN_EMAIL from .jade/.env or "not set"]

GitHub
─────────────────────────────────────
  gh CLI:         [gh auth status result]
  Remote verified: [yes/no]
  Git identity:    [from git config]

Project
─────────────────────────────────────
  JADE directory: [.jade/ exists/missing]
  Credentials:    [.jade/.env exists/missing]
  Setup marker:   [.jade/.configured exists/missing]

════════════════════════════════════════

What would you like to do?
[1] View full config
[2] Reconfigure (removes .jade/.configured)
[3] Done
```
</step>

<step name="handle_reconfigure">
If user wants to reconfigure:
1. Remove `.jade/.configured`
2. Print: "Configuration cleared. Run `/jade:init` to reconfigure."
</step>

</process>

<success_criteria>
- [ ] Current Jira config displayed
- [ ] Current GitHub config displayed
- [ ] User can reconfigure if needed
</success_criteria>
