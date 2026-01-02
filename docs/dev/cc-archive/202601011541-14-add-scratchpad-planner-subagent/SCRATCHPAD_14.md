# Add scratchpad-planner subagent for codebase analysis - #14

## Issue Details
- **Repository:** fusupo/muleteer
- **GitHub URL:** https://github.com/fusupo/muleteer/issues/14
- **State:** open
- **Labels:** (none)
- **Milestone:** (none)
- **Assignees:** (none)
- **Related Issues:** (none listed)

## Description

The `issue-setup` skill currently uses the generic Explore agent (via Task tool) for codebase analysis during the DeepDiveSolution phase. This works but has limitations:

- Generic exploration without specialized planning expertise
- Exploration context bloats main conversation
- Cannot resume analysis for large codebases
- Limited control over analysis methodology

**Proposed Solution:** Create a dedicated `scratchpad-planner` subagent specialized for the DeepDiveSolution workflow phase.

## Acceptance Criteria

- [x] Agent file created in `agents/scratchpad-planner.md`
- [x] System prompt includes specialized planning methodology
- [x] `issue-setup` skill updated to invoke scratchpad-planner
- [x] Agent can be resumed for iterative refinement
- [x] Agent reads and applies project CLAUDE.md conventions
- [x] Tested with complex issue requiring deep codebase analysis
- [x] Documentation updated in README.md

## Branch Strategy
- **Base branch:** main
- **Feature branch:** 14-add-scratchpad-planner-subagent
- **Current branch:** main

## Implementation Checklist

### Setup
- [ ] Fetch latest from base branch
- [ ] Create and checkout feature branch

### Implementation Tasks

#### Task 1: Create agent frontmatter and basic structure
- Files affected: `agents/scratchpad-planner.md` (NEW)
- Why: Define agent metadata, tools, and model configuration
- Details:
  - Create YAML frontmatter with name, description, tools, model
  - Use tools: Read, Grep, Glob, Bash, LSP (as specified in issue)
  - Model: sonnet
  - Description must include trigger conditions: "MUST be used during issue-setup's DeepDiveSolution phase"

#### Task 2: Write specialized system prompt for planning methodology
- Files affected: `agents/scratchpad-planner.md`
- Why: Provide deep expertise for codebase analysis and implementation planning
- Details:
  - System prompt sections:
    - **Role definition**: Specialized planning assistant for issue-setup workflow
    - **Codebase analysis methodology**: How to explore architecture, patterns, integrations
    - **Similar pattern identification**: LSP usage, code pattern matching
    - **Implementation approach generation**: Break down into atomic tasks
    - **Scratchpad structure**: Follow project CLAUDE.md conventions
    - **Interactive refinement**: How to pose clarifying questions
    - **Project awareness**: Read and apply project-specific conventions
    - **Resumability**: Support iterative refinement across invocations
  - Include examples of good vs. bad analysis
  - Reference muleteer's workflow philosophy (atomic commits, incremental progress)

#### Task 3: Update issue-setup skill to invoke scratchpad-planner
- Files affected: `skills/issue-setup/SKILL.md`
- Why: Replace generic Explore agent with specialized scratchpad-planner
- Details:
  - Modify Phase 2 (Analyze & Plan) - lines 118-134
  - Replace Task tool invocation with Skill tool invocation
  - Change from:
    ```
    Task:
      subagent_type: Explore
      prompt: "Analyze the codebase..."
    ```
  - To:
    ```
    Skill: scratchpad-planner
    args: "{issue context, repo info, specific areas}"
    ```
  - Update "When to delegate vs. do directly" guidance
  - Ensure agent receives issue number, summary, body, and project context

#### Task 4: Document the agent in README.md
- Files affected: `README.md`
- Why: User-facing documentation for the new agent capability
- Details:
  - Add agent to "Agents" section (if it exists, or create it)
  - Document purpose: Specialized codebase analysis for issue setup
  - Explain when it's invoked automatically (during issue-setup)
  - Note benefits: context preservation, resumability, specialized expertise
  - Include in feature list if appropriate

### Quality Checks
- [ ] Run `claude --plugin-dir .` to verify plugin loads without errors
- [ ] Verify agent frontmatter is valid YAML
- [ ] Check that agent description includes trigger conditions
- [ ] Ensure system prompt follows best practices from plugin-dev patterns
- [ ] Self-review for code quality and documentation clarity

