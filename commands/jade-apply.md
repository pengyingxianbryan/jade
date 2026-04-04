---
name: jade:apply
description: Execute plan with GitHub gate + RED/GREEN/REFACTOR TDD enforcement per task
argument-hint: "[plan-path]"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion]
---

<objective>
Execute an approved PLAN.md file with strict TDD enforcement and GitHub integration.

**When to use:** After PLAN phase complete and plan is approved (APPROVE received).

Every task runs through RED → GREEN → REFACTOR with hard gates. Every task commits and pushes. Every task posts results to Jira.
</objective>

<context>
Plan path: $ARGUMENTS

@.jade/STATE.md
</context>

<process>

<!-- ════════════════════════════════════════════════ -->
<!-- GITHUB GATE — HARD                               -->
<!-- ════════════════════════════════════════════════ -->

<step name="github_gate" priority="first">
**Before writing a single line of code, verify GitHub remote:**

1. Run `git remote -v` — confirm origin is set to the configured repo URL
2. Run `git ls-remote origin HEAD` — confirm remote is reachable
3. Run `git status` — confirm working tree is clean or on correct branch

**If ANY check fails: STOP immediately.**
Print exactly what failed. Do not write a single line of code.

```
❌ GitHub gate failed: [specific error]

[Diagnostic info]

Fix the issue and run /jade:apply again.
```
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- JIRA TICKET CREATION (if not yet created)        -->
<!-- ════════════════════════════════════════════════ -->

<step name="ensure_jira_ticket">
Read `jira:` field from PLAN.md frontmatter.

**Expected:** `jira:` should already have a ticket key — all tickets are created upfront during `/jade:plan` after APPROVE.

**If `jira:` is empty (fallback — e.g., plan was revised or added after initial approval):**
1. Source credentials: `source .jade/.env`
2. Create Jira ticket via REST API:
   ```bash
   source .jade/.env
   AUTH="Authorization: Basic $(echo -n "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" | base64)"
   curl -s -X POST \
     -H "$AUTH" -H "Content-Type: application/json" \
     "$JIRA_BASE_URL/rest/api/3/issue" \
     -d '{"fields":{"project":{"key":"'"$JIRA_PROJECT_KEY"'"},"summary":"[from objective]","issuetype":{"name":"Story"},"description":{"version":3,"type":"doc","content":[{"type":"paragraph","content":[{"type":"text","text":"[from ACs]"}]}]}}}'
   ```
3. Parse response for ticket key
4. Write `jira:` to PLAN.md frontmatter
5. Update STATE.md with ticket key

**If `jira:` already has a value:** proceed with existing key.
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- BRANCH CREATION                                  -->
<!-- ════════════════════════════════════════════════ -->

<step name="create_branch">
Read `jira:` field from PLAN.md frontmatter to get the ticket key.

1. Create feature branch: `git checkout -b jade/[jira_key]`
2. Push branch: `git push -u origin jade/[jira_key]`
3. Update STATE.md: `branch: jade/[jira_key]`
4. Print: "✅ Branch jade/[jira_key] created and pushed. Beginning TDD loop."
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- JIRA TRANSITION                                  -->
<!-- ════════════════════════════════════════════════ -->

<step name="jira_start">
1. Source credentials: `source .jade/.env`
2. Transition Jira ticket `To Do` → `In Progress` via REST API:
   ```bash
   AUTH="Authorization: Basic $(echo -n "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" | base64)"
   # Get available transitions
   TRANSITIONS=$(curl -s -H "$AUTH" "$JIRA_BASE_URL/rest/api/3/issue/$JIRA_KEY/transitions")
   # Find "In Progress" transition ID and POST it
   TRANSITION_ID=$(echo "$TRANSITIONS" | jq -r '.transitions[] | select(.name | test("progress";"i")) | .id')
   curl -s -X POST -H "$AUTH" -H "Content-Type: application/json" \
     "$JIRA_BASE_URL/rest/api/3/issue/$JIRA_KEY/transitions" \
     -d '{"transition":{"id":"'"$TRANSITION_ID"'"}}'
   ```
3. Update STATE.md: `status: In Progress`
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- VALIDATE PLAN                                    -->
<!-- ════════════════════════════════════════════════ -->

<step name="validate_plan">
1. Confirm plan file exists at $ARGUMENTS path (or find current plan from STATE.md)
2. Error if not found: "Plan not found: {path}"
3. Derive SUMMARY path (replace PLAN.md with SUMMARY.md)
4. If SUMMARY exists: "Plan already executed. SUMMARY: {path}"
5. Read all tasks from `<tasks>` section
6. Read `<boundaries>` — these files are OFF LIMITS during execution
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- TDD LOOP — PER TASK                              -->
<!-- ════════════════════════════════════════════════ -->

<step name="tdd_loop">
**For each `<task>` in the plan, execute in strict order:**

```
─── Task [N]: [task name] ──────────────────────────────

RED phase
  1. Identify test file for this task from <files> field
  2. Write the failing test. Touch ONLY test files.
  3. Run: [test command from <verify> field]
  4. Confirm output shows FAIL for the new test

  GATE: If new test passes before implementation → STOP.
        This means either the test is wrong or the feature already exists.
        Report to user and wait for instruction. Do not proceed.

GREEN phase
  5. Write minimal implementation. Touch ONLY implementation files.
  6. Run: [test command from <verify> field]
  7. Confirm ALL tests pass — new and existing.

  GATE: If any existing test breaks → STOP.
        Report exactly which tests broke and why. Do not proceed.

REFACTOR phase
  8. Clean up implementation. No new behaviour introduced.
  9. Run: [test command from <verify> field]
  10. Confirm still all green.

  GATE: If any test fails after refactor → STOP.
        Undo refactor changes and report.
```

