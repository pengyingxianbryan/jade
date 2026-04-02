# SUMMARY.md Template

Template for `.jade/phases/{phase-number}-{name}/{phase}-{plan}-SUMMARY.md` — plan completion documentation.

**Purpose:** Document what was built, decisions made, deviations from plan, and readiness for next phase.

---

## File Template

```markdown
---
phase: XX-name
plan: NN
subsystem: [primary category: auth, payments, ui, api, database, infra, testing]
tags: [searchable tech: jwt, stripe, react, postgres, prisma]

requires:
  - phase: [prior phase this depends on]
    provides: [what that phase built that this uses]
provides:
  - [what this plan built/delivered]
affects: [phase names or keywords that will need this context]

tech-stack:
  added: [libraries/tools added]
  patterns: [architectural patterns established]

key-files:
  created: [important files created]
  modified: [important files modified]

key-decisions:
  - "Decision 1: [brief]"

patterns-established:
  - "Pattern 1: [description]"

duration: Xmin
started: YYYY-MM-DDTHH:MM:SSZ
completed: YYYY-MM-DDTHH:MM:SSZ
---

# Phase [X] Plan [Y]: [Name] Summary

**[Substantive one-liner describing outcome - what actually shipped]**

## Performance

| Metric | Value |
|--------|-------|
| Duration | [time] |
| Started | [ISO timestamp] |
| Completed | [ISO timestamp] |
| Tasks | [N] completed |
| Files modified | [N] |

## Acceptance Criteria Results

| Criterion | Status | Notes |
|-----------|--------|-------|
| AC-1: [Name] | Pass / Fail | [Details if needed] |
| AC-2: [Name] | Pass / Fail | [Details] |

## Accomplishments

- [Most important outcome - specific, substantive]
- [Second key accomplishment]

## Task Commits

| Task | Commit | Type | Description |
|------|--------|------|-------------|
| Task 1: [name] | `abc123f` | feat | [What was done] |
| Task 2: [name] | `def456g` | feat | [What was done] |

## Files Created/Modified

| File | Change | Purpose |
|------|--------|---------|
| `path/to/file.ts` | Created | [What it does] |

## Decisions Made

| Decision | Rationale | Impact |
|----------|-----------|--------|
| [What was decided] | [Why] | [Effect on future work] |

## Deviations from Plan

### Summary

| Type | Count | Impact |
|------|-------|--------|
| Auto-fixed | [N] | [Brief assessment] |
| Deferred | [N] | Logged to issues |

### Deferred Items

- [Issue ID]: [Brief description]

Or: "None - plan executed exactly as written"

## Issues Encountered

| Issue | Resolution |
|-------|------------|
| [Problem] | [How solved] |

## Next Phase Readiness

**Ready:**
- [What's ready for next phase]

**Concerns:**
- [Potential issues for future phases]

**Blockers:**
- "None"

---
*Phase: XX-name, Plan: NN*
*Completed: [YYYY-MM-DD]*
```
