---
name: jade:plan
description: Plan, revise, fix, or modify the project roadmap
argument-hint: "[--revise N | --fix N | --add-phase <desc> | --remove-phase N | ticket-key]"
allowed-tools: [Read, Write, Glob, Bash, AskUserQuestion]
---

<objective>
The single entry point for all planning and roadmap modifications. Supports six modes:

- `/jade:plan` (no args) → **Plan All mode** — generate PLAN.md for every phase, present all for APPROVE
- `/jade:plan --revise N` → **Revise mode** — update the plan for phase N based on learnings
- `/jade:plan --fix N` → **Fix mode** — create a fix plan from UAT issues for plan N
- `/jade:plan --add-phase <description>` → **Add Phase** — append a new phase to the roadmap
- `/jade:plan --remove-phase N` → **Remove Phase** — remove a future (not started) phase
- `/jade:plan PROJ-123` (ticket key) → **Jira-first mode** — link an existing Jira ticket

**When to use:** After `/jade:init` has created the roadmap and phase directories.

**Built-in planning intelligence:** During Plan All and Revise modes, JADE automatically:
- Surfaces its assumptions about architecture, tech choices, and risks (like the old `/jade:assumptions`)
- Explores phase vision and goals through conversation (like the old `/jade:discuss`)
- Identifies technical unknowns and researches options (like the old `/jade:discover`)

These are not separate steps — they are woven into the planning conversation naturally.
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
- `--fix N` → **Fix mode** for plan N (e.g., `--fix 04-02`)
- `--add-phase <description>` → **Add Phase mode**
- `--remove-phase N` → **Remove Phase mode** for phase N
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

2. **Create parent Story ticket per phase** with rich content, priority, and components via REST API:

   **Priority derivation from `wave` field in PLAN.md frontmatter:**
   - Wave 1 → `"Highest"`
   - Wave 2 → `"High"`
   - Wave 3 → `"Medium"`
   - Wave 4+ → `"Low"`

   ```bash
   source .jade/.env
   AUTH="Authorization: Basic $(echo -n "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" | base64)"
   # Repeat for each phase — build rich ADF description from PLAN.md
   curl -s -X POST \
     -H "$AUTH" -H "Content-Type: application/json" \
     "$JIRA_BASE_URL/rest/api/3/issue" \
     -d '{
       "fields": {
         "project": {"key": "'"$JIRA_PROJECT_KEY"'"},
         "summary": "[Phase N] [from phase objective — first sentence]",
         "issuetype": {"name": "Story"},
         "priority": {"name": "[derived from wave — see mapping above]"},
         "labels": ["jade-managed"],
         "description": {
           "version": 3,
           "type": "doc",
           "content": [
             {"type": "heading", "attrs": {"level": 2}, "content": [{"type": "text", "text": "Objective"}]},
             {"type": "paragraph", "content": [{"type": "text", "text": "[full objective from PLAN.md <objective> section]"}]},
             {"type": "heading", "attrs": {"level": 2}, "content": [{"type": "text", "text": "Acceptance Criteria"}]},
             {"type": "paragraph", "content": [{"type": "text", "text": "[AC-1 name]"}]},
             {"type": "codeBlock", "attrs": {"language": "gherkin"}, "content": [{"type": "text", "text": "Given [precondition]\nWhen [action]\nThen [outcome]"}]},
             {"type": "paragraph", "content": [{"type": "text", "text": "[AC-2 name]"}]},
             {"type": "codeBlock", "attrs": {"language": "gherkin"}, "content": [{"type": "text", "text": "Given [precondition]\nWhen [action]\nThen [outcome]"}]},
             {"type": "paragraph", "content": [{"type": "text", "text": "[AC-3 name]"}]},
             {"type": "codeBlock", "attrs": {"language": "gherkin"}, "content": [{"type": "text", "text": "Given [precondition]\nWhen [action]\nThen [outcome]"}]},
             {"type": "heading", "attrs": {"level": 2}, "content": [{"type": "text", "text": "Scope & Boundaries"}]},
             {"type": "paragraph", "content": [{"type": "text", "text": "[from PLAN.md <boundaries> section — scope limits and protected files]"}]},
             {"type": "heading", "attrs": {"level": 2}, "content": [{"type": "text", "text": "Tasks"}]},
             {"type": "paragraph", "content": [{"type": "text", "text": "[N] subtask(s) — see child tickets for details"}]}
           ]
         }
       }
     }'
   ```
