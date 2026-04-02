---
name: jade:pause
description: Create comprehensive handoff, post paused status to Jira, prepare for session break
argument-hint: "[reason]"
allowed-tools: [Read, Write, Bash, AskUserQuestion]
---

<objective>
Create a comprehensive handoff document capturing all context, post a pause comment to Jira, and update STATE.md for session continuity.

**When to use:** Before ending a session, switching context, or when context limit is approaching.

This command combines the old `/jade:pause` and `/jade:handoff` into one — every pause produces a full handoff.
</objective>

<context>
$ARGUMENTS

@.jade/STATE.md
@.jade/PROJECT.md
</context>

<process>

<step name="detect_position">
Read STATE.md for:
- Current phase, plan, loop position
- Jira ticket key and status
- GitHub branch and last push
- TDD progress
</step>

<step name="create_handoff">
Create `.jade/HANDOFF-{date}.md` with comprehensive context:

```markdown
# JADE Session Handoff

**Session:** {date}
**Phase:** {current_phase}
**Jira:** {ticket_key} — {status}
**Branch:** jade/{ticket_key}
**TDD:** {N}/{M} tasks complete

---

## Session Accomplishments
{what was done this session}

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
| 1 | {most important next step} |

---
*Handoff created: {timestamp}*
*Resume: /jade:resume*
```
</step>

<step name="jira_comment">
If Jira ticket exists in STATE.md, post comment via REST API:

```bash
source .jade/.env
AUTH="Authorization: Basic $(echo -n "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" | base64)"
curl -s -X POST \
  -H "$AUTH" -H "Content-Type: application/json" \
  "$JIRA_BASE_URL/rest/api/3/issue/$JIRA_KEY/comment" \
  -d '{"body":{"version":3,"type":"doc","content":[{"type":"paragraph","content":[{"type":"text","text":"⏸️ Session paused: [reason or session break]\nProgress: [N]/[M] tasks complete\nBranch: jade/[jira_key]\nLast push: [timestamp]\nResume with: /jade:resume"}]}]}}'
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

Handoff: .jade/HANDOFF-{date}.md
Jira: [key] — pause comment posted
Branch: jade/[key] — all work pushed

Resume: /jade:resume
════════════════════════════════════════
```
</step>

</process>

<success_criteria>
- [ ] Comprehensive HANDOFF.md created with Jira/GitHub/TDD context
- [ ] Decisions and open questions captured
- [ ] Prioritized next actions listed
- [ ] Jira comment posted (if ticket exists)
- [ ] STATE.md updated with session continuity
- [ ] Resume instructions provided
</success_criteria>
