---
name: jade:handoff
description: Generate comprehensive session handoff with Jira/GitHub/TDD context
argument-hint: "[context notes]"
allowed-tools: [Read, Write]
---

<objective>
Generate a comprehensive handoff document including Jira ticket context, GitHub branch state, and TDD progress.

**When to use:** End of session, context break, or when decisions need documentation.
</objective>

<context>
Optional notes: $ARGUMENTS

@.jade/STATE.md
</context>

<process>

<step name="gather_context">
From STATE.md:
- Current phase, plan, loop position
- Jira: ticket key, status, last synced
- GitHub: branch, last push, PR URL
- TDD Results: per-task progress

From conversation context:
- Files created/modified this session
- Decisions made
- Questions raised
- Gaps identified
</step>

<step name="generate_handoff">
Create `.jade/HANDOFF-{date}-{context}.md`:

```markdown
# JADE Session Handoff

**Session:** {date}
**Phase:** {current_phase}
**Jira:** {ticket_key} — {status}
**Branch:** jade/{ticket_key}
**TDD:** {N}/{M} tasks complete

---

## Session Accomplishments
{what was done}

## Jira Context
- Ticket: {key} — {status}
- Comments posted: {N}
- Last sync: {timestamp}

## GitHub Context
- Branch: jade/{key}
- Commits this session: {N}
- Last push: {timestamp}
- PR: {URL or "not yet"}

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
| 1 | {action} |

---
*Handoff created: {timestamp}*
*Resume: /jade:resume*
```
</step>

</process>

<success_criteria>
- [ ] Handoff includes Jira ticket context
- [ ] Handoff includes GitHub branch state
- [ ] Handoff includes TDD progress
- [ ] Next actions prioritized
</success_criteria>
