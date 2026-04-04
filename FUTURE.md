# JADE — Future Enhancements

Enterprise Jira improvements to make the board a real product management tool, not just an audit trail.

---

## Tier 2 — High Impact, Medium Effort

### Epic Container for the Project
- Create one Epic per project/milestone at `jade:init`. All phase Stories become children.
- Enables burndown charts, board filtering by project, portfolio views.
- **Init**: `POST /rest/api/3/issue` with `"issuetype":{"name":"Epic"}`, discover Epic Link field via `GET /rest/api/3/field`, store `JIRA_EPIC_KEY` + `JIRA_EPIC_LINK_FIELD` in `.jade/.env`
- **Plan**: Add Epic Link field to Story creation payloads.
- Files: `jade-init.md`, `jade-plan.md`, `jade-apply.md`, `CLAUDE.md`

### Story Points (Task Count as Proxy)
- Set story_points on each Story = count of tasks in plan (2-3 per JADE convention).
- Lightweight estimation — enables velocity charts, burndown, capacity planning.
- **Init**: Discover Story Points field ID via `GET /rest/api/3/field`, store as `JIRA_STORY_POINTS_FIELD`
- **Plan**: Add `"$JIRA_STORY_POINTS_FIELD": N` to Story payloads.
- Files: `jade-init.md`, `jade-plan.md`, `jade-apply.md`

### Fix Version for Release Tracking
- Create Jira version per milestone at `jade:init`, assign to all Stories.
- Powers Jira Release Hub, release notes, release readiness tracking.
- **Init**: `POST /rest/api/3/version`, store ID as `JIRA_FIX_VERSION_ID`
- **Plan**: Add `"fixVersions":[{"id":"..."}]` to Story payloads.
- Files: `jade-init.md`, `jade-plan.md`

### Time Tracking from SUMMARY.md
- Post work log to Jira using duration from SUMMARY.md (`started`, `completed`, `duration`).
- Feeds capacity planning and "actual vs estimate" analysis.
- **Unify**: `POST /rest/api/3/issue/$KEY/worklog` with `timeSpentSeconds` from SUMMARY.md
- Files: `jade-unify.md`

---

## Tier 3 — Nice to Have (Opt-in)

### Sprint Assignment
- Auto-assign Stories to active sprint when transitioning to In Progress.
- Requires board ID + sprint ID discovery via Agile API.
- Gated by `JIRA_AUTO_SPRINT=true` in `.jade/.env` — many teams don't want automated sprint assignment.
- Files: `jade-apply.md`, `jade-init.md`

### JQL-Based Progress Reporting
- During `/jade:progress`, query Jira via JQL for ground truth instead of cached STATE.md.
- `GET /rest/api/3/search?jql=project=$KEY+AND+labels=jade-managed` — reconcile with STATE.md, flag drift.
- Files: `jade-progress.md`
