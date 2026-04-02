---
name: jade:flows
description: Configure specialized workflow integrations
argument-hint: "[add|audit|list]"
allowed-tools: [Read, Write, Bash, Glob]
---

<objective>
Configure, amend, or audit specialized skill integrations for a JADE project.

**Subcommands:**
- (no argument): Full interactive configuration
- `add`: Quick-add single skill mapping
- `audit`: Check current phase against declared flows
- `list`: Display current configuration
</objective>

<context>
Subcommand: $ARGUMENTS (optional)

@.jade/PROJECT.md
@.jade/STATE.md
@.jade/SPECIAL-FLOWS.md (if exists)
</context>

<process>
**Route based on argument:**

- **No argument:** Interactive skill discovery and mapping → generate .jade/SPECIAL-FLOWS.md
- **`add`:** Quick-add single skill to SPECIAL-FLOWS.md
- **`audit`:** Check required skills for current phase
- **`list`:** Display current configuration summary
</process>

<success_criteria>
- [ ] SPECIAL-FLOWS.md created or updated (for config/add)
- [ ] Current phase skills displayed (for audit)
- [ ] Configuration summary shown (for list)
</success_criteria>
