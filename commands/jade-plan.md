---
name: jade:plan
description: Plan conversation → APPROVE → Jira ticket auto-created (or link existing ticket)
argument-hint: "[ticket-key]"
allowed-tools: [Read, Write, Glob, AskUserQuestion]
---

<objective>
Create an executable plan through conversation. After user APPROVE, automatically create or link a Jira ticket.

**DEFAULT BEHAVIOUR — no ticket number required.** The user should never need to look up or type a Jira ticket number. JADE creates the ticket automatically after APPROVE in plan-first mode.

**When to use:** Starting new work or resuming incomplete plan.

**Two modes:**
- `/jade:plan` (no argument) → **Plan-first mode (DEFAULT)** — auto-creates Jira ticket after APPROVE
- `/jade:plan PROJ-123` (ticket key argument) → **Jira-first mode** — links existing ticket
</objective>

<context>
$ARGUMENTS

@.jade/PROJECT.md
@.jade/STATE.md
@.jade/ROADMAP.md
</context>

<process>

<step name="detect_mode" priority="first">
Check if user passed a ticket key argument:
- No argument → **Plan-first mode (DEFAULT)**
- Ticket key (e.g., `PROJ-123`) → **Jira-first mode**

Parse: If $ARGUMENTS matches pattern `[A-Z]+-\d+`, it's a ticket key.
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- PLAN-FIRST MODE (DEFAULT)                        -->
<!-- ════════════════════════════════════════════════ -->

<step name="plan_first_conversation">
**Only if plan-first mode.**

Run the full planning conversation. Ask the user ONE question at a time:

1. **Who is this for?** (user persona)
2. **What problem does it solve?**
3. **Why now — what is the metric or driver?**
4. **What does success look like?**
5. **What is explicitly out of scope?**
6. **Are there dependencies?**

Use the answers to shape the plan. Do not ask all questions at once.
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- JIRA-FIRST MODE                                  -->
<!-- ════════════════════════════════════════════════ -->

<step name="jira_first_fetch">
**Only if Jira-first mode.**

1. Fetch ticket from Jira via MCP using the provided key (e.g., `PROJ-123`)
2. Extract content:
   - Summary → `<objective>`
   - Description + ACs → `<acceptance_criteria>`
   - Out-of-scope / boundaries → `<boundaries>`
3. Pre-populate PLAN.md with extracted content
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- COMMON — DRAFT PLAN                              -->
<!-- ════════════════════════════════════════════════ -->

<step name="draft_plan">
Draft the complete PLAN.md:

- **Frontmatter:** phase, plan, type, jira (empty for now), wave, depends_on, files_modified, autonomous
- **`<objective>`** — user story format: "As a [persona], I can [action] so that [outcome]"
- **`<acceptance_criteria>`** — minimum 3 ACs in Given/When/Then format:
  - AC-1: Happy path
  - AC-2: Edge case
  - AC-3: Error/failure case
- **`<tasks>`** — each with `<name>`, `<files>`, `<action>`, `<verify>`, `<done>` fields
- **`<boundaries>`** — explicit DO NOT CHANGE list + scope limits
- **`<verification>`** — completion checklist

**Scope:** 2-3 tasks per plan maximum. If more needed, split into multiple plans.
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- APPROVAL GATE — HARD STOP                        -->
<!-- ════════════════════════════════════════════════ -->

<step name="present_and_approve">
Present the full plan to the user clearly formatted.

**Say exactly (plan-first mode):**
> "Here is your complete plan. Reply **APPROVE** to create the Jira ticket and begin, or tell me what to change."

**Say exactly (Jira-first mode):**
> "I've pulled [TICKET-KEY] from Jira and built this plan. Reply **APPROVE** to begin, or tell me what to change."

**HARD STOP.** Wait for APPROVE. Do not create any Jira ticket, do not move to APPLY, do not write any implementation code until the user says APPROVE or clear equivalent.

If user requests changes: revise plan and re-present. Loop until APPROVE.
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- AFTER APPROVE                                    -->
<!-- ════════════════════════════════════════════════ -->

<step name="after_approve_plan_first">
**Only if plan-first mode. Runs automatically after APPROVE — no further user input required.**

1. Auto-create Jira ticket via Atlassian MCP:
   ```
   Title:       [from <objective> — first sentence]
   Type:        Story (default) | Bug | Task — infer from plan content
   Description: [full <acceptance_criteria> content in Given/When/Then format]
   Priority:    High (default) — adjust based on plan urgency language
   Labels:      [inferred from plan domain — e.g., "checkout", "auth", "api"]
   Project:     [JIRA_PROJECT_KEY from env]
   ```

2. Receive the ticket key from Jira MCP response (e.g., `PROJ-123`)

3. Write automatically — user never types this:
   - `jira: PROJ-123` to PLAN.md frontmatter
   - `ticket: PROJ-123` and `status: To Do` to STATE.md Jira section

4. Print confirmation:
   ```
   ✅ Plan approved.
   ✅ Jira ticket created: PROJ-123
   ✅ Branch will be: jade/PROJ-123

   Run /jade:apply to begin implementation.
   ```
</step>

<step name="after_approve_jira_first">
**Only if Jira-first mode. Runs automatically after APPROVE.**

1. Transition ticket to `To Do` via Jira MCP (if not already)
2. Write to PLAN.md frontmatter: `jira: [TICKET-KEY]`
3. Write to STATE.md: `ticket: [TICKET-KEY]`, `status: To Do`

4. Print confirmation:
   ```
   ✅ Plan approved.
   ✅ Jira ticket [TICKET-KEY] linked.
   ✅ Branch will be: jade/[TICKET-KEY]

   Run /jade:apply to begin implementation.
   ```
</step>

<step name="update_state">
Update STATE.md:
- Loop position: PLAN ◉ (planning complete)
- Current plan path
- Last activity timestamp
- Jira section populated
</step>

</process>

<success_criteria>
- [ ] Planning conversation completed (plan-first) OR ticket fetched (Jira-first)
- [ ] PLAN.md created with objective, ACs, tasks, boundaries
- [ ] Minimum 3 ACs in Given/When/Then format
- [ ] Plan presented to user and APPROVE received
- [ ] Jira ticket created (plan-first) or linked (Jira-first)
- [ ] jira: field written to PLAN.md frontmatter
- [ ] STATE.md updated with Jira ticket key and status
- [ ] User informed of next action: /jade:apply
</success_criteria>
