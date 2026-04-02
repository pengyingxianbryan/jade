---
name: jade:resume
description: Restore context from STATE.md and handoffs, including Jira/GitHub state
argument-hint: "[optional: handoff path]"
allowed-tools: [Read, Glob, Bash]
---

<objective>
Restore JADE context after a session break, including Jira ticket state and GitHub branch status. Suggest exactly ONE next action.

**When to use:** Starting a new session on an existing JADE project.
</objective>

<context>
$ARGUMENTS (optional handoff path)

@.jade/STATE.md
</context>

<process>

<step name="verify_jade">
1. Verify .jade/ exists. If not: "No JADE project found. Run /jade:init first."
2. Read STATE.md for full context
</step>

<step name="detect_handoffs">
1. If $ARGUMENTS provided, use that handoff path
2. Otherwise, find most recent HANDOFF file in .jade/
3. Load handoff content if detected
</step>

<step name="restore_context">
From STATE.md, restore:
- Current phase and plan
- Loop position (PLAN/APPLY/UNIFY)
- Jira section: ticket key, status, last synced
- GitHub section: branch, remote verified, last push, PR
- TDD Results: which tasks completed, which pending
- Session continuity: what was last done, what's next
</step>

<step name="verify_external_state">
Quick checks:
1. `git branch --show-current` — confirm we're on expected branch
2. `git status` — check for uncommitted changes
3. If Jira ticket exists: note last synced time (may be stale)
</step>

<step name="display_and_route">
Present resume status with single routing:

```
════════════════════════════════════════
JADE RESUMED
════════════════════════════════════════

Project: [name]
Last session: [timestamp]

Jira: [key] — [status] (synced [time ago])
Branch: jade/[key] ([clean/dirty])
TDD: [N]/[M] tasks complete

Loop:
  PLAN ──▶ APPLY ──▶ UNIFY
    ✓        ◉        ○

[If handoff detected:]
Handoff: [path]
Context: [key info from handoff]

────────────────────────────────────────
▶ NEXT: [single action based on loop position]
────────────────────────────────────────
```

After work proceeds: archive/delete consumed handoff.
</step>

</process>

<success_criteria>
- [ ] Context restored from STATE.md and/or handoff
- [ ] Jira ticket status shown
- [ ] GitHub branch status verified
- [ ] TDD progress shown
- [ ] Loop position correctly identified
- [ ] Exactly ONE next action suggested
</success_criteria>
