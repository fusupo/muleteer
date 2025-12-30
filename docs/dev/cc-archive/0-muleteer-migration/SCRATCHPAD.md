# Muleteer Migration Plan

**Project:** White-label the `.claude-crg` workflow as generic "muleteer" workflow
**Date:** 2025-12-27

## Overview

Migrate the CRG-specific Claude Code workflow from `~/.claude-crg` to `~/.muleteer` as a generic, reusable workflow system. The workflow is currently half-complete but provides a solid foundation for a generic implementation.

## Current State Analysis

### Source: `.claude-crg` Directory Structure
```
.claude-crg/
├── skills/
│   └── crg-issue-setup/
│       └── SKILL.md              # Issue → scratchpad workflow (398 lines)
├── commands/
│   ├── crg-archive-dev.md        # Archive development work
│   ├── crg-commit.md             # Conventional commits (129 lines)
│   ├── crg-open-pr.md            # PR creation helper
│   ├── crg-prime-session.md      # Session orientation
│   ├── crg-pr-review.md          # PR review workflow
│   └── crg-start-work.md         # Begin work from scratchpad
├── agents/                       # (Not yet created, but referenced in README)
│   ├── crg-semantic-analyzer.md  # (future)
│   └── crg-reviewer.md           # (future)
├── CLAUDE-CRG.md                 # CRG-specific context (130 lines)
├── install.sh                    # Symlink installer (97 lines)
├── README.md                     # Documentation (206 lines)
└── workflow.png                  # Workflow diagram

Target: `.muleteer/`
├── README.md (currently just "# muleteer")
```

## Migration Strategy

### Phase 1: Branding & Naming
**Goal:** Strip CRG-specific branding, establish Muleteer identity

#### 1.1 Naming Conventions
- **Prefix:** Replace `crg-` with `mltr-` or no prefix (evaluate case-by-case)
- **Project name:** "Muleteer" (you're the mule, I'm driving you)
- **Tagline:** Generic workflow system for Claude Code development
- **Context file:** `CLAUDE-CRG.md` → `CLAUDE-MULETEER.md` (generic version)

#### 1.2 File Renaming Map
```
commands/crg-archive-dev.md    → commands/archive-dev.md
commands/crg-commit.md         → commands/commit.md
commands/crg-open-pr.md        → commands/open-pr.md
commands/crg-prime-session.md  → commands/prime-session.md
commands/crg-pr-review.md      → commands/pr-review.md
commands/crg-start-work.md     → commands/start-work.md
skills/crg-issue-setup/        → skills/issue-setup/
CLAUDE-CRG.md                  → CLAUDE-MULETEER.md (genericized)
```

### Phase 2: Content De-Branding
**Goal:** Remove CRG-specific references while preserving functionality

#### 2.1 Files Requiring Heavy Edits
1. **CLAUDE-CRG.md → CLAUDE-MULETEER.md**
   - Remove: All CRG semantic platform specifics (Archivist, Clarity, etc.)
   - Remove: Gellish methodology, OSM patterns, fact triples
   - Remove: V1.0 philosophy specific to Relica project
   - Keep: Generic development philosophy principles
   - Keep: Workflow conventions (adapt to be project-agnostic)
   - Add: Generic placeholder sections for project customization

2. **README.md**
   - Remove: "Corpus Relica Generalis" branding throughout
   - Remove: CRG-specific examples (CRG-42, etc.)
   - Replace: With generic examples
   - Update: Installation paths (.claude-crg → .muleteer)
   - Update: Philosophy section (make generic)
   - Update: Repository references

