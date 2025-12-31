#!/bin/bash
# Install Muleteer Claude Code workflow into ~/.claude/

set -e  # Exit on error

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "🔧 Installing Muleteer workflow..."

# Create ~/.claude structure if it doesn't exist
mkdir -p ~/.claude/{agents,skills}

# Clean up old command symlinks from previous Muleteer versions
# (Commands have been converted to skills)
if [ -d ~/.claude/commands ]; then
    echo "🧹 Cleaning up old command symlinks..."
    for old_cmd in ~/.claude/commands/{commit,open-pr,pr-review,start-work,archive-dev,prime-session}.md; do
        if [ -L "$old_cmd" ]; then
            rm "$old_cmd"
            echo "  ✓ Removed old command: $(basename "$old_cmd")"
        fi
    done
fi

# Symlink skills
echo "🎯 Installing skills..."
if [ -d "$SCRIPT_DIR/skills" ]; then
    for skill_dir in "$SCRIPT_DIR"/skills/*/; do
        skill_name=$(basename "$skill_dir")
        target=~/.claude/skills/"$skill_name"

        # Remove existing symlink/directory if it exists
        if [ -L "$target" ] || [ -d "$target" ]; then
            rm -rf "$target"
        fi

        ln -s "$skill_dir" "$target"
        echo "  ✓ Linked skill: $skill_name"
    done
fi

# Symlink agents
echo "🤖 Installing agents..."
if [ -d "$SCRIPT_DIR/agents" ]; then
    for agent in "$SCRIPT_DIR"/agents/*.md; do
        if [ -f "$agent" ]; then
            agent_name=$(basename "$agent")
            target=~/.claude/agents/"$agent_name"

            # Remove existing symlink if it exists
            [ -L "$target" ] && rm "$target"

            ln -sf "$agent" "$target"
            echo "  ✓ Linked agent: $agent_name"
        fi
    done
fi

# Install scripts
echo "📜 Installing scripts..."
if [ -d "$SCRIPT_DIR/scripts" ]; then
    for script in "$SCRIPT_DIR"/scripts/*.sh; do
        if [ -f "$script" ]; then
            chmod +x "$script"
            echo "  ✓ Made executable: $(basename "$script")"
        fi
    done
fi

# Configure hooks in settings.json
echo "🪝 Configuring hooks..."
SETTINGS_FILE=~/.claude/settings.json

# Create settings.json if it doesn't exist
if [ ! -f "$SETTINGS_FILE" ]; then
    echo "{}" > "$SETTINGS_FILE"
fi

# Check if PreCompact hook is already configured
if command -v jq &> /dev/null; then
    if ! jq -e '.hooks.PreCompact' "$SETTINGS_FILE" > /dev/null 2>&1; then
        # Add PreCompact hook using jq (need both manual and auto matchers)
        HOOK_CONFIG='{
          "hooks": {
            "PreCompact": [
              {
                "matcher": "manual",
                "hooks": [
                  {
                    "type": "command",
                    "command": "~/.muleteer/scripts/archive-session-log.sh",
                    "timeout": 60
                  }
                ]
              },
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
        }'

        # Merge hook config into existing settings
        jq --argjson hook "$HOOK_CONFIG" '. * $hook' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && \
            mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
        echo "  ✓ Added PreCompact hook for session archiving"
    else
        echo "  ℹ PreCompact hook already configured (skipped)"
    fi
else
    echo "  ⚠ jq not found - please manually add hook from templates/hooks-config.json"
fi

# Handle CLAUDE.md
echo "📝 Installing Muleteer context..."
if [ -f "$SCRIPT_DIR/CLAUDE-MULETEER.md" ]; then
    # If ~/.claude/CLAUDE.md doesn't exist, create it
    if [ ! -f ~/.claude/CLAUDE.md ]; then
        touch ~/.claude/CLAUDE.md
        echo "# Claude Configuration" > ~/.claude/CLAUDE.md
        echo "" >> ~/.claude/CLAUDE.md
    fi

    # Check if Muleteer context is already included
    if ! grep -q "## Muleteer Workflow Context" ~/.claude/CLAUDE.md 2>/dev/null; then
        echo "" >> ~/.claude/CLAUDE.md
        cat "$SCRIPT_DIR/CLAUDE-MULETEER.md" >> ~/.claude/CLAUDE.md
        echo "  ✓ Appended Muleteer context to CLAUDE.md"
    else
        echo "  ℹ Muleteer context already in CLAUDE.md (skipped)"
    fi
fi

echo ""
echo "✅ Muleteer workflow installed successfully!"
echo ""
echo "🎯 Available skills:"
[ -d "$SCRIPT_DIR/skills" ] && ls -1 "$SCRIPT_DIR"/skills/ | sed 's/^/   - /'
echo ""
echo "🤖 Available agents:"
[ -d "$SCRIPT_DIR/agents" ] && ls -1 "$SCRIPT_DIR"/agents/*.md 2>/dev/null | xargs -n1 basename | sed 's/.md$//' | sed 's/^/   - /' || echo "   (none yet - extensibility ready)"
echo ""
echo "💬 Skills are invoked via natural language:"
echo "   - \"Setup issue #42\"        → issue-setup skill"
echo "   - \"Commit these changes\"   → commit-changes skill"
echo "   - \"Create a PR\"            → create-pr skill"
echo "   - \"Start working on this\"  → work-session skill"
echo ""
echo "📜 Scripts available:"
[ -d "$SCRIPT_DIR/scripts" ] && ls -1 "$SCRIPT_DIR"/scripts/*.sh 2>/dev/null | xargs -n1 basename | sed 's/^/   - /' || echo "   (none)"
echo ""
echo "🪝 Session archiving:"
echo "   PreCompact hook auto-configured in ~/.claude/settings.json"
echo "   Run /compact to archive session logs before compaction"
echo "   Docs: ~/.muleteer/docs/SESSION-ARCHIVING.md"
echo ""
echo "🚀 Start using: Open Claude Code in any project repo"
