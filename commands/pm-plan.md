---
name: pm:plan
description: Plan, revise, fix, or modify the project roadmap
argument-hint: "[--revise N | --fix N | --add-phase <desc> | --remove-phase N]"
allowed-tools: [Read, Write, Glob, Bash, AskUserQuestion]
---

<objective>
The single entry point for all planning and roadmap modifications. Supports five modes:

- `/pm:plan` (no args) → **Plan All mode** — generate PLAN.md for every phase, present all for APPROVE
- `/pm:plan --revise N` → **Revise mode** — update the plan for phase N based on learnings
- `/pm:plan --fix N` → **Fix mode** — create a fix plan from UAT issues for plan N
- `/pm:plan --add-phase <description>` → **Add Phase** — append a new phase to the roadmap
- `/pm:plan --remove-phase N` → **Remove Phase** — remove a future (not started) phase

**When to use:** After `/pm:init` has created the roadmap and phase directories.

**Built-in planning intelligence:** During Plan All and Revise modes, PM automatically:
- Surfaces its assumptions about architecture, tech choices, and risks
- Explores phase vision and goals through conversation
- Identifies technical unknowns and researches options

These are not separate steps — they are woven into the planning conversation naturally.
</objective>

<context>
$ARGUMENTS

@.pm/PROJECT.md
@.pm/STATE.md
@.pm/ROADMAP.md
</context>

<process>

<step name="detect_mode" priority="first">
Check $ARGUMENTS:
- No argument → **Plan All mode**
- `--revise N` → **Revise mode** for phase N
- `--fix N` → **Fix mode** for plan N (e.g., `--fix 04-02`)
- `--add-phase <description>` → **Add Phase mode**
- `--remove-phase N` → **Remove Phase mode** for phase N
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- PLAN ALL MODE (DEFAULT)                          -->
<!-- ════════════════════════════════════════════════ -->

<step name="plan_all_generate">
**Only if Plan All mode.**

1. Read ROADMAP.md — get all phases with names, goals, scope, and dependencies
2. Read PROJECT.md — get project context, tech stack, constraints
3. For each phase in the roadmap:
   a. Generate a PLAN.md in clean, readable markdown format (see plan_structure step)
   b. Include: objective, acceptance criteria, tasks (2-3 max), boundaries, verification
   c. Write to `.pm/phases/{phase-dir}/{phase}-01-PLAN.md`
4. Each plan uses human-readable markdown with clear headers — no XML tags in the output

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

**HARD STOP.** Wait for APPROVE. Do not proceed to APPLY until APPROVE received.

If user requests changes: revise affected plans and re-present.
</step>

<step name="plan_all_after_approve">
**Only if Plan All mode. Runs automatically after APPROVE.**

1. **Create local Story/Task hierarchy for ALL phases:**

   For each phase:
   a. Create `STORY.md` in the phase directory using the STORY.md template:
      - Populate from PLAN.md: objective, acceptance criteria, scope, task summary
      - Set status: `To Do`
      - Set priority from wave field (Wave 1=Highest, 2=High, 3=Medium, 4+=Low)

   b. Create `tasks/` subdirectory in the phase directory

   c. For each task in the PLAN.md, create `tasks/TASK-{NN}.md` using the TASK.md template:
      - Populate from plan: name, discipline, description, acceptance criteria, files, verification
      - Set status: `To Do`
      - Inherit priority from parent Story
      - Link back to parent STORY.md

2. Update STATE.md: record `plans_approved: [ISO timestamp]`

3. Print confirmation:
   ```
   All plans approved. Local tracking created:

     Phase 1: [name]
       ├── STORY.md (Highest priority)
       ├── tasks/TASK-01.md [backend]
       └── tasks/TASK-02.md [frontend]
     Phase 2: [name]
       ├── STORY.md (High priority)
       ├── tasks/TASK-01.md [fullstack]
       └── tasks/TASK-02.md [frontend]
     [... all phases ...]

   Run /pm:apply to begin Phase 1.
   ```
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- REVISE MODE                                      -->
<!-- ════════════════════════════════════════════════ -->

<step name="revise_phase">
**Only if Revise mode (`--revise N`).**

1. Read the existing PLAN.md for phase N from `.pm/phases/{phase-dir}/`
2. Read SUMMARY.md files from completed earlier phases — incorporate learnings
3. Read STATE.md for current project state
4. Revise the plan:
   - Adjust tasks based on what earlier phases revealed
   - Update file references if earlier phases changed structure
   - Modify scope if needed
