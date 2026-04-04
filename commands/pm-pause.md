---
name: pm:pause
description: Create comprehensive handoff, prepare for session break
argument-hint: "[reason]"
allowed-tools: [Read, Write, Bash, AskUserQuestion]
---

<objective>
Create a comprehensive handoff document capturing all context and update STATE.md for session continuity.

**When to use:** Before ending a session, switching context, or when context limit is approaching.

This command combines the old `/pm:pause` and `/pm:handoff` into one — every pause produces a full handoff.
</objective>

<context>
$ARGUMENTS

@.pm/STATE.md
@.pm/PROJECT.md
</context>

<process>

<step name="detect_position">
Read STATE.md for:
- Current phase, plan, loop position
- GitHub branch and last push
- TDD progress

Read STORY.md and TASK-NN.md files for current phase:
- Task statuses
- PR URLs
</step>

<step name="create_handoff">
Create `.pm/HANDOFF-{date}.md` with comprehensive context:

```markdown
# PM Session Handoff

**Session:** {date}
**Phase:** {current_phase}
**Branch:** {current git branch}
**TDD:** {N}/{M} tasks complete

---

## Session Accomplishments
{what was done this session}

## Story Status
- Phase: [name] — [status]
- Tasks: [N]/[M] complete

## Task Progress
| # | Task | Status | PR |
|---|------|--------|-----|
| 1 | [name] | Done | [URL] |
| 2 | [name] | In Progress | — |
| 3 | [name] | To Do | — |

## GitHub Context
- Current branch: {branch name}
- Commits this session: {N}
- Last push: {timestamp}
- Open PRs: {list}

## TDD Progress
{per-task RED/GREEN/REFACTOR status}

## Decisions Made
| Decision | Rationale | Impact |
|----------|-----------|--------|

## Open Questions
{unresolved items}

## Prioritized Next Actions
| Priority | Action |
|----------|--------|
| 1 | {most important next step} |

---
*Handoff created: {timestamp}*
*Resume: /pm:resume*
```
</step>

<step name="update_state">
Update STATE.md session continuity section:
- Last session timestamp
- What was completed
- Next action
- Resume context
</step>

<step name="confirm">
```
════════════════════════════════════════
SESSION PAUSED
════════════════════════════════════════

Handoff: .pm/HANDOFF-{date}.md
Branch: {branch} — all work pushed

Resume: /pm:resume
════════════════════════════════════════
```
</step>

</process>

<success_criteria>
- [ ] Comprehensive HANDOFF.md created with GitHub/TDD/task context
- [ ] Decisions and open questions captured
- [ ] Prioritized next actions listed
- [ ] STATE.md updated with session continuity
- [ ] Resume instructions provided
</success_criteria>
