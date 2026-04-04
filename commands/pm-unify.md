---
name: pm:unify
description: Close loop — write summary, reconcile, triage deferred issues
argument-hint: "[plan-path]"
allowed-tools: [Read, Write, Bash, Glob, AskUserQuestion]
---

<objective>
Reconcile plan versus actual results, create SUMMARY.md, and triage deferred issues.

**When to use:** After APPLY phase complete. This is MANDATORY — never skip UNIFY.

Creates SUMMARY.md, updates STORY.md to In Review, and creates issue files for deferred items.
</objective>

<context>
Plan path: $ARGUMENTS

@.pm/STATE.md
@{plan-path} (the PLAN.md being unified)
</context>

<process>

<step name="validate_preconditions" priority="first">
1. Confirm PLAN.md exists at $ARGUMENTS path (or find from STATE.md)
2. Confirm APPLY phase was executed (tasks completed, TDD Results in STATE.md)
3. If SUMMARY.md already exists: "Loop already closed. SUMMARY: {path}"
4. Read STORY.md for the phase
</step>

<step name="reconcile">
Compare plan to actual:
- Which tasks completed as planned?
- Any deviations from plan?
- Decisions made during execution?
- Issues discovered but deferred?
- Files created/modified vs planned
</step>

<step name="create_summary">
Create SUMMARY.md in same directory as PLAN.md:
- Document what was built
- Record acceptance criteria results (pass/fail per AC)
- Note any deferred issues
- Capture decisions made
- List files created/modified
- Include TDD results from STATE.md
- Include commit SHAs and PR URLs from TASK-NN.md files
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- UPDATE LOCAL STATUS                              -->
<!-- ════════════════════════════════════════════════ -->

<step name="update_story_status">
Update the phase's STORY.md:
- Set `Status` to `In Review`
- Update acceptance criteria checkboxes based on results

Update STATE.md: `status: In Review`
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- DEFERRED ISSUES → LOCAL FILES                    -->
<!-- ════════════════════════════════════════════════ -->

<step name="triage_deferred_issues">
**Triage all deferred issues:**

1. Collect deferred issues from:
   - Issues discovered during reconciliation (this session)
   - `.pm/ISSUES.md` (if exists — accumulated from prior phases)
   - Phase-scoped UAT files
2. For each issue, analyze against current codebase:
   - Has it been resolved by subsequent work?
   - Is it urgent enough to address now?
   - Can it wait for a future phase?
3. Present categorized report to user:
   - **Resolved** — already fixed by other work (mark as closed)
   - **Promote** — needs attention soon
   - **Defer** — keep for future consideration
4. For promoted issues, create issue entries in `.pm/ISSUES.md`:
   ```markdown
   ### ISSUE-{NNN}: [title]

   | Field | Value |
   |-------|-------|
   | Status | Open |
   | Priority | High / Medium / Low |
   | Origin | Phase [N] |
   | Discipline | frontend / backend / fullstack / devops |

   **Description:** [Detailed description]
   **Acceptance Criteria:** [What done looks like]
   **Affected Files:** [Files related to this issue]
   ```
5. Report all created issues to the user
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- STATE UPDATE                                     -->
<!-- ════════════════════════════════════════════════ -->

<step name="update_state">
Update STATE.md:
- Loop position: PLAN ✓ → APPLY ✓ → UNIFY ✓
- Phase progress if plan completes phase
- Performance metrics (duration)
- Session continuity (next action)
- `status: In Review`
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- REPORT                                           -->
<!-- ════════════════════════════════════════════════ -->

<step name="report">
```
════════════════════════════════════════
Loop Closed
════════════════════════════════════════

Plan: {plan-path}
Summary: {summary-path}

PLAN ──▶ APPLY ──▶ UNIFY
  ✓        ✓        ✓

Story: [phase name] → In Review
Deferred: [N] issues logged

PRs merged during apply:
  - Task 1: [PR URL]
  - Task 2: [PR URL]

────────────────────────────────────────
▶ NEXT: /pm:verify
  Run UAT verification. On pass, story transitions to Done.
────────────────────────────────────────
```
</step>

</process>

<success_criteria>
- [ ] SUMMARY.md created with reconciliation
- [ ] STORY.md updated to In Review
- [ ] Deferred issues triaged and logged to ISSUES.md
- [ ] STATE.md updated with loop closure
- [ ] User knows next action: /pm:verify
</success_criteria>
