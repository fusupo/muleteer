# Issue #2 - Rearchitect commands as skills for automatic invocation

**Archived:** 2025-12-29
**PR:** #6 (merged)
**Status:** Completed

## Summary

Converted Muleteer from slash-command based workflow to skill-based workflow that integrates with Claude Code's natural language capabilities. Created 6 new skills, removed commands directory entirely.

## Key Decisions

1. **Skill invocation:** Hybrid approach - skills can be invoked automatically via natural language OR explicitly via Skill tool
2. **Migration strategy:** Clean break - removed commands entirely, no backward compatibility layer
3. **prime-session:** Converted to auto-invoke skill that activates when entering new/unfamiliar repo

## Files Changed

**Created:**
- `skills/commit-changes/SKILL.md`
- `skills/create-pr/SKILL.md`
- `skills/review-pr/SKILL.md`
- `skills/work-session/SKILL.md`
- `skills/archive-work/SKILL.md`
- `skills/prime-session/SKILL.md`
- `CLAUDE.md`

**Modified:**
- `install.sh` - Removed commands logic, added cleanup
- `skills/issue-setup/SKILL.md` - Added interactive Q&A phase

**Deleted:**
- `commands/` directory (all 6 command files)

## Lessons Learned

- Scratchpad templates should only contain implementation tasks, not workflow actions (commit/push/PR)
- Workflow actions should be invoked conversationally when ready, not pre-planned
- Interactive Q&A (AskUserQuestion) helps resolve ambiguities before implementation begins
