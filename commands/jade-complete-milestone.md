---
name: jade:complete-milestone
description: Mark current milestone as complete
argument-hint: "[version]"
allowed-tools: [Read, Write, Edit, Bash, Glob]
---

<objective>
Complete the current milestone, archive it, and evolve PROJECT.md.

**When to use:** All phases in current milestone are complete and verified.
</objective>

<context>
$ARGUMENTS

@.jade/PROJECT.md
@.jade/STATE.md
@.jade/ROADMAP.md
@.jade/MILESTONES.md
</context>

<process>
1. Verify all phases complete
2. Archive milestone with summary
3. Create git tag for version
4. Evolve PROJECT.md with learnings
5. Update STATE.md
</process>

<success_criteria>
- [ ] Milestone archived with summary
- [ ] PROJECT.md evolved
- [ ] Git tag created
- [ ] STATE.md updated
</success_criteria>
