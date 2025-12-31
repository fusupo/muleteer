# Convert Muleteer to Official Claude Code Plugin Architecture - #9

## Issue Details
- **Repository:** fusupo/muleteer
- **GitHub URL:** https://github.com/fusupo/muleteer/issues/9
- **State:** open
- **Labels:** None
- **Milestone:** None
- **Assignees:** None
- **Related Issues:**
  - Supersedes: #7 (uninstall script - no longer needed with plugins)
  - Affects: #1 (documentation), #3 (affordances), #4 (validation)

## Description

Restructure Muleteer from a custom symlink-based installation to an official Claude Code plugin. This will enable marketplace distribution, proper versioning, and cleaner installation/uninstallation.

### Key Benefits of Plugin Architecture
- **Native distribution** via marketplace (vs manual symlinks)
- **Built-in namespacing** (`/muleteer:issue-setup` prevents conflicts)
- **Proper hooks system** (`hooks/hooks.json` vs template + script injection)
- **Version management** in manifest
- **Clean install/uninstall** via Claude Code itself (`/plugin install`)
- **No custom scripts needed** - eliminates `install.sh` and `uninstall.sh`

## Acceptance Criteria
- [x] Plugin structure created with `.claude-plugin/plugin.json`
- [x] All 7 skills have correct tool specifications
- [x] Hooks migrated to `hooks/hooks.json` with `${CLAUDE_PLUGIN_ROOT}`
- [x] Documentation updated for plugin-based usage
- [x] Legacy files removed (install.sh, uninstall.sh, templates/, scripts/)
- [ ] Plugin loads correctly with `claude --plugin-dir ./muleteer` (requires restart)
- [ ] Version 2.0.0 released as plugin architecture (pending PR merge)

## Branch Strategy
- **Base branch:** main
- **Feature branch:** 9-convert-to-plugin-architecture
- **Current branch:** 9-convert-to-plugin-architecture

## Implementation Checklist

### Phase 1: Plugin Infrastructure

- [ ] Create `.claude-plugin/plugin.json` manifest
  - Files: `.claude-plugin/plugin.json` (new)
  - Why: Required manifest file that defines plugin identity

- [ ] Create `hooks/hooks.json` from templates
  - Files: `hooks/hooks.json` (new), copy hook script to `hooks/`
  - Why: Migrate hook configuration to plugin format with `${CLAUDE_PLUGIN_ROOT}`

- [ ] Update README.md with plugin installation instructions
  - Files: `README.md`
  - Why: Users need new installation instructions

### Phase 2: Content Migration

- [ ] Evaluate and migrate CLAUDE-MULETEER.md content
  - Files: `CLAUDE-MULETEER.md` (remove or convert)
  - Why: Workflow guidance should live in skill descriptions or README
  - Decision: Keep as reference documentation, not auto-injected

- [ ] Update skill tool specifications for Claude Code plugin format
  - Files: `skills/*/SKILL.md`
  - Why: Tool names may need updating (e.g., `filesystem:*` → standard format)

- [ ] Consider adding optional slash commands for explicit invocation
  - Files: `commands/` (new, optional)
  - Why: Some users may prefer explicit `/muleteer:setup-issue` over natural language

### Phase 3: Cleanup

- [ ] Remove `install.sh` (plugins self-install)
  - Files: `install.sh` (delete)
  - Why: Plugin architecture handles installation

- [ ] Remove `uninstall.sh` (plugins handle uninstall)
  - Files: `uninstall.sh` (delete)
  - Why: `/plugin uninstall muleteer` handles this

- [ ] Archive or remove `templates/` directory
  - Files: `templates/` (remove or archive)
  - Why: Hook config now in `hooks/`, CLAUDE template may still be useful

- [ ] Remove `scripts/` directory (move archive script to hooks/)
  - Files: `scripts/` (move contents to hooks/)
  - Why: Consolidate hook-related scripts in hooks directory

### Phase 4: Testing & Documentation

- [ ] Test with `claude --plugin-dir ./muleteer`
  - All skills invocable
  - Hooks execute correctly
  - No conflicts with other plugins

- [ ] Update project CLAUDE.md
  - Files: `CLAUDE.md`
  - Why: Reflect new plugin-based architecture

- [ ] Document marketplace submission process
  - Files: `README.md` or `docs/DISTRIBUTION.md`
  - Why: For future marketplace publishing

### Quality Checks
- [ ] Run through all 7 skills manually
- [ ] Verify hooks trigger on PreCompact
- [ ] Test clean install on fresh system
- [ ] Verify no leftover symlinks needed

