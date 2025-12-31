# Issue #7 - Create Uninstall Script

**Archived:** 2025-12-30
**PR:** #10
**Status:** Merged

## Summary
Created `uninstall.sh` script to cleanly remove Muleteer from `~/.claude/`. The script reverses everything that `install.sh` creates: skill symlinks, agent symlinks, CLAUDE.md section, and PreCompact hook.

## Key Decisions
- Use symlink target path detection (`readlink` + grep for "muleteer") to identify only Muleteer items
- Use awk for reliable multi-line CLAUDE.md section removal
- Use jq for settings.json hook removal (with fallback warning if jq unavailable)
- Idempotent design - safe to run multiple times

## Files Changed
- `uninstall.sh` (created) - Main uninstall script with full functionality
- `README.md` (modified) - Added uninstall instructions

## Features Implemented
- `--dry-run` flag for preview mode
- `--force` flag to skip confirmation
- `--cleanup` flag for empty directory removal
- Color-coded output with summary
- Confirmation prompt before removal

## Lessons Learned
- awk is more reliable than sed for multi-line text removal
- Checking symlink targets is a safe way to identify "owned" symlinks without tracking state