3. For each phase, parse response for parent ticket key (e.g., `PROJ-123`)

4. **Create subtask tickets for each task** in the phase, one per task:
   ```bash
   # For each task in PLAN.md <tasks> section:
   curl -s -X POST \
     -H "$AUTH" -H "Content-Type: application/json" \
     "$JIRA_BASE_URL/rest/api/3/issue" \
     -d '{
       "fields": {
         "project": {"key": "'"$JIRA_PROJECT_KEY"'"},
         "parent": {"key": "PROJ-123"},
         "summary": "Task [N]: [task name]",
         "issuetype": {"name": "Subtask"},
         "priority": {"name": "[inherit from parent Story priority]"},
         "labels": ["jade-managed", "[discipline]"],
         "components": [{"name": "[discipline from <discipline> field]"}],
         "description": {
           "version": 3,
           "type": "doc",
           "content": [
             {"type": "heading", "attrs": {"level": 3}, "content": [{"type": "text", "text": "Discipline"}]},
             {"type": "paragraph", "content": [{"type": "text", "text": "[frontend | backend | fullstack | devops] — from <discipline> field"}]},
             {"type": "heading", "attrs": {"level": 3}, "content": [{"type": "text", "text": "Implementation"}]},
             {"type": "paragraph", "content": [{"type": "text", "text": "[from <action> field — full implementation instructions]"}]},
             {"type": "heading", "attrs": {"level": 3}, "content": [{"type": "text", "text": "Files"}]},
             {"type": "paragraph", "content": [{"type": "text", "text": "[from <files> field]"}]},
             {"type": "heading", "attrs": {"level": 3}, "content": [{"type": "text", "text": "Acceptance Criteria"}]},
             {"type": "paragraph", "content": [{"type": "text", "text": "[from <done> field — links back to parent Story ACs]"}]},
             {"type": "heading", "attrs": {"level": 3}, "content": [{"type": "text", "text": "Verification"}]},
             {"type": "paragraph", "content": [{"type": "text", "text": "[from <verify> field]"}]}
           ]
         }
       }
     }'
   ```
   **Discipline mapping:** The `<discipline>` value (`frontend`, `backend`, `fullstack`, `devops`) is used as both a Jira label AND a component. Components enable default assignee routing and board filtering. Labels provide additional flexibility.

5. **Create issue links for cross-phase dependencies:**

   After all Story tickets are created, build a plan-id → Jira key mapping. Then for each phase whose PLAN.md has a non-empty `depends_on: [...]` array, create a `Blocks` link:
   ```bash
   # For each dependency: the depended-on phase "blocks" the dependent phase
   curl -s -X POST \
     -H "$AUTH" -H "Content-Type: application/json" \
     "$JIRA_BASE_URL/rest/api/3/issueLink" \
     -d '{
       "type": {"name": "Blocks"},
       "inwardIssue": {"key": "[BLOCKER Story key — the depended-on phase]"},
       "outwardIssue": {"key": "[DEPENDENT Story key — the phase with depends_on]"}
     }'
   ```
   This creates visible dependency chains in Jira. The timeline/roadmap view will show these links, and teams can see "if phase 2 slips, phase 3 is blocked."

6. Write `jira: PROJ-XXX` (parent Story key) to each phase's PLAN.md frontmatter
7. Write subtask keys into each task's section in PLAN.md (add `jira_subtask: PROJ-YYY` comment after `<name>`)
8. Update STATE.md: record all parent + subtask ticket keys, `plans_approved: [ISO timestamp]`

