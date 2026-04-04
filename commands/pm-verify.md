---
name: pm:verify
description: Simple UAT confirmation gate — updates Story status to Done on pass
argument-hint: "[optional: phase or plan number]"
allowed-tools: [Read, Write, Bash, Glob, AskUserQuestion]
---

<objective>
Simple confirmation gate for user acceptance testing. Show what was built, list merged PRs, and ask for PASS or FAIL.

**When to use:** After `/pm:unify` has posted the summary.

On PASS: updates STORY.md status to Done. On FAIL: captures issues for `/pm:plan --fix`.
</objective>

<context>
Scope: $ARGUMENTS (optional — defaults to most recently unified plan)

@.pm/STATE.md
</context>

<process>

<step name="find_scope">
1. If $ARGUMENTS provided: find matching SUMMARY.md
2. If not: find most recently created SUMMARY.md
3. Read SUMMARY.md for deliverables and AC results
4. Read STATE.md for PR URLs
5. Read TASK-NN.md files for completion records
</step>

<step name="present_summary">
Present what was built:

```
════════════════════════════════════════
UAT VERIFICATION — Phase [N]: [name]
════════════════════════════════════════

What was built:
[from SUMMARY.md — accomplishments section]

Acceptance Criteria:
  AC-1: [name] — [pass/fail from SUMMARY]
  AC-2: [name] — [pass/fail from SUMMARY]
  AC-3: [name] — [pass/fail from SUMMARY]

TDD Results:
[from STATE.md TDD Results section]

PRs merged:
  - Task 1: [PR URL]
  - Task 2: [PR URL]

────────────────────────────────────────
Review the changes and test them.

Type PASS to mark as Done, or FAIL to capture issues.
────────────────────────────────────────
```
</step>

<step name="handle_verdict">
Wait for user response.

**If PASS (or clear equivalent):**
1. Update STORY.md: set `Status` to `Done`
2. Mark all acceptance criteria in STORY.md as checked
3. Update STATE.md: `status: Done`
4. Print:
   ```
   UAT passed.
   Phase [N]: [name] → Done
   All [N] PRs merged and verified.
   ```

**If FAIL:**
1. Ask: "Describe the issues found."
2. Capture issues to `.pm/phases/XX-name/{plan}-UAT.md`:
   ```markdown
   # UAT Issues — Phase [N]

   ## Issue 1: [title]
   | Field | Value |
   |-------|-------|
   | Severity | Blocker / Major / Minor / Cosmetic |
   | AC Reference | AC-[N] |

   **Steps to reproduce:** [from user description]
   **Expected:** [from AC]
   **Actual:** [from user description]
   ```
3. Print:
   ```
   UAT issues captured.
   Issues logged: .pm/phases/XX-name/{plan}-UAT.md

   Issues found:
     Issue 1: [description] (Blocker)
     Issue 2: [description] (Major)

   ▶ NEXT: /pm:plan --fix [plan-number]
     Create a fix plan for the issues found.
   ```
</step>

</process>

<success_criteria>
- [ ] Summary of deliverables presented
- [ ] PR URLs shown
- [ ] User verdict collected (PASS or FAIL)
- [ ] On PASS: STORY.md updated to Done
- [ ] On FAIL: Issues captured to UAT.md with severity
- [ ] Clear next action provided
</success_criteria>
