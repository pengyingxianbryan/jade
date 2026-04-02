---
name: jade:consider-issues
description: Review deferred issues, triage, and optionally create Jira tickets
allowed-tools: [Read, Bash, Grep, Glob, Edit, AskUserQuestion]
---

<objective>
Review all open issues from ISSUES.md and UAT files with current codebase context. Identify resolved, urgent, and waiting issues. For promoted issues, create Jira tickets.

**When to use:** Periodically or before milestone completion.
</objective>

<context>
@.jade/ISSUES.md (if exists)
@.jade/STATE.md
@.jade/ROADMAP.md
</context>

<process>

<step name="find_issues">
1. Find all issue files (ISSUES.md, phase-scoped UAT files)
2. Parse open issues
3. Read Jira ticket key from STATE.md for linking
</step>

<step name="analyze">
For each issue, analyze against current codebase:
- Has it been resolved by subsequent work?
- Is it urgent enough to fix now?
- Is it a natural fit for the current phase?
- Can it wait?
</step>

<step name="present_and_act">
Present categorized report to user.

For issues the user wants to promote:
1. Create Jira ticket via REST API:
   ```bash
   source .jade/.env
   AUTH="Authorization: Basic $(echo -n "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" | base64)"
   curl -s -X POST \
     -H "$AUTH" -H "Content-Type: application/json" \
     "$JIRA_BASE_URL/rest/api/3/issue" \
     -d '{"fields":{"project":{"key":"'"$JIRA_PROJECT_KEY"'"},"summary":"[From deferred] [issue description]","issuetype":{"name":"Task"},"labels":["deferred"]}}'
   ```
2. Report created ticket key
3. Update ISSUES.md to mark as promoted
</step>

</process>

<success_criteria>
- [ ] All open issues analyzed
- [ ] Each issue categorized
- [ ] Promoted issues created as Jira tickets
- [ ] Files updated
</success_criteria>
