---
name: jade:unify
description: Close loop — post summary to Jira, open PR, create deferred tickets
argument-hint: "[plan-path]"
allowed-tools: [Read, Write, Bash, Glob, AskUserQuestion]
---

<objective>
Reconcile plan versus actual results, create SUMMARY.md, post to Jira, and open a Pull Request.

**When to use:** After APPLY phase complete. This is MANDATORY — never skip UNIFY.

Creates SUMMARY.md, posts structured summary to Jira, transitions ticket to In Review, creates PR via GitHub MCP, and creates child tickets for deferred issues.
</objective>

<context>
Plan path: $ARGUMENTS

@.jade/STATE.md
@{plan-path} (the PLAN.md being unified)
</context>

<process>

<step name="validate_preconditions" priority="first">
1. Confirm PLAN.md exists at $ARGUMENTS path (or find from STATE.md)
2. Confirm APPLY phase was executed (tasks completed, TDD Results in STATE.md)
3. If SUMMARY.md already exists: "Loop already closed. SUMMARY: {path}"
4. Read `jira:` from PLAN.md frontmatter
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
- Include commit SHAs
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- JIRA SUMMARY POST                                -->
<!-- ════════════════════════════════════════════════ -->

<step name="jira_summary">
Post SUMMARY.md content as a structured comment to the Jira ticket via Atlassian MCP:

```
## JADE Implementation Summary — [jira_key]

**Objective:** [from plan objective]
**Delivered:** [from unify reconciliation]
**TDD Results:** [from STATE.md TDD Results section]
**Decisions made:** [from unify decisions log]
**Deferred issues:** [list]
**Commits:** [list of commit SHAs with messages]
**PR:** [PR URL if raised]
```
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- JIRA TRANSITION                                  -->
<!-- ════════════════════════════════════════════════ -->

<step name="jira_transition">
Transition Jira ticket: `In Progress` → `In Review` via Atlassian MCP.
Update STATE.md: `status: In Review`
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- GITHUB PR CREATION                               -->
<!-- ════════════════════════════════════════════════ -->

<step name="create_pr">
After pushing the final commit, create a Pull Request via GitHub MCP:

**Title:** `[jira_key] [plan objective — first sentence]`

**Body:**
```markdown
## Summary
[from SUMMARY.md — delivered section]

## Jira ticket
[JIRA_BASE_URL]/browse/[jira_key]

## TDD Results
[from STATE.md TDD Results section — formatted as table]

## Changes
[list of files changed across all tasks]

## Acceptance Criteria
[from PLAN.md acceptance_criteria section]
```

**Base branch:** `main` (or configured default branch from GITHUB_DEFAULT_BRANCH)
**Head branch:** `jade/[jira_key]`

Print the PR URL to the user.
Update STATE.md: `pr: [PR URL]`
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- DEFERRED ISSUES → NEW TICKETS                    -->
<!-- ════════════════════════════════════════════════ -->

<step name="deferred_tickets">
For each deferred issue captured during reconciliation:

Create a new Jira ticket via Atlassian MCP:
- Summary: `[Deferred from [jira_key]] [issue description]`
- Type: Task
- Label: `deferred`
- Link: `relates to [jira_key]`
- Project: [JIRA_PROJECT_KEY from env]

Report all created ticket keys to the user.
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
- `pr: [PR URL]`
- `last_synced: [ISO timestamp]`
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

Jira: [jira_key] → In Review
PR: [PR URL]
Deferred: [N] new tickets created

────────────────────────────────────────
▶ NEXT: /jade:verify
  Run UAT verification. On pass, ticket transitions to Done.
────────────────────────────────────────
```
</step>

</process>

<success_criteria>
- [ ] SUMMARY.md created with reconciliation
- [ ] Structured summary posted to Jira ticket as comment
- [ ] Jira ticket transitioned to In Review
- [ ] Pull Request created via GitHub MCP
- [ ] PR URL written to STATE.md
- [ ] Deferred issues created as child Jira tickets
- [ ] STATE.md updated with loop closure
- [ ] User knows next action: /jade:verify
</success_criteria>
