# Add hook to archive chat logs before auto-compaction threshold - #5

## Issue Details
- **Repository:** fusupo/muleteer
- **GitHub URL:** https://github.com/fusupo/muleteer/issues/5
- **State:** open
- **Labels:** None
- **Milestone:** None
- **Assignees:** None
- **Related Issues:** None

## Description

Claude Code has an auto-compaction feature that triggers when the conversation context approaches token limits. When this happens, conversation history may be condensed or lost, losing valuable implementation details, decisions, and troubleshooting context.

This issue creates a hook-based system to:
1. Detect when we're approaching the auto-compaction threshold
2. Archive the full chat log before compaction occurs
3. Trigger manual compaction at a controlled point

## Acceptance Criteria

- [ ] Hook detects approaching auto-compaction threshold
- [ ] Full chat log archived to project location before compaction
- [ ] Archive includes metadata (timestamp, issue, branch, etc.)
- [ ] Manual compaction triggered after successful archive
- [ ] Process is transparent to user (notification of archiving)
- [ ] Archived logs are easily accessible and readable
- [ ] Hook configuration documented for customization

## Branch Strategy
- **Base branch:** main
- **Feature branch:** 5-add-hook-archive-chat-logs
- **Current branch:** main

## Technical Research Summary

### Claude Code Hook System

**Key Finding:** Claude Code has a `PreCompact` hook that fires BEFORE auto-compaction occurs.

**Hook Input (via stdin JSON):**
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session-id.jsonl",
  "trigger": "auto" | "manual",
  "hook_event_name": "PreCompact"
}
```

**Capabilities:**
- `transcript_path` provides the full conversation log file
- Hook can execute bash scripts to archive before compaction
- Exit code 0 allows compaction to proceed normally
- Exit code 2 blocks compaction with error message

**Configuration Location:**
- User settings: `~/.claude/settings.json` (global)
- Project settings: `.claude/settings.json` (per-project)

### Archive Strategy

**Current Convention (from archive-work skill):**
```
docs/dev/cc-archive/
└── {issue-number}-{description}/
    ├── SCRATCHPAD_{issue_number}.md
    └── README.md
