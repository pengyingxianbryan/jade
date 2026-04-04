# TASK.md Template

Template for `.pm/phases/{phase-number}-{name}/tasks/TASK-{NN}.md` — individual task tracking.

**Purpose:** Provides a Jira Subtask-style document for each task with status, acceptance criteria, implementation details, and completion record. Created by `/pm:plan` after APPROVE. Updated by `/pm:apply` as each task completes.

---

## File Template

```markdown
# Task [N]: [Task Name]

| Field | Value |
|-------|-------|
| Status | To Do |
| Discipline | frontend / backend / fullstack / devops |
| Priority | Highest / High / Medium / Low |
| Parent | [Phase name — links to STORY.md] |
| Created | [YYYY-MM-DD] |
| Last Updated | [YYYY-MM-DD] |

## Summary

[One-line description of what this task accomplishes]

## Details

[Detailed implementation instructions — specific enough for a developer to execute]

- What to do
- How to approach it
- What to avoid and why

## Acceptance Criteria

- [ ] [Condition 1 — what done looks like]
- [ ] [Condition 2 — validation step]
- [ ] [Condition 3 — links to parent Story AC-N]

## Files

- `path/to/file1.ts`
- `path/to/file2.ts`

## Verification

```bash
[command to prove it worked]
```

## Dependencies

- Depends on: [Task X / nothing]

## Notes

[Any additional context, edge cases, or implementation considerations]

---

## Completion Record

<!-- Updated automatically by pm:apply after TDD passes and PR is merged -->

| Field | Value |
|-------|-------|
| Completed At | — |
| Commit SHA | — |
| Tests Added | — |
| Tests Passing | — |
| PR URL | — |
| Branch | — |

### TDD Results

| Phase | Result |
|-------|--------|
| RED | — |
| GREEN | — |
| REFACTOR | — |

---
*Created: [YYYY-MM-DD] | Last updated: [YYYY-MM-DD]*
```

---

## Status Values

| Status | Meaning |
|--------|---------|
| `To Do` | Task planned but not started |
| `In Progress` | TDD loop is executing for this task |
| `Done` | TDD passed, PR merged, completion record filled |
| `Cancelled` | Task removed during plan revision |

## Update Rules

- **Status** changes to `In Progress` when pm:apply starts this task
- **Status** changes to `Done` after PR is merged and completion record is filled
- **Acceptance criteria** checkboxes checked when task is verified
- **Completion Record** populated by pm:apply with commit SHA, test counts, PR URL, TDD results
- **Last Updated** timestamp refreshed on every change

## Discipline Values

| Discipline | Meaning |
|------------|---------|
| `frontend` | UI components, pages, layouts, animations |
| `backend` | APIs, services, database, business logic |
| `fullstack` | Touches both frontend and backend |
| `devops` | CI/CD, infrastructure, deployment, configuration |