**BOUNDARY CHECK:** Before writing any file, verify it is NOT listed in `<boundaries>` DO NOT CHANGE section. If it is, STOP and report.

**IMPLEMENTATION-BEFORE-TEST CHECK:** If implementation code for a task exists before the failing test is written, DELETE IT. Start clean. This is not negotiable.

**DESIGN QUALITY CHECK:** If the task involves frontend UI (components, pages, layouts, animations), activate the `designer-uxui` skill from `skills/designer-uxui/SKILL.md`. During REFACTOR phase, run the skill's Review Checklist against all UI code produced. Violations (wrong easing, missing reduced-motion, stacked glass elements, etc.) must be fixed before the task is marked complete.
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- COMMIT & PUSH — PER TASK                         -->
<!-- ════════════════════════════════════════════════ -->

<step name="commit_push">
After all three TDD phases pass for a task:

1. Stage changes: `git add -A`
2. Commit with structured message:
   ```
   feat([jira_key]): task [N] — [task name]

   - RED: [test file] — X tests added, confirmed failing
   - GREEN: [impl file] — all X tests passing
   - REFACTOR: cleanup applied

   Refs: [jira_key]

   Co-Authored-By: Claude <noreply@anthropic.com>
   ```
3. Push: `git push origin jade/[jira_key]`
4. Print: "✅ Pushed task [N] to jade/[jira_key]"
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- JIRA UPDATE — PER TASK                           -->
<!-- ════════════════════════════════════════════════ -->

<step name="jira_update">
Post comment to Jira ticket via REST API:

```bash
source .jade/.env
AUTH="Authorization: Basic $(echo -n "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" | base64)"
curl -s -X POST \
  -H "$AUTH" -H "Content-Type: application/json" \
  "$JIRA_BASE_URL/rest/api/3/issue/$JIRA_KEY/comment" \
  -d '{"body":{"version":3,"type":"doc","content":[{"type":"paragraph","content":[{"type":"text","text":"✅ Task [N] complete: [task name]\nRED ✓ | GREEN ✓ | REFACTOR ✓\nTests added: X | All passing: Y\nFiles: [list]\nCommit: [sha]"}]}]}}'
```
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- STATE UPDATE — PER TASK                          -->
<!-- ════════════════════════════════════════════════ -->

<step name="state_update">
Append to STATE.md TDD Results section:
```
task_[N]: RED ✓ | GREEN ✓ | REFACTOR ✓ | tests_added: X | passing: Y
```

Update `last_push:` timestamp in GitHub section.
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- CHECKPOINT HANDLING                               -->
<!-- ════════════════════════════════════════════════ -->

<step name="handle_checkpoints">
When a checkpoint task is reached (non-auto tasks):

**checkpoint:decision**
- Present decision context and options
- Wait for user selection
- Record decision
- Continue execution

**checkpoint:human-verify**
- Present what was built
- Present verification steps
- Wait for "approved" or issue description
- Continue execution

**checkpoint:human-action**
- Present required action
- Wait for "done" confirmation
- Continue execution
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- PHASE TRANSITION                                 -->
<!-- ════════════════════════════════════════════════ -->

<step name="phase_transition">
After all tasks in the current phase complete:

1. Check ROADMAP.md: are there more phases?
2. If yes:
   - Present: "Phase [N] complete. Phase [N+1] plan exists."
   - Ask: "Would you like to **review/revise** the plan for Phase [N+1], or **continue** as planned?"
   - If "revise" → instruct user to run `/jade:plan --revise N+1`
   - If "continue" → proceed to UNIFY for current phase
3. If no more phases: proceed to UNIFY (final)
</step>

<!-- ════════════════════════════════════════════════ -->
<!-- COMPLETION                                       -->
<!-- ════════════════════════════════════════════════ -->

<step name="complete">
After all tasks complete:

```
════════════════════════════════════════
APPLY COMPLETE
════════════════════════════════════════

All [N] tasks complete.
Branch: jade/[jira_key]
Commits: [N] pushed
Tests: [total] passing

TDD Results:
  task_1: RED ✓ | GREEN ✓ | REFACTOR ✓
  task_2: RED ✓ | GREEN ✓ | REFACTOR ✓

────────────────────────────────────────
▶ NEXT: /jade:unify
  Close the loop, post summary to Jira, open PR.
────────────────────────────────────────
```

Update STATE.md loop position: APPLY ✓
</step>

</process>

<success_criteria>
- [ ] GitHub remote verified before any code written
- [ ] Jira ticket exists (created if needed) before execution
- [ ] Feature branch created and pushed
- [ ] Jira ticket transitioned to In Progress
- [ ] Every task completed RED → GREEN → REFACTOR in order
- [ ] No test passed before implementation (RED gate)
- [ ] No existing tests broken (GREEN gate)
- [ ] Every task committed with structured message including jira key
- [ ] Every task pushed to feature branch
- [ ] Every task posted as Jira comment (via curl)
- [ ] STATE.md TDD Results updated per task
- [ ] Boundary files untouched
- [ ] Phase transition offered if more phases exist
- [ ] User informed of next action: /jade:unify
</success_criteria>
