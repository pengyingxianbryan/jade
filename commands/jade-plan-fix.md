---
name: jade:plan-fix
description: Plan fixes for UAT issues with Jira ticket context
argument-hint: "<plan, e.g., '04-02'>"
allowed-tools: [Read, Bash, Write, Glob, Grep, AskUserQuestion]
---

<objective>
Create FIX.md plan from UAT issues found during `/jade:verify`.

**When to use:** After `/jade:verify` logs issues to phase-scoped UAT file.

Pre-populates fix plan with Jira ticket context from the parent plan.
</objective>

<context>
Plan number: $ARGUMENTS (required)

@.jade/STATE.md
@.jade/ROADMAP.md
</context>

<process>

<step name="find_uat">
1. Parse plan argument (e.g., "04-02")
2. Find matching UAT.md file in phase directory
3. If not found: error with usage hint
4. Read Jira ticket key from STATE.md for context
</step>

<step name="read_issues">
Parse each issue from UAT.md:
- ID, title, severity
- Description / steps to reproduce
- AC reference
</step>

<step name="create_fix_plan">
Create `.jade/phases/XX-name/{plan}-FIX.md`:
- Frontmatter with `type: fix` and `jira:` from parent plan
- Objective referencing the parent Jira ticket
- One task per issue (or grouped related minors)
- Boundaries: only fix reported issues, no scope creep
- Prioritize: Blocker → Major → Minor → Cosmetic
</step>

<step name="offer_execution">
Present fix plan summary with issue counts by severity.
Offer: [1] Approved, run APPLY | [2] Review first | [3] Pause
</step>

</process>

<success_criteria>
- [ ] UAT.md found and parsed
- [ ] Fix tasks created per issue
- [ ] FIX.md includes parent Jira ticket context
- [ ] User offered to execute or review
</success_criteria>
