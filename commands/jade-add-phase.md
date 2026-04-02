---
name: jade:add-phase
description: Add a new phase to current milestone
argument-hint: "[phase-name]"
allowed-tools: [Read, Write, Edit, Bash]
---

<objective>
Add a new phase to the current milestone's roadmap.

**When to use:** Scope expansion during milestone, adding planned work.
</objective>

<context>
$ARGUMENTS

@.jade/PROJECT.md
@.jade/STATE.md
@.jade/ROADMAP.md
</context>

<process>
1. Parse phase name from arguments
2. Add phase to ROADMAP.md with next available number
3. Create phase directory
4. Update STATE.md
</process>

<success_criteria>
- [ ] Phase added to ROADMAP.md
- [ ] Phase directory created
- [ ] STATE.md updated
</success_criteria>
