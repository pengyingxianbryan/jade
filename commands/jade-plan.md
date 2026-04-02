---
name: jade:plan
description: Generate all phase plans, revise a single phase, or link an existing Jira ticket
argument-hint: "[--revise N | ticket-key]"
allowed-tools: [Read, Write, Glob, Bash, AskUserQuestion]
---

<objective>
Create executable plans for the project. Supports three modes:

- `/jade:plan` (no args) → **Plan All mode** — generate PLAN.md for every phase in the roadmap, present all for APPROVE
- `/jade:plan --revise N` → **Revise mode** — update the plan for phase N based on learnings from completed phases
- `/jade:plan PROJ-123` (ticket key) → **Jira-first mode** — link an existing Jira ticket to a single plan

**When to use:** After `/jade:init` has created the roadmap and phase directories.
</objective>

<context>
$ARGUMENTS

@.jade/PROJECT.md
@.jade/STATE.md
@.jade/ROADMAP.md
</context>

<process>

<step name="detect_mode" priority="first">
Check $ARGUMENTS:
- No argument → **Plan All mode**
- `--revise N` → **Revise mode** for phase N
- Matches `[A-Z]+-\d+` → **Jira-first mode**
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- PLAN ALL MODE (DEFAULT)                          -->
<!-- ════════════════════════════════════════════════ -->

<step name="plan_all_generate">
**Only if Plan All mode.**

1. Read ROADMAP.md — get all phases with names, goals, scope, and dependencies
2. Read PROJECT.md — get project context, tech stack, constraints
3. For each phase in the roadmap:
   a. Generate a PLAN.md using the phase goal and scope from ROADMAP.md
   b. Include: objective, acceptance criteria (Given/When/Then), tasks (2-3 max), boundaries, verification
   c. Write to `.jade/phases/{phase-dir}/{phase}-01-PLAN.md`
4. Each plan follows the standard template (frontmatter, objective, ACs, tasks, boundaries)

**Planning approach:** Use PROJECT.md + ROADMAP.md context to draft plans. Ask clarifying questions if scope is ambiguous for any phase. Earlier phases should establish foundations that later phases depend on.
</step>

<step name="plan_all_present">
**Only if Plan All mode.**

Present ALL phase plans as a combined view:

```
════════════════════════════════════════
FULL PROJECT PLAN — [project name]
════════════════════════════════════════

Phase 1: [name]
  Objective: [summary]
  Tasks: [count]
  Files: [key files]

Phase 2: [name]
  Objective: [summary]
  Tasks: [count]
  Files: [key files]

[... all phases ...]

════════════════════════════════════════
```

Then show each plan in full detail sequentially.

**Say exactly:**
> "Here is the complete project plan across all phases. Reply **APPROVE** to begin, or tell me what to change."

**HARD STOP.** Wait for APPROVE. Do not create any Jira ticket, do not proceed to APPLY until APPROVE received.

If user requests changes: revise affected plans and re-present.
</step>

<step name="plan_all_after_approve">
**Only if Plan All mode. Runs automatically after APPROVE.**

1. Source credentials: `source .jade/.env`
2. Create Jira ticket for **phase 1 only** via REST API:
   ```bash
   source .jade/.env
   AUTH="Authorization: Basic $(echo -n "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" | base64)"
   curl -s -X POST \
     -H "$AUTH" -H "Content-Type: application/json" \
     "$JIRA_BASE_URL/rest/api/3/issue" \
     -d '{"fields":{"project":{"key":"'"$JIRA_PROJECT_KEY"'"},"summary":"[from phase 1 objective]","issuetype":{"name":"Story"},"description":{"version":3,"type":"doc","content":[{"type":"paragraph","content":[{"type":"text","text":"[from phase 1 ACs]"}]}]}}}'
   ```
3. Parse response for ticket key (e.g., `PROJ-123`)
4. Write `jira: PROJ-123` to phase 1 PLAN.md frontmatter
5. Update STATE.md: `ticket: PROJ-123`, `status: To Do`, `plans_approved: [ISO timestamp]`

**Subsequent phase tickets are created when each phase starts `/jade:apply`.**

