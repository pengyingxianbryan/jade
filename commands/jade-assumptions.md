---
name: jade:assumptions
description: Surface Claude's assumptions about a phase before planning
argument-hint: "<phase-number>"
allowed-tools: [Read, Bash]
---

<objective>
Surface Claude's assumptions about a phase to validate understanding before planning.

**When to use:** Before planning to catch misconceptions early.

**Distinction from /jade:discuss:** This shows what CLAUDE thinks. Discuss gathers what USER wants.
</objective>

<context>
Phase number: $ARGUMENTS (required)

@.jade/PROJECT.md
@.jade/STATE.md
@.jade/ROADMAP.md
</context>

<process>
1. Read phase scope from ROADMAP.md
2. Read PROJECT.md for context
3. Present assumptions across 5 areas:
   - Architecture approach
   - Key technologies/patterns
   - Dependencies and prerequisites
   - Risk areas
   - Estimated scope/complexity
4. Indicate confidence level per assumption
5. Wait for user corrections
6. Route to `/jade:plan` after validation
</process>

<success_criteria>
- [ ] Assumptions presented across 5 areas
- [ ] Confidence levels indicated
- [ ] User can provide corrections
- [ ] Clear path to planning
</success_criteria>
