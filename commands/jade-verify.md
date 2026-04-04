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
1. Source credentials and transition Jira ticket `In Review` → `Done` via REST API:
   ```bash
   source .jade/.env
   AUTH="Authorization: Basic $(echo -n "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" | base64)"
   TRANSITIONS=$(curl -s -H "$AUTH" "$JIRA_BASE_URL/rest/api/3/issue/$JIRA_KEY/transitions")
   TRANSITION_ID=$(echo "$TRANSITIONS" | jq -r '.transitions[] | select(.name | test("done";"i")) | .id')
   curl -s -X POST -H "$AUTH" -H "Content-Type: application/json" \
     "$JIRA_BASE_URL/rest/api/3/issue/$JIRA_KEY/transitions" \
     -d '{"transition":{"id":"'"$TRANSITION_ID"'"}}'
   ```
2. Update STATE.md: `status: Done`, `last_synced: [ISO timestamp]`
3. Post comment to Jira via REST API: "✅ UAT passed. Ticket closed."
4. Print:
   ```
   ✅ UAT passed.
   ✅ Jira [jira_key] → Done
   ✅ PR ready to merge: [PR URL]
   ```

**If FAIL:**
1. Ask: "Describe the issues found."
2. Capture issues to `.jade/phases/XX-name/{plan}-UAT.md`
3. For each issue, create a **Bug** ticket in Jira (not Task) via REST API:
   ```bash
   source .jade/.env
   AUTH="Authorization: Basic $(echo -n "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" | base64)"
   curl -s -X POST \
     -H "$AUTH" -H "Content-Type: application/json" \
     "$JIRA_BASE_URL/rest/api/3/issue" \
     -d '{
       "fields": {
         "project": {"key": "'"$JIRA_PROJECT_KEY"'"},
         "summary": "[Bug] [AC or issue description]",
         "issuetype": {"name": "Bug"},
         "priority": {"name": "[Blocker=Highest, Major=High, Minor=Medium, Cosmetic=Low]"},
         "labels": ["jade-managed", "uat-failure"],
         "components": [{"name": "[discipline if determinable from the failing area]"}],
         "description": {
           "version": 3,
           "type": "doc",
           "content": [
             {"type": "heading", "attrs": {"level": 3}, "content": [{"type": "text", "text": "Steps to Reproduce"}]},
             {"type": "paragraph", "content": [{"type": "text", "text": "[from user FAIL description — what they did to trigger the issue]"}]},
             {"type": "heading", "attrs": {"level": 3}, "content": [{"type": "text", "text": "Expected Result"}]},
             {"type": "paragraph", "content": [{"type": "text", "text": "[from the relevant AC Given/When/Then — what should have happened]"}]},
             {"type": "heading", "attrs": {"level": 3}, "content": [{"type": "text", "text": "Actual Result"}]},
             {"type": "paragraph", "content": [{"type": "text", "text": "[from user description — what actually happened]"}]},
             {"type": "heading", "attrs": {"level": 3}, "content": [{"type": "text", "text": "Affected AC"}]},
             {"type": "paragraph", "content": [{"type": "text", "text": "[AC-N reference from PLAN.md that this bug violates]"}]},
             {"type": "heading", "attrs": {"level": 3}, "content": [{"type": "text", "text": "Origin"}]},
             {"type": "paragraph", "content": [{"type": "text", "text": "Story: [jira_key] | PR: [PR URL] | Phase: [N]"}]}
           ]
         }
       }
     }'
   ```
4. Link each Bug back to the parent Story:
   ```bash
   curl -s -X POST \
     -H "$AUTH" -H "Content-Type: application/json" \
     "$JIRA_BASE_URL/rest/api/3/issueLink" \
     -d '{
       "type": {"name": "Relates"},
       "inwardIssue": {"key": "[BUG_KEY]"},
       "outwardIssue": {"key": "[STORY_KEY]"}
     }'
   ```
5. Post comment to Jira via REST API: "❌ UAT failed. [N] Bug ticket(s) created: [BUG-KEY1, BUG-KEY2, ...]"
6. Print:
   ```
   ❌ UAT issues captured.
   Issues logged: .jade/phases/XX-name/{plan}-UAT.md

   Bug tickets created:
     [BUG-KEY1]: [description] (Highest)
     [BUG-KEY2]: [description] (High)

   ▶ NEXT: /jade:plan --fix [plan-number]
     Create a fix plan for the bugs found.
   ```
</step>

</process>

<success_criteria>
- [ ] Summary of deliverables presented
- [ ] PR URL shown
- [ ] User verdict collected (PASS or FAIL)
- [ ] On PASS: Jira ticket transitioned to Done (via curl)
- [ ] On FAIL: Issues captured, Bug tickets created in Jira with priority + steps to reproduce, linked to parent Story
- [ ] Clear next action provided
</success_criteria>
