---
name: jade:research
description: Research a topic, phase unknowns, or map the codebase using subagents
argument-hint: "<topic | phase N | codebase>"
allowed-tools: [Read, Write, Bash, Glob, Grep, AskUserQuestion]
---

<objective>
The single entry point for all research and discovery. Spawns subagents to gather information and saves findings for review.

**Modes (auto-detected from argument):**
- `/jade:research <topic>` → Research a specific topic (API, library, pattern, etc.)
- `/jade:research phase N` → Identify and research unknowns for phase N
- `/jade:research codebase` → Map the existing codebase structure and patterns

**When to use:** Before planning when you need context, or anytime you need to investigate something.
</objective>

<context>
$ARGUMENTS (required)

@.jade/PROJECT.md
@.jade/STATE.md
@.jade/ROADMAP.md
</context>

<process>

<step name="detect_mode" priority="first">
Parse $ARGUMENTS:
- Starts with "phase" followed by a number → **Phase Research mode**
- Equals "codebase" → **Codebase Map mode**
- Anything else → **Topic Research mode**
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- TOPIC RESEARCH                                   -->
<!-- ════════════════════════════════════════════════ -->

<step name="topic_research">
**Only if Topic Research mode.**

1. Validate topic is substantive (not a trivial lookup)
2. Determine research approach:
   - Code-related → spawn Explore subagent
   - External/web → spawn research subagent
   - Mixed → spawn both in parallel
3. Save findings to `.jade/research/{topic-slug}.md`
4. Present summary with key findings and recommendations
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- PHASE RESEARCH                                   -->
<!-- ════════════════════════════════════════════════ -->

<step name="phase_research">
**Only if Phase Research mode (`phase N`).**

1. Validate phase exists in ROADMAP.md
2. Read phase scope, goals, and dependencies
3. Analyze phase for unknowns across categories:
   - **Codebase:** existing patterns, relevant files, integration points
   - **External:** APIs, libraries, services to integrate
   - **Architecture:** design decisions needed
4. Present unknowns to user for confirmation before researching
5. Spawn parallel research agents (max 3) for confirmed unknowns
6. Consolidate findings into `.jade/phases/{NN}-{name}/RESEARCH.md`
7. Present summary with recommendations for planning
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- CODEBASE MAP                                     -->
<!-- ════════════════════════════════════════════════ -->

<step name="codebase_map">
**Only if Codebase Map mode.**

1. Check if `.jade/codebase/` exists (offer refresh/update/skip)
2. Create `.jade/codebase/` directory
3. Spawn parallel Explore agents to analyze:
   - Technology stack and dependencies
   - Architecture and file structure
   - Code conventions and patterns
   - Testing patterns and coverage
   - External integrations
   - Areas of concern
4. Aggregate findings into structured documents:
   - `.jade/codebase/STACK.md` — tech stack overview
   - `.jade/codebase/ARCHITECTURE.md` — structure and patterns
   - `.jade/codebase/CONVENTIONS.md` — coding standards found
5. Present summary and offer next steps
</step>

</process>

<success_criteria>
- [ ] Research mode correctly detected
- [ ] Appropriate subagents spawned
- [ ] Findings saved to correct location (.jade/research/ or .jade/phases/ or .jade/codebase/)
- [ ] Summary presented with actionable recommendations
</success_criteria>