5. Present revised plan for APPROVE
6. After APPROVE:
   a. Update the PLAN.md file in place
   b. Update STORY.md with revised objective, ACs, scope
   c. Sync task files — for each task in the revised plan:
      - If TASK-NN.md already exists: update with revised details
      - If task is new: create new TASK-NN.md
      - If task was removed: mark as cancelled in TASK-NN.md

**Say exactly:**
> "Here is the revised plan for Phase N, incorporating learnings from completed phases. Reply **APPROVE** to accept, or tell me what to change."
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- FIX MODE                                         -->
<!-- ════════════════════════════════════════════════ -->

<step name="fix_plan">
**Only if Fix mode (`--fix N`, e.g., `--fix 04-02`).**

1. Parse plan argument (e.g., "04-02")
2. Find matching UAT.md file in phase directory (created by `/pm:verify` on FAIL)
3. If not found: error — "No UAT issues found for plan {N}. Run /pm:verify first."
4. Parse each issue from UAT.md (ID, title, severity, steps to reproduce, AC reference)
5. Create `.pm/phases/{phase-dir}/{plan}-FIX.md`:
   - Frontmatter with `type: fix`
   - Objective referencing the original plan
   - One task per issue (group related minors)
   - Boundaries: only fix reported issues, no scope creep
   - Prioritize: Blocker → Major → Minor → Cosmetic
6. Present fix plan → wait for APPROVE
7. After APPROVE:
   - Create TASK-NN.md files for each fix task
   - "Run /pm:apply to execute fixes."
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
4. Create phase directory: `.pm/phases/{NN}-{name}/`
5. Print: "Phase {N} added: {name}. Run /pm:plan --revise {N} to create a detailed plan."
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- REMOVE PHASE MODE                                -->
<!-- ════════════════════════════════════════════════ -->

<step name="remove_phase">
**Only if Remove Phase mode (`--remove-phase N`).**

1. Validate phase exists in ROADMAP.md
2. Validate phase has NOT started (cannot remove completed or in-progress phases)
3. If started: STOP — "Cannot remove phase {N}: already {status}."
4. Remove from ROADMAP.md
5. Clean up phase directory if empty
6. Renumber subsequent phases in ROADMAP.md
7. Update STATE.md
8. Print: "Phase {N} removed. Subsequent phases renumbered."
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- COMMON — PLAN STRUCTURE                          -->
<!-- ════════════════════════════════════════════════ -->

<step name="plan_structure">
Every PLAN.md must be written in **clean, readable markdown** that a non-technical person can understand. No XML tags in the output file.

**Format:**

```markdown
---
phase: XX-name
plan: NN
type: execute
wave: N
depends_on: []
files_modified: []
autonomous: true
---

# Phase N: [Phase Name]

## Objective

**Goal:** [What this plan accomplishes — specific, measurable]

**Purpose:** [Why this matters for the project]

**Output:** [What artifacts will be created/modified]

## Acceptance Criteria

- [ ] **AC-1: [Name]** — [Condition: task is complete when X is achieved]
- [ ] **AC-2: [Name]** — [Validated by Y]
- [ ] **AC-3: [Name]** — [Verified via Z]

## Tasks

### Task 1: [Action-oriented name]

| Field | Value |
|-------|-------|
| Discipline | frontend / backend / fullstack / devops |
| Status | pending |
| Files | `path/to/file1.ts`, `path/to/file2.ts` |

**What to do:**
- [Specific implementation instructions]
- [What to avoid and WHY]

**Verification:** `[command to prove it worked]`

**Done when:** [Links to AC-N — measurable acceptance criteria]

---

### Task 2: [Action-oriented name]

[Same structure as Task 1]

---

## Boundaries

### Do Not Change
- [Protected file or pattern]

### Scope Limits
- [What's explicitly out of scope for this plan]

## Verification Checklist

- [ ] [Specific test command]
- [ ] [Build/type check passes]
- [ ] All acceptance criteria met
```

**Output path:** `.pm/phases/{phase-dir}/{phase}-{plan}-PLAN.md`
Verify the phase directory exists before writing.
</step>

<step name="update_state">
Update STATE.md:
- Loop position: PLAN (planning complete)
- Current plan path
- Last activity timestamp
</step>

</process>

<success_criteria>
- [ ] Plans generated for scope (all phases / single revision)
- [ ] Each plan has objective, ACs, tasks, boundaries — in readable markdown
- [ ] Plans written to correct phase directories
- [ ] Plan(s) presented to user and APPROVE received
- [ ] Local Story/Task .md hierarchy created for ALL phases after APPROVE
- [ ] STATE.md updated
- [ ] User informed of next action: /pm:apply
</success_criteria>
