# PLAN.md Template

Template for `.jade/phases/{phase-number}-{name}/{phase}-{plan}-PLAN.md` - executable phase plans.

**Naming:** `{phase}-{plan}-PLAN.md` (e.g., `01-02-PLAN.md` for Phase 1, Plan 2)

---

## File Template

```markdown
---
phase: XX-name
plan: NN
type: execute                    # execute | tdd | research
jira:                            # Jira ticket key — auto-filled after APPROVE
wave: N                          # Execution wave (1, 2, 3...). Pre-computed at plan time.
depends_on: []                   # Plan IDs this plan requires (e.g., ["01-01"]).
files_modified: []               # Files this plan modifies.
autonomous: true                 # false if plan has checkpoints requiring user interaction
---

<objective>
## Goal
[What this plan accomplishes - specific, measurable]

## Purpose
[Why this matters for the project - connects to PROJECT.md value]

## Output
[What artifacts will be created/modified]
</objective>

<context>
## Project Context
@.jade/PROJECT.md
@.jade/ROADMAP.md
@.jade/STATE.md

## Prior Work (only if genuinely needed)
# Only reference prior SUMMARYs if:
# - This plan imports types/exports from prior plan
# - Prior plan made decision affecting this plan
# - Prior plan's output is direct input to this plan

## Source Files
@path/to/relevant/source.ts
</context>

<skills>
## Required Skills (from SPECIAL-FLOWS.md)

| Skill | Priority | When to Invoke | Loaded? |
|-------|----------|----------------|---------|
| /skill-name | required | Before [work type] | ○ |

**BLOCKING:** Required skills MUST be loaded before APPLY proceeds.
</skills>

<acceptance_criteria>

<!-- JADE: These ACs will be written to the Jira ticket description.
     Use Given/When/Then format: Given [precondition] / When [action] / Then [outcome]
     Minimum 3 ACs per plan: happy path + edge case + error/failure case -->

## AC-1: [Criterion Name]
```gherkin
Given [precondition / system state]
When [user action / trigger]
Then [expected outcome / observable result]
```

## AC-2: [Criterion Name]
```gherkin
Given [precondition]
When [action]
Then [outcome]
```

## AC-3: [Criterion Name]
```gherkin
Given [precondition]
When [action]
Then [outcome]
```

</acceptance_criteria>

<tasks>

<task type="auto">
  <name>Task 1: [Action-oriented name]</name>
  <discipline>frontend | backend | fullstack | devops</discipline>
  <status>pending</status>
  <!-- status: pending | done — updated by /jade:apply after TDD passes -->
  <!-- completed_at, commit, tests_added, tests_passing — injected by /jade:apply on completion -->
  <files>path/to/file.ext, another/file.ext</files>
  <action>
    [Specific implementation instructions]
    - What to do
    - How to do it
    - What to avoid and WHY
  </action>
  <verify>[Command or check to prove it worked]</verify>
  <done>[Measurable acceptance criteria - links to AC-N]</done>
</task>

<task type="auto">
  <name>Task 2: [Action-oriented name]</name>
  <discipline>frontend | backend | fullstack | devops</discipline>
  <files>path/to/file.ext</files>
  <action>[Specific implementation]</action>
  <verify>[Command or check]</verify>
  <done>[Acceptance criteria]</done>
</task>

<task type="checkpoint:decision" gate="blocking">
  <decision>[What needs deciding]</decision>
  <context>[Why this decision matters now]</context>
  <options>
    <option id="option-a">
      <name>[Option name]</name>
      <pros>[Benefits and advantages]</pros>
      <cons>[Tradeoffs and limitations]</cons>
    </option>
    <option id="option-b">
      <name>[Option name]</name>
      <pros>[Benefits and advantages]</pros>
      <cons>[Tradeoffs and limitations]</cons>
    </option>
  </options>
  <resume-signal>Select: option-a or option-b</resume-signal>
</task>

</tasks>

<boundaries>

## DO NOT CHANGE
- [Protected file or pattern]
- [Another protected element]

## SCOPE LIMITS
- [What's explicitly out of scope for this plan]

</boundaries>

<verification>
Before declaring plan complete:
- [ ] [Specific test command]
- [ ] [Build/type check passes]
- [ ] [Behavior verification]
- [ ] All acceptance criteria met
</verification>

<success_criteria>
- All tasks completed
- All verification checks pass
- No errors or warnings introduced
</success_criteria>

<output>
After completion, create `.jade/phases/XX-name/{phase}-{plan}-SUMMARY.md`
</output>
```

---

## Frontmatter Fields

| Field | Required | Purpose |
|-------|----------|---------|
| `phase` | Yes | Phase identifier (e.g., `01-foundation`) |
| `plan` | Yes | Plan number within phase (e.g., `01`, `02`) |
| `type` | Yes | `execute` for standard, `tdd` for test-driven, `research` for exploration |
| `jira` | Yes | Jira ticket key (e.g., `PROJ-123`). Auto-filled after APPROVE. |
| `wave` | Yes | Execution wave number (1, 2, 3...). Pre-computed at plan time. |
| `depends_on` | Yes | Array of plan IDs this plan requires. Empty = parallel candidate. |
| `files_modified` | Yes | Files this plan touches. For conflict detection. |
| `autonomous` | Yes | `true` if no checkpoints, `false` if has checkpoints |

---

## Task Types

| Type | Use For | Behavior |
|------|---------|----------|
| `auto` | Everything AI can do independently | Fully autonomous execution |
| `checkpoint:decision` | Implementation choices requiring human input | Pauses, presents options, waits |
| `checkpoint:human-verify` | Visual/functional verification | Pauses, presents steps, waits |
| `checkpoint:human-action` | Truly unavoidable manual steps (rare) | Pauses, describes action, waits |

---

## Task Structure Requirements

Every `auto` task MUST have:
- `<name>` - Action-oriented, describes outcome
- `<discipline>` - `frontend` | `backend` | `fullstack` | `devops` — determines Jira label and assignee context
- `<files>` - Which files created/modified
- `<action>` - Specific implementation (what to do, what to avoid)
- `<verify>` - How to prove it worked (command, check)
- `<done>` - Acceptance criteria (links to AC-N)

**If you can't specify Files + Action + Verify + Done, the task is too vague.**

---

## Scope Guidance

- 2-3 tasks per plan maximum
- ~50% context usage target
- Single concern per plan
- Prefer vertical slices over horizontal layers
