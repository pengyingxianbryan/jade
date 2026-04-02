---
name: jade:research-phase
description: Research unknowns for a phase using subagents
argument-hint: "<phase-number>"
allowed-tools: [Read, Task, Bash, Write]
---

<objective>
Analyze a phase for unknowns and research them using subagents.

**When to use:** Before planning a phase when there are technical unknowns.

**Distinction from /jade:research:** Research is user-directed. Research-phase is Claude-directed — Claude identifies what needs researching.
</objective>

<context>
Phase number: $ARGUMENTS (required)

@.jade/PROJECT.md
@.jade/STATE.md
@.jade/ROADMAP.md
</context>

<process>
1. Validate phase exists in ROADMAP.md
2. Analyze phase for unknowns (codebase, web/docs, architecture)
3. Present unknowns to user for confirmation
4. Spawn parallel research agents (max 3)
5. Consolidate findings into `.jade/phases/{NN}-{name}/RESEARCH.md`
6. Present summary with next steps
</process>

<success_criteria>
- [ ] Phase validated against ROADMAP.md
- [ ] Unknowns identified and classified
- [ ] User confirmed research list
- [ ] Findings consolidated
- [ ] Summary presented
</success_criteria>