```

**Session Log Location:**
- Hook saves to project root: `SESSION_LOG_1.md`, `SESSION_LOG_2.md`, etc.
- At archive time, `archive-work` skill moves them with the scratchpad
- Timestamp prefix applied only at archive time (consistent with scratchpad)

## Implementation Checklist

### Setup
- [x] Fetch latest from main
- [x] Create and checkout feature branch: `5-add-hook-archive-chat-logs`

### Implementation Tasks

#### Task 1: Create archive script
- [x] Create `scripts/archive-session-log.sh` in .muleteer
  - Files: `scripts/archive-session-log.sh`
  - Purpose: Parse hook input, extract transcript, save to project root

Script should:
1. Read JSON input from stdin
2. Extract `transcript_path` and `session_id`
3. Detect current project from `$CLAUDE_PROJECT_DIR`
4. **Save to project root with incremental naming:**
   - Find next available number: `SESSION_LOG_1.md`, `SESSION_LOG_2.md`, etc.
   - Simple approach: count existing SESSION_LOG_*.md files + 1
5. Convert JSONL transcript to readable markdown
6. Add metadata header (timestamp, branch, session_id)
7. Save to project root (NOT archive dir - that's archive-work's job)
8. Exit 0 to allow compaction to proceed

**Key simplification:** Hook doesn't worry about final archive location.
Session logs sit in project root until `archive-work` moves them with the scratchpad.

#### Task 2: Create hook configuration template
- [x] Create template hook configuration for settings.json
  - Files: `templates/hooks-config.json`
  - Purpose: Example configuration users can add to their settings

Configuration structure:
```json
{
  "hooks": {
    "PreCompact": [
      {
        "matcher": "auto",
        "hooks": [
          {
            "type": "command",
            "command": "~/.muleteer/scripts/archive-session-log.sh",
            "timeout": 60
          }
        ]
      }
    ]
  }
}
```

#### Task 3: Update install.sh
- [x] Add scripts directory creation and permissions
  - Files: `install.sh`
  - Purpose: Ensure archive script is executable after install

#### Task 4: Create documentation
- [x] Document hook setup and customization
  - Files: `docs/SESSION-ARCHIVING.md`
  - Purpose: User guide for enabling and configuring session archiving

Documentation should cover:
- How to enable (add to settings.json)
- Archive format and location
- Customization options
- Troubleshooting

#### Task 5: Integration with archive-work skill
- [x] Update archive-work skill to recognize session logs (already implemented in v1.2.0)
  - Files: `skills/archive-work/SKILL.md`
  - Purpose: Archive skill can now handle session logs too

### Quality Checks
- [ ] Test hook with manual compaction (/compact)
- [ ] Verify archive is created in correct location
- [ ] Confirm transcript is readable markdown
- [ ] Test with multi-project setup
- [ ] Verify install.sh handles scripts correctly

### Documentation
- [ ] Update README.md with session archiving feature
- [ ] Add session archiving to CLAUDE.md capabilities list

## Technical Notes

### Architecture Considerations

**Hook Location:** The hook script lives in `~/.muleteer/scripts/` so it's available globally but archives to each project's `docs/dev/cc-archive/session-logs/`.

**Project Detection:** Uses `$CLAUDE_PROJECT_DIR` environment variable provided by Claude Code hooks system.

**Transcript Format:** The `transcript_path` points to a JSONL file with conversation turns. Script will convert to readable markdown.

### Implementation Approach

1. **Minimal Hook Script:** Keep the bash script simple and focused
2. **Project-Aware:** Archive goes to current project, not global
3. **Non-Blocking:** Always exit 0 to not interrupt workflow
4. **Metadata Rich:** Include branch, session ID, timestamp
5. **Readable Format:** Convert JSONL to markdown for human consumption

### Potential Challenges

1. **JSONL Parsing:** Need to parse conversation format correctly
2. **Large Transcripts:** Very long sessions may need truncation or split
3. **Missing Project Dir:** Handle case where not in a project context
4. **Permissions:** Ensure script is executable after install

## Questions/Blockers

### Clarifications Needed
None - all resolved

### Blocked By
None

### Assumptions Made
- Claude Code hook system is stable and available
- `$CLAUDE_PROJECT_DIR` is reliably set
- JSONL transcript format is consistent

### Decisions Made
**2025-12-29**

**Q: Where should the hook save session logs?**
**A:** Project root with incremental naming:
- Hook saves to: `SESSION_LOG_1.md`, `SESSION_LOG_2.md`, etc.
- `archive-work` skill moves them with scratchpad at archive time
- Final location determined by archive-work, not the hook
**Rationale:** Simpler hook logic; timestamp prefix applied at archive time; keeps session logs with scratchpad

**Q: What format should archived session logs use?**
**A:** Markdown only
**Rationale:** Human-readable, diff-friendly, easy to review

**Q: Should the hook trigger for manual /compact commands?**
**A:** Both auto and manual (matcher: "*")
**Rationale:** User needs to capture session logs when work completes mid-context, not just when context fills up. Running `/compact` manually provides explicit control over when to archive.

## Work Log

### 2025-12-29 - Implementation Session

**Completed all implementation tasks:**

1. **Created `scripts/archive-session-log.sh`**
   - Bash script that reads PreCompact hook JSON input
   - Parses transcript_path and session_id from stdin
   - Converts JSONL transcript to readable Markdown
   - Saves to project root as SESSION_LOG_{N}.md
   - Non-blocking (always exits 0)

2. **Created `templates/hooks-config.json`**
   - Template for users to add to their settings.json
   - Configured for auto-compaction only (matcher: "auto")
   - 60 second timeout

3. **Updated `install.sh`**
   - Added section to make scripts executable
   - Added output showing available scripts
   - Added pointer to session archiving documentation

4. **Created `docs/SESSION-ARCHIVING.md`**
   - Complete user guide for the feature
   - Setup instructions
   - Configuration options
   - Troubleshooting section

5. **Verified archive-work skill**
   - Already had SESSION_LOG_*.md support (v1.2.0)
   - No changes needed

6. **Updated hook trigger decision**
   - Changed from "auto" only to "*" (both auto and manual)
   - Users can now run `/compact` to capture session log when work completes
   - No need to wait for context window to fill up

---
**Generated:** 2025-12-29
**By:** Issue Setup Skill
**Source:** https://github.com/fusupo/muleteer/issues/5