**All tickets (parent Stories + subtasks) are created upfront with priority, components, and dependency links. The Jira board shows full backlog with proper hierarchy, priority ordering, and cross-phase dependencies.**

9. Print confirmation:
   ```
   ✅ All plans approved.
   ✅ Jira tickets created for all phases:
     Phase 1: PROJ-123 (Story, Highest)
       ├─ PROJ-124: Task 1 [backend]
       └─ PROJ-125: Task 2 [frontend]
     Phase 2: PROJ-126 (Story, High) — blocked by PROJ-123
       ├─ PROJ-127: Task 1 [fullstack]
       └─ PROJ-128: Task 2 [frontend]
     [... all phases ...]

   Dependencies linked: [N] issue link(s) created.
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
6. After APPROVE:
   a. Update the PLAN.md file in place
   b. Sync changes to Jira — update the parent Story with rich content:
      ```bash
      source .jade/.env
      AUTH="Authorization: Basic $(echo -n "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" | base64)"
      # Update parent Story with full ADF description (same structure as plan_all_after_approve)
      curl -s -X PUT \
        -H "$AUTH" -H "Content-Type: application/json" \
        "$JIRA_BASE_URL/rest/api/3/issue/$JIRA_KEY" \
        -d '{"fields":{"summary":"[updated objective]","description":{... rich ADF with Objective, ACs (Given/When/Then), Scope, Tasks sections ...}}}'
      ```
   c. Sync subtasks — for each task in the revised plan:
      - If subtask already exists (has `jira_subtask:` in PLAN.md): update it via PUT with revised action/files/done/discipline
      - If task is new (no subtask key): create new subtask under parent Story (same structure as plan_all_after_approve step 4)
      - If task was removed: transition orphaned subtask to Done/Cancelled with comment
   d. Post a comment noting the revision:
      ```bash
      curl -s -X POST \
        -H "$AUTH" -H "Content-Type: application/json" \
        "$JIRA_BASE_URL/rest/api/3/issue/$JIRA_KEY/comment" \
        -d '{"body":{"version":3,"type":"doc","content":[{"type":"paragraph","content":[{"type":"text","text":"📝 Plan revised — scope updated based on learnings from earlier phases."}]}]}}'
      ```

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
<!-- FIX MODE                                         -->
<!-- ════════════════════════════════════════════════ -->

<step name="fix_plan">
**Only if Fix mode (`--fix N`, e.g., `--fix 04-02`).**

1. Parse plan argument (e.g., "04-02")
2. Find matching UAT.md file in phase directory (created by `/jade:verify` on FAIL)
3. If not found: error — "No UAT issues found for plan {N}. Run /jade:verify first."
4. Read Jira ticket key from the parent PLAN.md
5. Parse each issue from UAT.md (ID, title, severity, steps to reproduce, AC reference)
6. Create `.jade/phases/{phase-dir}/{plan}-FIX.md`:
   - Frontmatter with `type: fix` and `jira:` from parent plan
   - Objective referencing the parent Jira ticket
   - One task per issue (group related minors)
   - Boundaries: only fix reported issues, no scope creep
   - Prioritize: Blocker → Major → Minor → Cosmetic
7. Present fix plan → wait for APPROVE
8. After APPROVE: "Run /jade:apply to execute fixes."
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- ADD PHASE MODE                                   -->
<!-- ════════════════════════════════════════════════ -->

<step name="add_phase">
**Only if Add Phase mode (`--add-phase <description>`).**

1. Read ROADMAP.md for current phase list
2. Determine next available phase number
3. Add phase to ROADMAP.md with:
   - Name (from description)
   - Goal
   - Dependencies on existing phases
   - Scope placeholder
4. Create phase directory: `.jade/phases/{NN}-{name}/`
5. Create parent Story ticket for the new phase (placeholder — subtasks added when plan is created via `--revise`):
   ```bash
   source .jade/.env
   AUTH="Authorization: Basic $(echo -n "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" | base64)"
   curl -s -X POST \
     -H "$AUTH" -H "Content-Type: application/json" \
     "$JIRA_BASE_URL/rest/api/3/issue" \
     -d '{
       "fields": {
         "project": {"key": "'"$JIRA_PROJECT_KEY"'"},
         "summary": "[Phase N] [from phase goal]",
         "issuetype": {"name": "Story"},
         "priority": {"name": "Medium"},
         "labels": ["jade-managed"],
         "description": {
           "version": 3,
           "type": "doc",
           "content": [
             {"type": "heading", "attrs": {"level": 2}, "content": [{"type": "text", "text": "Objective"}]},
             {"type": "paragraph", "content": [{"type": "text", "text": "[from phase goal]"}]},
             {"type": "paragraph", "content": [{"type": "text", "text": "⏳ Phase added to roadmap. Detailed plan and subtasks pending /jade:plan --revise N."}]}
           ]
         }
       }
     }'
   ```
6. Parse response for ticket key and note it for PLAN.md frontmatter (subtask tickets will be created when `--revise` generates the full plan)
7. Update STATE.md with new ticket key
8. Print: "Phase {N} added: {name}. Jira ticket: PROJ-XXX. Run /jade:plan --revise {N} to create a detailed plan."
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- REMOVE PHASE MODE                                -->
<!-- ════════════════════════════════════════════════ -->

<step name="remove_phase">
**Only if Remove Phase mode (`--remove-phase N`).**

1. Validate phase exists in ROADMAP.md
2. Validate phase has NOT started (cannot remove completed or in-progress phases)
3. If started: STOP — "Cannot remove phase {N}: already {status}."
4. Read `jira:` from the phase's PLAN.md frontmatter (if it exists)
5. If Jira ticket exists, transition it to Done/Cancelled with a comment:
   ```bash
   source .jade/.env
   AUTH="Authorization: Basic $(echo -n "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" | base64)"
   # Post cancellation comment
   curl -s -X POST \
     -H "$AUTH" -H "Content-Type: application/json" \
     "$JIRA_BASE_URL/rest/api/3/issue/$JIRA_KEY/comment" \
     -d '{"body":{"version":3,"type":"doc","content":[{"type":"paragraph","content":[{"type":"text","text":"🚫 Phase removed from roadmap. Ticket cancelled."}]}]}}'
   # Transition to Done/Cancelled (get available transitions first)
   TRANSITIONS=$(curl -s -H "$AUTH" "$JIRA_BASE_URL/rest/api/3/issue/$JIRA_KEY/transitions")
   TRANSITION_ID=$(echo "$TRANSITIONS" | jq -r '.transitions[] | select(.name | test("done|cancel|closed";"i")) | .id' | head -1)
   if [ -n "$TRANSITION_ID" ]; then
     curl -s -X POST -H "$AUTH" -H "Content-Type: application/json" \
       "$JIRA_BASE_URL/rest/api/3/issue/$JIRA_KEY/transitions" \
       -d '{"transition":{"id":"'"$TRANSITION_ID"'"}}'
   fi
   ```
6. Remove from ROADMAP.md
7. Clean up phase directory if empty
8. Renumber subsequent phases in ROADMAP.md
9. Update STATE.md
8. Print: "Phase {N} removed. Subsequent phases renumbered."
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- COMMON — PLAN STRUCTURE                          -->
<!-- ════════════════════════════════════════════════ -->

<step name="plan_structure">
Every PLAN.md must include:

- **Frontmatter:** phase, plan, type, jira (empty until ticket created), wave, depends_on, files_modified, autonomous
- **`<objective>`** — user story format: "As a [persona], I can [action] so that [outcome]"
- **`<acceptance_criteria>`** — minimum 3 ACs in Given/When/Then format
- **`<tasks>`** — 2-3 tasks max, each with `<name>`, `<discipline>` (frontend|backend|fullstack|devops), `<files>`, `<action>`, `<verify>`, `<done>`
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
- [ ] Jira tickets created for ALL phases (Plan All) or linked (Jira-first)
- [ ] STATE.md updated
- [ ] User informed of next action: /jade:apply
</success_criteria>
