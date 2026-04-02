---
name: jade:map-codebase
description: Generate codebase map for context
allowed-tools: [Read, Write, Bash, Glob, Grep, Task]
---

<objective>
Analyze existing codebase and create structured documentation in `.jade/codebase/`.

Spawns parallel Explore agents to analyze technology stack, architecture, conventions, testing patterns, external integrations, and areas of concern.

**When to use:** At project start or when onboarding to an existing codebase.
</objective>

<context>
@.jade/PROJECT.md
@.jade/STATE.md
</context>

<process>
1. Check if .jade/codebase/ exists (offer refresh/update/skip)
2. Create directory structure
3. Spawn parallel Explore agents for stack, architecture, conventions, concerns
4. Aggregate findings into structured documents
5. Write codebase documents
6. Offer next steps
</process>

<success_criteria>
- [ ] .jade/codebase/ directory created
- [ ] Documents populated with actual file paths
- [ ] User informed of next steps
</success_criteria>
