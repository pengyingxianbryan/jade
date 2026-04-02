---
name: jade:milestone
description: Create a new milestone in the project
argument-hint: "[milestone-name]"
allowed-tools: [Read, Write, Edit, Bash, Glob, AskUserQuestion]
---

<objective>
Create a new milestone with defined scope and phases.

**When to use:** Starting a new milestone cycle after completing the previous one.
</objective>

<context>
$ARGUMENTS

@.jade/PROJECT.md
@.jade/STATE.md
@.jade/ROADMAP.md
</context>

<process>
1. Guide through milestone definition (name, scope, phases)
2. Create milestone entry in MILESTONES.md
3. Update ROADMAP.md with milestone grouping
4. Update STATE.md to reflect new milestone
</process>

<success_criteria>
- [ ] Milestone created in MILESTONES.md
- [ ] ROADMAP.md updated
- [ ] STATE.md reflects new milestone
</success_criteria>