6. Print confirmation:
   ```
   ✅ All plans approved.
   ✅ Jira ticket created for Phase 1: PROJ-123
   ✅ Branch will be: jade/PROJ-123

   Run /jade:apply to begin Phase 1.
   ```
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- REVISE MODE                                      -->
<!-- ════════════════════════════════════════════════ -->

<step name="revise_phase">
**Only if Revise mode (`--revise N`).**

1. Read the existing PLAN.md for phase N from `.jade/phases/{phase-dir}/`
2. Read SUMMARY.md files from completed earlier phases — incorporate learnings
3. Read STATE.md for current project state
4. Revise the plan:
   - Adjust tasks based on what earlier phases revealed
   - Update file references if earlier phases changed structure
   - Modify scope if needed
5. Present revised plan for APPROVE
6. After APPROVE: update the PLAN.md file in place

**Say exactly:**
> "Here is the revised plan for Phase N, incorporating learnings from completed phases. Reply **APPROVE** to accept, or tell me what to change."
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- JIRA-FIRST MODE                                  -->
<!-- ════════════════════════════════════════════════ -->

<step name="jira_first_fetch">
**Only if Jira-first mode.**

1. Source credentials: `source .jade/.env`
2. Fetch ticket from Jira via REST API:
   ```bash
   source .jade/.env
   AUTH="Authorization: Basic $(echo -n "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" | base64)"
   curl -s -H "$AUTH" "$JIRA_BASE_URL/rest/api/3/issue/$TICKET_KEY"
   ```
3. Extract content:
   - Summary → `<objective>`
   - Description + ACs → `<acceptance_criteria>`
   - Out-of-scope / boundaries → `<boundaries>`
4. Pre-populate PLAN.md with extracted content
</step>

<step name="jira_first_present">
**Only if Jira-first mode.**

Present the plan:
> "I've pulled [TICKET-KEY] from Jira and built this plan. Reply **APPROVE** to begin, or tell me what to change."

**HARD STOP.** Wait for APPROVE.
</step>

<step name="jira_first_after_approve">
**Only if Jira-first mode. Runs automatically after APPROVE.**

1. Source credentials: `source .jade/.env`
2. Transition ticket to `To Do` via Jira REST API (2-step: GET transitions, POST correct ID)
3. Write to PLAN.md frontmatter: `jira: [TICKET-KEY]`
4. Write to STATE.md: `ticket: [TICKET-KEY]`, `status: To Do`

5. Print confirmation:
   ```
   ✅ Plan approved.
   ✅ Jira ticket [TICKET-KEY] linked.
   ✅ Branch will be: jade/[TICKET-KEY]

   Run /jade:apply to begin implementation.
   ```
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- COMMON — PLAN STRUCTURE                          -->
<!-- ════════════════════════════════════════════════ -->

<step name="plan_structure">
Every PLAN.md must include:

- **Frontmatter:** phase, plan, type, jira (empty until ticket created), wave, depends_on, files_modified, autonomous
- **`<objective>`** — user story format: "As a [persona], I can [action] so that [outcome]"
- **`<acceptance_criteria>`** — minimum 3 ACs in Given/When/Then format
- **`<tasks>`** — 2-3 tasks max, each with `<name>`, `<files>`, `<action>`, `<verify>`, `<done>`
- **`<boundaries>`** — DO NOT CHANGE list + scope limits
- **`<verification>`** — completion checklist

**Output path:** `.jade/phases/{phase-dir}/{phase}-{plan}-PLAN.md`
Verify the phase directory exists before writing.
</step>

<step name="update_state">
Update STATE.md:
- Loop position: PLAN ◉ (planning complete)
- Current plan path
- Last activity timestamp
- Jira section populated (if ticket created)
</step>

</process>

<success_criteria>
- [ ] Plans generated for scope (all phases / single revision / Jira-first)
- [ ] Each plan has objective, ACs (Given/When/Then), tasks, boundaries
- [ ] Plans written to correct phase directories
- [ ] Plan(s) presented to user and APPROVE received
- [ ] Jira ticket created for phase 1 (Plan All) or linked (Jira-first)
- [ ] STATE.md updated
- [ ] User informed of next action: /jade:apply
</success_criteria>