3. **install.sh**
   - Update: Echo messages ("CRG Claude Code workflow" → "Muleteer workflow")
   - Update: CLAUDE-CRG.md reference → CLAUDE-MULETEER.md
   - Update: Comments and output messages
   - Keep: Core symlink logic (it's already generic)

#### 2.2 Skills Requiring Edits
1. **skills/issue-setup/SKILL.md**
   - Line 12: "CRG Issue Setup Skill" → "Issue Setup Skill"
   - Lines 275-291: Remove "For CRG Semantic Platform Projects" section
   - Line 397: "Maintained By: Corpus Relica Generalis" → generic
   - Update: Examples from CRG-specific to generic
   - Keep: Core workflow logic (already mostly generic)
   - Update: Branch naming from `{TEAM}-{NUM}` to just `{NUM}-{slug}`
   - Consider: Make project-specific sections templated/configurable

#### 2.3 Commands Requiring Edits
1. **commit.md** (formerly crg-commit.md)
   - Lines 36-43: Remove/genericize module-specific emojis (archivist, clarity, etc.)
   - Lines 9-10: Adapt PROJECT_CONTEXT.md reference
   - Lines 23-24: Remove V1.0 specific prioritization
   - Lines 110-111: Remove CRG module-specific commit body guidance
   - Keep: Conventional commits format
   - Keep: Change type emojis (they're generic)
   - Add: Configuration section for project-specific module emojis

2. **prime-session.md** (formerly crg-prime-session.md)
   - Remove: CRG-specific orientation
   - Generalize: To read any project's CLAUDE.md or similar

3. **pr-review.md** (formerly crg-pr-review.md)
   - Remove: Epic-aware references specific to CRG
   - Generalize: Review workflow

4. **Other commands** (archive-dev, open-pr, start-work)
   - Review for CRG-specific references
   - Likely already generic, just verify

### Phase 3: Structure & Organization
**Goal:** Establish clean Muleteer directory structure

#### 3.1 Directory Layout
```
.muleteer/
├── skills/
│   └── issue-setup/
│       └── SKILL.md
├── commands/
│   ├── archive-dev.md
│   ├── commit.md
│   ├── open-pr.md
│   ├── prime-session.md
│   ├── pr-review.md
│   └── start-work.md
├── agents/                    # Empty for now, ready for future
│   └── .gitkeep
├── templates/                 # NEW: Project customization templates
│   ├── CLAUDE-MULETEER.template.md
│   └── commit-config.template.yml
├── docs/                      # NEW: Extended documentation
│   ├── WORKFLOW.md            # Workflow explanation
│   └── CUSTOMIZATION.md       # How to customize for projects
├── CLAUDE-MULETEER.md         # Generic workflow context
├── install.sh                 # Symlink installer
├── README.md                  # Main documentation
├── SCRATCHPAD.md             # This file
└── workflow.png              # Workflow diagram (if still relevant)
```

#### 3.2 New Files to Create
1. **templates/CLAUDE-MULETEER.template.md**
   - Stripped-down template showing how to customize
   - Placeholder sections for project-specific content

2. **templates/commit-config.template.yml**
   - YAML config for project-specific module emojis
   - Could be read by commit.md command

3. **docs/WORKFLOW.md**
   - Detailed workflow explanation
   - How the pieces fit together
   - When to use each skill/command

4. **docs/CUSTOMIZATION.md**
   - How to adapt Muleteer to specific projects
   - Examples of customization
   - Best practices

### Phase 4: Multi-Project Customization Strategy
**Goal:** Support multiple projects on same system with per-project customization

#### 4.1 Architecture Principle: Per-Project Config
**IMPORTANT:** Muleteer must support multiple projects on the same system

- **Global layer:** `.muleteer/` contains generic workflow (installed once)
- **Per-project layer:** Each project repo has its own `CLAUDE.md` with customizations
- Commands/skills read project-local `CLAUDE.md` to get project-specific settings
- No global config file that would lock to single project

**Example:**
```
# System-wide (once)
~/.muleteer/         # Generic workflow base
~/.claude/           # Symlinks to muleteer

# Per-project (in each repo)
~/projects/project-a/.git/
~/projects/project-a/CLAUDE.md    # Project A's module emojis, conventions
~/projects/project-b/.git/
~/projects/project-b/CLAUDE.md    # Project B's module emojis, conventions
~/projects/relica/.git/
~/projects/relica/CLAUDE.md       # Relica's module emojis (via .claude-crg)
```

#### 4.2 Customization Approach (DECISION: Documentation-based)
- **No global config files** - Would break multi-project support
- **Per-project customization** via each repo's `CLAUDE.md`
- Document in `docs/CUSTOMIZATION.md` how to add project-specific sections
- Commands detect current git repo and read its `CLAUDE.md`
- Example customization sections to copy/paste into project's `CLAUDE.md`

#### 4.3 Backwards Compatibility
- `.muleteer` becomes the generic base (global)
- `.claude-crg` becomes CRG-specific extension layer (global, but thin)
- Each CRG project repo has its own `CLAUDE.md` with CRG modules
- Multiple CRG projects can coexist with non-CRG projects

### Phase 5: Documentation
**Goal:** Clear, comprehensive docs for generic use

#### 5.1 README.md Structure
```markdown
# Muleteer

Generic Claude Code workflow system. You're the mule, I'm driving you.

## What This Is
- Reusable workflow modules (skills)
- Quick workflow helpers (commands)
- Extensible for project-specific needs

## Features
- Issue → Scratchpad workflow
- Conventional commits with emojis
- PR creation and review
- Session orientation

## Installation
[Generic installation instructions]

## Quick Start
[Basic usage examples]

## Customization
[How to adapt for specific projects]

## Philosophy
[Generic development principles]
```

#### 5.2 Migration Guide for CRG
Create `docs/CRG_MIGRATION.md` explaining how `.claude-crg` will use Muleteer going forward.

## Implementation Checklist

### Prerequisites
- [x] Decide on final naming: **No prefix** - Commands become `/commit`, `/prime-session`, etc.
- [x] Decide on config system: **Per-project only** - No global config (supports multiple projects)
- [x] Review workflow.png - **Generic enough to use as-is**
- [x] Issue tracking: **GitHub only** for now (no Linear support)
- [x] CRG workflow: **Will become thin wrapper** over Muleteer

### Execution Order

#### Step 1: Setup Muleteer Structure
- [ ] Create directory structure in `.muleteer`
- [ ] Create empty directories: agents/, templates/, docs/
- [ ] Add .gitkeep to empty dirs

#### Step 2: Copy & Rename Files
- [ ] Copy skills/crg-issue-setup/ → skills/issue-setup/
- [ ] Copy all commands/ files (without crg- prefix)
- [ ] Copy install.sh
- [ ] Copy workflow.png

#### Step 3: De-brand Core Files
- [ ] Edit README.md (remove CRG branding)
- [ ] Edit install.sh (update messages)
- [ ] Create CLAUDE-MULETEER.md (generic version)

#### Step 4: De-brand Skills
- [ ] Edit skills/issue-setup/SKILL.md:
  - [ ] Remove CRG-specific sections
  - [ ] Genericize examples
  - [ ] Make branch naming configurable
  - [ ] Remove semantic platform references

#### Step 5: De-brand Commands
- [ ] Edit commands/commit.md:
  - [ ] Remove hardcoded CRG module emojis
  - [ ] Add note about customizing via project CLAUDE.md
  - [ ] Genericize examples
- [ ] Edit commands/prime-session.md
- [ ] Edit commands/pr-review.md
- [ ] Verify other commands are generic (archive-dev, open-pr, start-work)

#### Step 6: Create New Documentation
- [ ] Write docs/WORKFLOW.md
- [ ] Write docs/CUSTOMIZATION.md (include module emoji examples)
- [ ] Create templates/CLAUDE-MULETEER.template.md

#### Step 7: Testing
- [ ] Test install.sh in fresh environment
- [ ] Verify symlinks created correctly
- [ ] Test each command works
- [ ] Test issue-setup skill

#### Step 8: CRG Adaptation (Future)
- [ ] Update .claude-crg to use Muleteer as base
- [ ] Create CRG-specific config file
- [ ] Verify CRG workflow still works

## Decisions Made

✅ **All decisions confirmed - ready to implement**

1. **Naming:** ✓ Drop prefixes entirely
   - Commands: `/commit`, `/prime-session`, `/pr-review`, etc.
   - Skills: `issue-setup` (not `mltr-issue-setup`)
   - Cleaner, more universal approach

2. **Configuration System:** ✓ Per-project customization only
   - No global config file (would break multi-project support)
   - Each project repo customizes via its own `CLAUDE.md`
   - Document customization patterns in `docs/CUSTOMIZATION.md`
   - Commands read current project's `CLAUDE.md` for settings

3. **Workflow Diagram:** ✓ Generic enough to use
   - workflow.png is project-agnostic
   - Copy as-is to `.muleteer/`

4. **Issue Tracking:** ✓ GitHub only for now
   - issue-setup skill supports GitHub issues
   - No Linear support in initial version
   - Can expand later if needed

5. **CRG Workflow:** ✓ Becomes thin wrapper over Muleteer
   - `.claude-crg` will extend `.muleteer` base
   - CRG-specific customization layer on top
   - Maintains backwards compatibility

## Risk Assessment

### Low Risk
- File renaming (reversible)
- Directory structure (new, doesn't affect CRG)
- Documentation updates

### Medium Risk
- De-branding skill content (need to preserve functionality)
- Install script changes (affects installation)
- Configuration system design (affects extensibility)

### Mitigation
- Work in `.muleteer` directory (doesn't affect `.claude-crg`)
- Keep `.claude-crg` as reference
- Test thoroughly before symlinking
- Version control everything

## Success Criteria

A successful migration produces:

✓ **Generic workflow:** No CRG-specific references in core files
✓ **Clear documentation:** Easy for others to understand and use
✓ **Extensible design:** Projects can customize without forking
✓ **Functional install:** `install.sh` works in fresh environment
✓ **CRG compatible:** Original workflow can be rebuilt on Muleteer base

## Next Steps

1. ✅ **Review this plan** - COMPLETE
2. ✅ **Make final decisions** - COMPLETE (all decisions made)
3. **Begin implementation** - Ready to start following checklist
4. **Test incrementally** - Verify each step as we go

---

**Status:** Ready to Implement
**Created:** 2025-12-27
**Updated:** 2025-12-27 (decisions finalized)
**Project:** Muleteer (generic Claude Code workflow)