## Technical Notes

### Plugin Manifest Draft

```json
{
  "name": "muleteer",
  "description": "AI-code workflow system with issue tracking, smart commits, and PR creation",
  "version": "2.0.0",
  "author": {
    "name": "fusupo"
  },
  "repository": "https://github.com/fusupo/muleteer",
  "license": "MIT"
}
```

### Hook Configuration Changes

Current hook path: `~/.muleteer/scripts/archive-session-log.sh`
New hook path: `${CLAUDE_PLUGIN_ROOT}/hooks/archive-session-log.sh`

This makes the hook portable across installations.

### Skill Tool Specifications

Current skills use tool patterns like:
- `github:*` - should work with MCP GitHub tools
- `bash:git *` - bash patterns
- `filesystem:read_text_file` - may need updating

Need to verify these map correctly to Claude Code's tool naming:
- `mcp__github__*` for GitHub MCP tools
- `Bash` for bash commands
- `Read`, `Write`, `Edit` for filesystem

### Directory Structure Comparison

**Current:**
```
muleteer/
├── skills/           (7 skills)
├── agents/           (empty)
├── templates/        (hooks-config.json, CLAUDE template)
├── scripts/          (archive-session-log.sh)
├── docs/
├── install.sh        (to remove)
├── uninstall.sh      (to remove)
├── CLAUDE-MULETEER.md
├── CLAUDE.md
└── README.md
```

**Target:**
```
muleteer/
├── .claude-plugin/
│   └── plugin.json   (manifest)
├── skills/           (7 skills, unchanged)
├── agents/           (empty, unchanged)
├── hooks/
│   ├── hooks.json    (from templates/)
│   └── archive-session-log.sh
├── commands/         (optional explicit commands)
├── docs/
├── CLAUDE.md
└── README.md
```

## Questions/Blockers

### Clarifications Needed

1. **Namespace strategy:** Should skills remain natural-language invokable, or prefer explicit `/muleteer:skill-name`?
   - Recommendation: Keep both - skills trigger on natural language, users can also invoke explicitly

2. **CLAUDE-MULETEER.md disposition:** Delete, convert to README section, or keep as docs/WORKFLOW.md?
   - Recommendation: Content largely duplicates what's in docs/WORKFLOW.md - consolidate

3. **Per-project customization:** How do project-specific CLAUDE.md files interact with plugin?
   - Answer: Projects still use their own CLAUDE.md - this is Claude Code's design

4. **Hook bundling:** Should archive-session-log hook be enabled by default or opt-in?
   - Recommendation: Enabled by default (current behavior)

### Assumptions Made
- Plugin will be distributed via GitHub (clone/download) initially, marketplace later
- Skills are the primary interface (commands optional)
- Hook script requires jq (document as dependency)

### Decisions Made

**Q: Should skills remain invokable via natural language triggers, or prefer explicit /muleteer:skill-name commands?**
**A:** Both - Skills trigger on natural language AND can be invoked via `/muleteer:skill-name`
**Rationale:** Maximum flexibility for users

**Q: What should happen to CLAUDE-MULETEER.md content (workflow guidance)?**
**A:** Drop for now, rebuild docs if necessary later
**Rationale:** Content had little relevance to actual project functionality

**Q: Should the archive-session-log hook be enabled by default?**
**A:** Enabled by default (current behavior)
**Rationale:** Preserves session history automatically

## Work Log

### Session 1 - Plugin Migration (2025-12-31)

**Phase 1: Plugin Infrastructure**
- Created `.claude-plugin/plugin.json` manifest (v2.0.0)
- Created `hooks/hooks.json` with `${CLAUDE_PLUGIN_ROOT}` paths
- Copied archive-session-log.sh to hooks/ directory

**Phase 2: Content Migration**
- Updated `skills/issue-setup/SKILL.md` tool specs (github:* -> mcp__github__*, etc.)
- Other skills already had correct tool naming

**Phase 3: Cleanup**
- Removed `install.sh`, `uninstall.sh`, `CLAUDE-MULETEER.md`
- Removed `templates/` and `scripts/` directories
- Created `.gitignore` for .claude/, SCRATCHPAD_*, SESSION_LOG_*

**Documentation Updates**
- Updated `README.md` with plugin installation instructions
- Updated `CLAUDE.md` for plugin architecture
- Documented hook dependency on `jq`

**Pending**
- Test plugin with `claude --plugin-dir`
- Create PR

---
**Generated:** 2025-12-31
**By:** Issue Setup Skill
**Source:** https://github.com/fusupo/muleteer/issues/9
