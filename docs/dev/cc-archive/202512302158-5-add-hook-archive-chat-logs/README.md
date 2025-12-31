# Issue #5 - Add hook to archive chat logs before auto-compaction threshold

**Archived:** 2025-12-30
**PR:** #8 (merged)
**Status:** Completed

## Summary

Implemented a PreCompact hook system that archives Claude Code session logs before compaction occurs. This preserves valuable implementation details, decisions, and troubleshooting context that would otherwise be lost during auto-compaction.

## Key Components

- **`scripts/archive-session-log.sh`** - Bash script that parses hook input, converts JSONL transcript to Markdown, and saves to project root
- **`templates/hooks-config.json`** - Template configuration for settings.json
- **`docs/SESSION-ARCHIVING.md`** - User documentation for the feature
- **`install.sh`** - Updated to auto-configure the PreCompact hook

## Key Decisions

1. **Archive Location:** Hook saves to project root (`SESSION_LOG_N.md`), `archive-work` skill moves to final archive location
2. **Format:** Markdown only for human readability
3. **Trigger:** Both auto and manual compaction (requires dual matchers: "manual" and "auto")
4. **Bug Fix:** PreCompact hooks don't support `"*"` wildcard - must use separate matcher entries

## Files Changed

- `scripts/archive-session-log.sh` (new)
- `templates/hooks-config.json` (new)
- `docs/SESSION-ARCHIVING.md` (new)
- `install.sh` (updated)
- `skills/archive-work/SKILL.md` (already had SESSION_LOG support)

## Lessons Learned

- Claude Code PreCompact hooks only accept `"manual"` or `"auto"` as matchers, NOT `"*"` wildcards
- Hook configuration is loaded at Claude Code startup - changes require session restart
- The `$CLAUDE_PROJECT_DIR` environment variable provides reliable project context for hooks
