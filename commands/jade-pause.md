---
name: jade:pause
description: Create handoff file, post paused status to Jira, prepare for session break
argument-hint: "[reason]"
allowed-tools: [Read, Write, Bash, AskUserQuestion]
---

<objective>
Create a HANDOFF.md file capturing current context, post a pause comment to Jira, and update STATE.md for session continuity.

**When to use:** Before ending a session, switching context, or when context limit is approaching.
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
Create `.jade/HANDOFF-{date}.md` with:
- Current loop position
- Jira ticket key and status
- GitHub branch name and last push timestamp
- TDD results so far (which tasks complete)
- What was last completed
- What to do next
- Key context needed to continue
- Reason for pause (from $ARGUMENTS if provided)
</step>

<step name="jira_comment">
If Jira ticket exists in STATE.md, post comment via Atlassian MCP:
```
⏸️ Session paused: [reason or "session break"]
Progress: [N]/[M] tasks complete
Branch: jade/[jira_key]
Last push: [timestamp]
Resume with: /jade:resume
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
- [ ] HANDOFF.md created with complete context including Jira/GitHub state
- [ ] Jira comment posted (if ticket exists)
- [ ] STATE.md updated with session continuity
- [ ] Resume instructions provided
</success_criteria>
