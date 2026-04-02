---
name: jade:discuss
description: Explore and articulate phase vision before planning
argument-hint: "<phase-number>"
allowed-tools: [Read, Write, AskUserQuestion]
---

<objective>
Facilitate vision discussion for a specific phase and create context handoff.

**When to use:** Before planning a phase, when goals and approach need exploration.
</objective>

<context>
Phase number: $ARGUMENTS (required)

@.jade/PROJECT.md
@.jade/STATE.md
@.jade/ROADMAP.md
</context>

<process>
1. Read phase details from ROADMAP.md
2. Facilitate conversational exploration of goals and approach
3. Create `.jade/phases/{NN}-{name}/CONTEXT.md` capturing vision
4. Route to `/jade:plan` when complete
</process>

<success_criteria>
- [ ] CONTEXT.md created in phase directory
- [ ] Goals and approach articulated
- [ ] Ready for /jade:plan
</success_criteria>
