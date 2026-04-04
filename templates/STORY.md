# STORY.md Template

Template for `.pm/phases/{phase-number}-{name}/STORY.md` — phase-level story tracking.

**Purpose:** Provides a Jira Story-style overview of the phase with status, acceptance criteria, scope, and task summary. Created by `/pm:plan` after APPROVE.

---

## File Template

```markdown
# [Phase Name]

| Field | Value |
|-------|-------|
| Status | To Do |
| Priority | Highest / High / Medium / Low |
| Wave | [N] |
| Phase | [XX-name] |
| Created | [YYYY-MM-DD] |
| Last Updated | [YYYY-MM-DD] |

## Summary

[One-line summary of what this phase delivers]

## Description

[Detailed description of the phase objective — what it accomplishes and why it matters for the project. Written for a non-technical reader to understand.]

## Acceptance Criteria

- [ ] **AC-1: [Name]** — [Condition: complete when X is achieved]
- [ ] **AC-2: [Name]** — [Validated by Y]
- [ ] **AC-3: [Name]** — [Verified via Z]

## Tasks

| # | Task | Discipline | Status | PR |
|---|------|------------|--------|----|
| 1 | [Task name] | backend | To Do | — |
| 2 | [Task name] | frontend | To Do | — |
| 3 | [Task name] | fullstack | To Do | — |

## Scope

**In scope:**
- [Deliverable 1]
- [Deliverable 2]

**Out of scope:**
- [Excluded item 1]

## Boundaries

**Do not change:**
- [Protected file/pattern]

## Dependencies

- Depends on: [Phase X / nothing]
- Blocks: [Phase Y / nothing]

---
*Created: [YYYY-MM-DD] | Last updated: [YYYY-MM-DD]*
```

---

## Status Values

| Status | Meaning |
|--------|---------|
| `To Do` | Phase planned but not started |
| `In Progress` | `/pm:apply` is executing tasks |
| `In Review` | `/pm:unify` complete, awaiting UAT |
| `Done` | `/pm:verify` passed |

## Priority Mapping (from wave field)

| Wave | Priority |
|------|----------|
| 1 | Highest |
| 2 | High |
| 3 | Medium |
| 4+ | Low |

## Update Rules

- **Status** updates as PM progresses through the workflow
- **Task table** updates per-task (not batched) — each task row shows current status and PR URL
- **Acceptance criteria** checkboxes checked during `/pm:unify` and `/pm:verify`
- **Last Updated** timestamp refreshed on every change
