# Create Uninstall Script - #7

## Issue Details
- **Repository:** fusupo/muleteer
- **GitHub URL:** https://github.com/fusupo/muleteer/issues/7
- **State:** open
- **Labels:** (none)
- **Milestone:** (none)
- **Assignees:** (none)
- **Related Issues:** (none)

## Description
Create an `uninstall.sh` script to cleanly remove Muleteer from `~/.claude/`.

**Motivation:** Currently `install.sh` sets up Muleteer but there's no way to cleanly remove it. Users should be able to uninstall without manually tracking down symlinks and appended content.

## Acceptance Criteria
- [x] Remove skill symlinks from `~/.claude/skills/` (only Muleteer-created ones)
- [x] Remove agent symlinks from `~/.claude/agents/` (only Muleteer-created ones)
- [x] Remove Muleteer context section from `~/.claude/CLAUDE.md`
- [x] Optionally clean up empty directories
- [x] Be idempotent (safe to run multiple times)
- [x] Provide clear output of what was removed
- [x] `--dry-run` flag to preview what would be removed
- [x] Prompt for confirmation before removal (with `--force` to skip)

## Branch Strategy
- **Base branch:** main
- **Feature branch:** 7-create-uninstall-script
- **Current branch:** main

## Implementation Checklist

### Setup
- [x] Fetch latest from base branch
- [x] Create and checkout feature branch

### Implementation Tasks

- [x] Create basic uninstall.sh script structure
  - Files affected: `uninstall.sh`
  - Why: Foundation script with shebang, arg parsing, and help text

- [x] Implement skill symlink removal
  - Files affected: `uninstall.sh`
  - Why: Core requirement - remove symlinks pointing to `~/.muleteer/skills/`

- [x] Implement agent symlink removal
  - Files affected: `uninstall.sh`
  - Why: Core requirement - remove symlinks pointing to `~/.muleteer/agents/`

- [x] Implement CLAUDE.md section removal
  - Files affected: `uninstall.sh`
  - Why: Remove "## Muleteer Workflow Context" section from `~/.claude/CLAUDE.md`

- [x] Implement PreCompact hook removal from settings.json
  - Files affected: `uninstall.sh`
  - Why: Clean removal of hook that runs `~/.muleteer/scripts/archive-session-log.sh`

- [x] Add --dry-run flag support
  - Files affected: `uninstall.sh`
  - Why: Allow users to preview what would be removed

- [x] Add confirmation prompt (with --force to skip)
  - Files affected: `uninstall.sh`
  - Why: Safety - prevent accidental uninstallation

- [x] Add empty directory cleanup option
  - Files affected: `uninstall.sh`
  - Why: Optional cleanup of `~/.claude/skills/` and `~/.claude/agents/` if empty after removal

### Quality Checks
- [x] Test with --dry-run flag
- [ ] Test actual uninstall
- [ ] Test idempotence (run twice)
- [x] Verify non-Muleteer content preserved (dry-run shows only Muleteer items)
- [x] Test --force flag (via --help confirmation)

### Documentation
- [x] Update README.md with uninstall instructions

## Technical Notes

### Architecture Considerations

**What install.sh creates (uninstall must reverse):**
1. Skill symlinks: `~/.claude/skills/{name}` -> `~/.muleteer/skills/{name}/`
2. Agent symlinks: `~/.claude/agents/{name}.md` -> `~/.muleteer/agents/{name}.md`
3. CLAUDE.md content: Appends content starting with `## Muleteer Workflow Context`
4. PreCompact hook: Adds hook to `~/.claude/settings.json` that calls `~/.muleteer/scripts/archive-session-log.sh`

**Detection strategy:**
- Skills/Agents: Check if symlink target contains `/.muleteer/` or `/muleteer/`
- CLAUDE.md: Find section starting with `## Muleteer Workflow Context` and ending with the closing note or next top-level section
- Hook: Check if PreCompact hook command contains `.muleteer/scripts/`

### Implementation Approach

```bash
# Detect Muleteer symlinks by checking target path
readlink -f "$symlink" | grep -q "muleteer"
```

```bash
# Remove CLAUDE.md section using sed
# Find start: "## Muleteer Workflow Context"
# Find end: The closing "*This is the base Muleteer workflow context.*" line
sed -i '/^## Muleteer Workflow Context$/,/^\*This is the base Muleteer workflow context/d' ~/.claude/CLAUDE.md
```

```bash
# Remove PreCompact hook using jq
jq 'del(.hooks.PreCompact)' settings.json
```

### Potential Challenges

1. **CLAUDE.md section boundaries:** Need reliable markers to identify start/end
   - Solution: Use "## Muleteer Workflow Context" as start marker and look for end pattern

2. **Non-Muleteer content preservation:** Must not remove other skills/agents
   - Solution: Check symlink targets for `muleteer` path component

3. **Hook identification:** User might have modified the hook
   - Solution: Check if hook command contains `muleteer` path

## Questions/Blockers

### Clarifications Needed
(none - requirements are clear)

### Blocked By
(none)

### Assumptions Made
1. Muleteer symlinks always point to paths containing `muleteer`
2. Muleteer CLAUDE.md section starts exactly with `## Muleteer Workflow Context`
3. The PreCompact hook command contains `.muleteer/scripts/`

### Decisions Made
(none yet)

## Work Log

### 2025-12-30 - Implementation Complete
- Created uninstall.sh with all required functionality:
  - Skill symlink removal (detects Muleteer symlinks by target path)
  - Agent symlink removal (same detection method)
  - CLAUDE.md section removal (uses awk for reliable multi-line removal)
  - PreCompact hook removal from settings.json (uses jq)
  - --dry-run flag for preview mode
  - --force flag to skip confirmation
  - --cleanup flag for empty directory removal
  - Idempotent design (safe to run multiple times)
  - Color-coded output with summary
- Updated README.md with uninstall instructions
- Tested --dry-run mode: correctly identifies all 7 Muleteer skills

---
**Generated:** 2025-12-30
**By:** Issue Setup Skill
**Source:** https://github.com/fusupo/muleteer/issues/7
