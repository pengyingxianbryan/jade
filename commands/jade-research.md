---
name: jade:research
description: Research a topic using subagents for discovery
argument-hint: "<topic> [--codebase | --web]"
allowed-tools: [Read, Task, Bash, Write]
---

<objective>
Research a specific topic using subagents and save findings for review.

**When to use:** When you need to gather information on a topic before planning or implementing.
</objective>

<context>
Topic: $ARGUMENTS (required)

@.jade/PROJECT.md
@.jade/STATE.md
</context>

<process>
1. Validate topic is substantive (not trivial lookup)
2. Determine agent type:
   - `--codebase` flag → Explore agent
   - `--web` flag → general-purpose agent
   - No flag → auto-detect based on topic
3. Spawn research subagent
4. Save findings to `.jade/research/{topic-slug}.md`
5. Present summary for review
</process>

<success_criteria>
- [ ] Topic validated
- [ ] Appropriate agent type selected
- [ ] Findings saved to .jade/research/
- [ ] Summary presented
</success_criteria>
