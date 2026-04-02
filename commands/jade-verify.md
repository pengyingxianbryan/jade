---
name: jade:verify
description: Simple UAT confirmation gate — transitions Jira ticket to Done on pass
argument-hint: "[optional: phase or plan number]"
allowed-tools: [Read, Bash, Glob, AskUserQuestion]
---

<objective>
Simple confirmation gate for user acceptance testing. Show what was built, link to PR, and ask for PASS or FAIL.

**When to use:** After `/jade:unify` has posted the summary and opened the PR.

On PASS: transitions Jira ticket to Done. On FAIL: captures issues for `/jade:plan-fix`.
</objective>

<context>
Scope: $ARGUMENTS (optional — defaults to most recently unified plan)

@.jade/STATE.md
</context>

<process>

<step name="find_scope">
1. If $ARGUMENTS provided: find matching SUMMARY.md
2. If not: find most recently created SUMMARY.md
3. Read SUMMARY.md for deliverables and AC results
4. Read STATE.md for Jira key and PR URL
</step>

<step name="present_summary">
Present what was built:

```
════════════════════════════════════════
UAT VERIFICATION — [jira_key]
════════════════════════════════════════

What was built:
[from SUMMARY.md — accomplishments section]

Acceptance Criteria:
  AC-1: [name] — [pass/fail from SUMMARY]
  AC-2: [name] — [pass/fail from SUMMARY]
  AC-3: [name] — [pass/fail from SUMMARY]

TDD Results:
[from STATE.md TDD Results section]

PR: [PR URL]
Branch: jade/[jira_key]

────────────────────────────────────────
Review the PR and test the changes.

Type PASS to mark as Done, or FAIL to capture issues.
────────────────────────────────────────
```
</step>

<step name="handle_verdict">
Wait for user response.

**If PASS (or clear equivalent):**
1. Transition Jira ticket: `In Review` → `Done` via Atlassian MCP
2. Update STATE.md: `status: Done`, `last_synced: [ISO timestamp]`
3. Post comment to Jira: "✅ UAT passed. Ticket closed."
4. Print:
   ```
   ✅ UAT passed.
   ✅ Jira [jira_key] → Done
   ✅ PR ready to merge: [PR URL]
   ```

**If FAIL:**
1. Ask: "Describe the issues found."
2. Capture issues to `.jade/phases/XX-name/{plan}-UAT.md`
3. Post comment to Jira: "❌ UAT failed. Issues captured for fix."
4. Print:
   ```
   ❌ UAT issues captured.
   Issues logged: .jade/phases/XX-name/{plan}-UAT.md

   ▶ NEXT: /jade:plan-fix [plan-number]
     Create a fix plan for the issues found.
   ```
</step>

</process>

<success_criteria>
- [ ] Summary of deliverables presented
- [ ] PR URL shown
- [ ] User verdict collected (PASS or FAIL)
- [ ] On PASS: Jira ticket transitioned to Done
- [ ] On FAIL: Issues captured and logged
- [ ] Clear next action provided
</success_criteria>