### Testing
- [ ] Test with a complex issue requiring deep codebase analysis
- [ ] Verify agent is invoked from issue-setup Phase 2
- [ ] Check that agent reads project CLAUDE.md
- [ ] Confirm analysis output includes proper structure
- [ ] Validate resumability by testing multi-iteration refinement

### Documentation
- [ ] Update README.md with agent documentation
- [ ] Add inline comments in agent system prompt for complex sections (if needed)

## Technical Notes

### Architecture Considerations

**Agent Directory Structure:**
- Location: `agents/scratchpad-planner.md`
- Currently only `.gitkeep` in agents/ - this will be the first agent
- Sets pattern for future agents in muleteer

**Integration Architecture:**
- Invoked via Skill tool from issue-setup Phase 2
- Replaces generic Explore agent (Task tool with subagent_type=Explore)
- Should be resumable using agent ID from previous invocations
- Must read project CLAUDE.md to apply conventions

**Tool Requirements:**
- Read: Access CLAUDE.md, existing code, documentation
- Glob: Find files by pattern (e.g., "*.ts", "src/**/*.js")
- Grep: Search code for patterns, keywords
- Bash: Run read-only commands (git log, ls, etc.)
- LSP: Navigate code (goToDefinition, findReferences)

### Implementation Approach

**Phase 1: Create Agent File**
1. Define frontmatter with proper metadata
2. Start with minimal system prompt
3. Test plugin loads correctly

**Phase 2: Develop System Prompt**
Focus on these capabilities in order of priority:
1. **Read project conventions** - Parse CLAUDE.md for module structure, emojis, patterns
2. **Analyze architecture** - Identify affected modules, integration points
3. **Find similar patterns** - Use Grep, LSP to locate existing implementations
4. **Propose approach** - Generate atomic task breakdown
5. **Interactive refinement** - Ask clarifying questions, iterate on feedback
6. **Resumability** - Support being resumed with full context

Use imperative voice, focus on actions to take.

**Phase 3: Update Integration Points**
1. Modify issue-setup Phase 2 to invoke the agent
2. Pass necessary context (issue details, repo info)
3. Document expected outputs

**Phase 4: Document and Test**
1. Add to README.md
2. Test with actual complex issue
3. Verify all acceptance criteria met

### Potential Challenges

**System Prompt Complexity:**
- Need to balance detailed methodology with conciseness
- Must avoid over-engineering for first version
- Should follow progressive disclosure pattern

**Integration with issue-setup:**
- Need to pass right amount of context without overwhelming
- Agent should work autonomously but also support interaction
- Resumability requires proper agent ID handling

**Project Convention Awareness:**
- Agent must dynamically read each project's CLAUDE.md
- Can't hardcode muleteer-specific patterns
- Should work across different project types

### Questions/Blockers

### Clarifications Needed
(none - all resolved)

### Blocked By
(none)

### Assumptions Made

1. **First Agent Sets Pattern**: This is the first agent in muleteer, so it sets the precedent
2. **Skill Tool Invocation**: Agents can be invoked via Skill tool (similar to skills)
3. **Agent ID Resumability**: Claude Code's agent system supports resumption via agent IDs
4. **Project CLAUDE.md Access**: Agent can use Read tool to access any project's CLAUDE.md

### Decisions Made

**2026-01-01 - Setup Phase**

**Q: How detailed should the scratchpad-planner agent's system prompt be?**
**A:** Focused methodology (1000-1500 words)
**Rationale:** Balances guidance with flexibility. Provides core principles and methodology with key examples. Good starting point that can be refined based on usage.

**Q: Should the scratchpad-planner agent always be invoked in issue-setup, or only for complex issues?**
**A:** Always invoke (replace Explore entirely)
**Rationale:** Provides consistent experience and specialized expertise for all issues. Simplifies issue-setup logic by removing conditional branching.

**Q: How should iterative refinement work when the agent analyzes the codebase?**
**A:** Agent loops internally
**Rationale:** Agent drafts analysis, self-reviews, asks clarifying questions, and iterates until satisfied before presenting final version. Provides most autonomous and polished experience.

## Work Log

### 2026-01-01 - Issue Setup
- Fetched issue #14 from fusupo/muleteer
- Analyzed codebase using Explore agent
- Identified integration points in issue-setup skill Phase 2
- Created implementation plan with 4 atomic tasks
- Ready for clarifying questions and implementation

---
**Generated:** 2026-01-01
**By:** Issue Setup Skill
**Source:** https://github.com/fusupo/muleteer/issues/14
