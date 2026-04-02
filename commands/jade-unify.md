---
name: jade:unify
description: Close loop — post summary to Jira, open PR, create deferred tickets
argument-hint: "[plan-path]"
allowed-tools: [Read, Write, Bash, Glob, AskUserQuestion]
---

<objective>
Reconcile plan versus actual results, create SUMMARY.md, post to Jira, and open a Pull Request.

**When to use:** After APPLY phase complete. This is MANDATORY — never skip UNIFY.

Creates SUMMARY.md, posts structured summary to Jira, transitions ticket to In Review, creates PR via `gh` CLI, and creates child tickets for deferred issues.
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
Post SUMMARY.md content as a structured comment to the Jira ticket via REST API:

```bash
source .jade/.env
AUTH="Authorization: Basic $(echo -n "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" | base64)"
curl -s -X POST \
  -H "$AUTH" -H "Content-Type: application/json" \
  "$JIRA_BASE_URL/rest/api/3/issue/$JIRA_KEY/comment" \
  -d '{"body":{"version":3,"type":"doc","content":[{"type":"paragraph","content":[{"type":"text","text":"## JADE Implementation Summary — [jira_key]\n\nObjective: [from plan]\nDelivered: [from reconciliation]\nTDD Results: [from STATE.md]\nDecisions: [from log]\nDeferred: [list]\nCommits: [SHAs]\nPR: [PR URL]"}]}]}}'
```
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- JIRA TRANSITION                                  -->
<!-- ════════════════════════════════════════════════ -->

<step name="jira_transition">
Transition Jira ticket `In Progress` → `In Review` via REST API:

```bash
source .jade/.env
AUTH="Authorization: Basic $(echo -n "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" | base64)"
# Get available transitions
TRANSITIONS=$(curl -s -H "$AUTH" "$JIRA_BASE_URL/rest/api/3/issue/$JIRA_KEY/transitions")
TRANSITION_ID=$(echo "$TRANSITIONS" | jq -r '.transitions[] | select(.name | test("review";"i")) | .id')
curl -s -X POST -H "$AUTH" -H "Content-Type: application/json" \
  "$JIRA_BASE_URL/rest/api/3/issue/$JIRA_KEY/transitions" \
  -d '{"transition":{"id":"'"$TRANSITION_ID"'"}}'
```

Update STATE.md: `status: In Review`
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- GITHUB PR CREATION                               -->
<!-- ════════════════════════════════════════════════ -->

<step name="create_pr">
After pushing the final commit, create a Pull Request via `gh` CLI:

```bash
gh pr create \
  --title "[jira_key] [plan objective — first sentence]" \
  --body "$(cat <<'EOF'
## Summary
[from SUMMARY.md — delivered section]

## Jira ticket
$JIRA_BASE_URL/browse/[jira_key]

## TDD Results
[from STATE.md TDD Results section — formatted as table]

## Changes
[list of files changed across all tasks]

## Acceptance Criteria
[from PLAN.md acceptance_criteria section]
EOF
)" \
  --base main \
  --head jade/[jira_key]
```

Print the PR URL to the user.
Update STATE.md: `pr: [PR URL]`
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- DEFERRED ISSUES → NEW TICKETS                    -->
<!-- ════════════════════════════════════════════════ -->

<step name="triage_deferred_issues">
**Triage all deferred issues** (absorbs the old `/jade:consider-issues` command):

1. Collect deferred issues from:
   - Issues discovered during reconciliation (this session)
   - `.jade/ISSUES.md` (if exists — accumulated from prior phases)
   - Phase-scoped UAT files
2. For each issue, analyze against current codebase:
   - Has it been resolved by subsequent work?
   - Is it urgent enough to address now?
   - Can it wait for a future phase?
3. Present categorized report to user:
   - **Resolved** — already fixed by other work (mark as closed)
   - **Promote** — create Jira ticket now
   - **Defer** — keep for future consideration
4. For promoted issues, create Jira tickets via REST API:
   ```bash
   source .jade/.env
   AUTH="Authorization: Basic $(echo -n "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" | base64)"
   curl -s -X POST \
     -H "$AUTH" -H "Content-Type: application/json" \
     "$JIRA_BASE_URL/rest/api/3/issue" \
     -d '{"fields":{"project":{"key":"'"$JIRA_PROJECT_KEY"'"},"summary":"[Deferred from [jira_key]] [issue description]","issuetype":{"name":"Task"},"labels":["deferred"]}}'
   ```
5. Update ISSUES.md with triage results
6. Report all created ticket keys to the user
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
- [ ] Structured summary posted to Jira ticket as comment (via curl)
- [ ] Jira ticket transitioned to In Review (via curl)
- [ ] Pull Request created via `gh pr create`
- [ ] PR URL written to STATE.md
- [ ] Deferred issues created as Jira tickets (via curl)
- [ ] STATE.md updated with loop closure
- [ ] User knows next action: /jade:verify
</success_criteria>
