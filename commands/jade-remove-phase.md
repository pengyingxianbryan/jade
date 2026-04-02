---
name: jade:remove-phase
description: Remove a future (not started) phase
argument-hint: "<phase-number-or-name>"
allowed-tools: [Read, Write, Edit, Bash]
---

<objective>
Remove a future phase from the roadmap and clean up its directory.

**When to use:** Scope reduction, removing phases that haven't started.
</objective>

<context>
$ARGUMENTS

@.jade/PROJECT.md
@.jade/STATE.md
@.jade/ROADMAP.md
</context>

<process>
1. Validate phase exists and hasn't started (cannot remove completed/in-progress)
2. Remove from ROADMAP.md
3. Clean up phase directory if empty
4. Renumber subsequent phases
5. Update STATE.md
</process>

<success_criteria>
- [ ] Phase removed from ROADMAP.md
- [ ] Phase directory cleaned up
- [ ] Subsequent phases renumbered
- [ ] STATE.md updated
</success_criteria>
