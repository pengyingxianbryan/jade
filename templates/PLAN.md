# PLAN.md Template

Template for `.pm/phases/{phase-number}-{name}/{phase}-{plan}-PLAN.md` — executable phase plans.

**Naming:** `{phase}-{plan}-PLAN.md` (e.g., `01-02-PLAN.md` for Phase 1, Plan 2)

---

## File Template

```markdown
---
phase: XX-name
plan: NN
type: execute                    # execute | tdd | research
wave: N                          # Execution wave (1, 2, 3...). Pre-computed at plan time.
depends_on: []                   # Plan IDs this plan requires (e.g., ["01-01"]).
files_modified: []               # Files this plan modifies.
autonomous: true                 # false if plan has checkpoints requiring user interaction
---

# Phase N: [Phase Name]

## Objective

**Goal:** [What this plan accomplishes — specific, measurable]

**Purpose:** [Why this matters for the project — connects to PROJECT.md value]

**Output:** [What artifacts will be created/modified]

## Acceptance Criteria

- [ ] **AC-1: [Name]** — [Condition: task is complete when X is achieved]
- [ ] **AC-2: [Name]** — [Validated by Y]
- [ ] **AC-3: [Name]** — [Verified via Z]

> Minimum 3 ACs per plan: happy path + edge case + error/failure case.

## Tasks

### Task 1: [Action-oriented name]

| Field | Value |
|-------|-------|
| Discipline | frontend / backend / fullstack / devops |
| Status | pending |
| Files | `path/to/file1.ts`, `path/to/file2.ts` |

**What to do:**
- [Specific implementation instructions]
- [How to approach it]
- [What to avoid and WHY]

**Verification:** `[command to prove it worked]`

**Done when:** [Measurable acceptance criteria — links to AC-N]

---

### Task 2: [Action-oriented name]

| Field | Value |
|-------|-------|
| Discipline | frontend / backend / fullstack / devops |
| Status | pending |
| Files | `path/to/file.ts` |

**What to do:**
- [Specific implementation instructions]

**Verification:** `[command or check]`

**Done when:** [Acceptance criteria]

---

### Checkpoint: [Decision or verification needed]

> **Type:** decision / human-verify / human-action
>
> **Context:** [Why this decision matters now]
>
> **Options:**
> - **Option A:** [Name] — Pros: [benefits] | Cons: [tradeoffs]
> - **Option B:** [Name] — Pros: [benefits] | Cons: [tradeoffs]
>
> **Resume:** Select Option A or Option B to continue.

---

## Boundaries

### Do Not Change
- [Protected file or pattern]
- [Another protected element]

### Scope Limits
- [What's explicitly out of scope for this plan]

## Verification Checklist

- [ ] [Specific test command]
- [ ] [Build/type check passes]
- [ ] [Behavior verification]
- [ ] All acceptance criteria met
```

---

## Frontmatter Fields

| Field | Required | Purpose |
|-------|----------|---------|
| `phase` | Yes | Phase identifier (e.g., `01-foundation`) |
| `plan` | Yes | Plan number within phase (e.g., `01`, `02`) |
| `type` | Yes | `execute` for standard, `tdd` for test-driven, `research` for exploration |
| `wave` | Yes | Execution wave number (1, 2, 3...). Pre-computed at plan time. |
| `depends_on` | Yes | Array of plan IDs this plan requires. Empty = parallel candidate. |
| `files_modified` | Yes | Files this plan touches. For conflict detection. |
| `autonomous` | Yes | `true` if no checkpoints, `false` if has checkpoints |

---

## Task Structure Requirements

Every task MUST have:
- **Name** — Action-oriented, describes outcome
- **Discipline** — `frontend` | `backend` | `fullstack` | `devops`
- **Files** — Which files created/modified
- **What to do** — Specific implementation (what to do, what to avoid)
- **Verification** — How to prove it worked (command, check)
- **Done when** — Acceptance criteria (links to AC-N)

**If you can't specify Files + What to do + Verification + Done when, the task is too vague.**

---

## Scope Guidance

- 2-3 tasks per plan maximum
- ~50% context usage target
- Single concern per plan
- Prefer vertical slices over horizontal layers
