# PM — Future Enhancements

Improvements to make PM a more powerful project management tool.

---

## Tier 1 — High Impact, Low Effort

### Optional Jira Integration
- Add optional Jira REST API integration for teams that use Jira
- Sync local STORY.md/TASK-NN.md status to Jira tickets
- Create Jira tickets from local tracking files on demand
- Keep local-first as the default — Jira as an optional overlay

### GitHub Project Board Sync
- Auto-create GitHub Project board from ROADMAP.md
- Sync task status to project board cards
- Use GitHub Issues as an alternative to local ISSUES.md

---

## Tier 2 — High Impact, Medium Effort

### Epic Container for the Project
- Create one GitHub Milestone per project at `pm:init`
- All phase PRs linked to the milestone
- Enables progress tracking via GitHub milestone progress

### Story Points (Task Count as Proxy)
- Set story points on each Story = count of tasks in plan (2-3 per PM convention)
- Track velocity across phases in STATE.md
- Display burndown in `/pm:progress`

### Time Tracking from SUMMARY.md
- Record actual duration per task and per phase
- Compare planned vs actual in progress reports
- Feed capacity planning for future phases

---

## Tier 3 — Nice to Have

### Automated PR Templates
- Generate PR body templates from TASK-NN.md automatically
- Include TDD results, file changes, and AC links
- Standardize PR format across all tasks

### Multi-Reviewer Support
- Allow specifying reviewers per task discipline
- Frontend tasks → frontend reviewer
- Backend tasks → backend reviewer
- Auto-assign via `gh pr create --reviewer`
