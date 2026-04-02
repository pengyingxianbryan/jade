---
name: jade:discover
description: Research technical options before planning a phase
argument-hint: "<phase or topic>"
allowed-tools: [Read, Bash, Glob, Grep, WebSearch, WebFetch, Task, AskUserQuestion]
---

<objective>
Execute discovery to inform planning decisions. Produces DISCOVERY.md with findings, recommendation, and confidence level.

**When to use:** Before planning a phase with technical unknowns (library selection, architecture decisions, integration approaches).

**Distinct from /jade:research:** Research gathers documentation. Discover makes technical decisions.
</objective>

<context>
$ARGUMENTS (phase number or topic)

@.jade/STATE.md
@.jade/ROADMAP.md
</context>

<process>
1. Determine depth level (quick/standard/deep)
2. Identify unknowns for the phase
3. Research options using subagents
4. Cross-verify findings
5. Create `.jade/phases/{NN}-{name}/DISCOVERY.md` with recommendation
6. Assign confidence level
7. Route to planning when complete
</process>

<success_criteria>
- [ ] Discovery depth determined
- [ ] Options researched with sources
- [ ] DISCOVERY.md created with recommendation
- [ ] Ready for /jade:plan
</success_criteria>
