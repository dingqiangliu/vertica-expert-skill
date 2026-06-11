#!/bin/bash

# ==============================================================================
# Vertica Expert Skill - Uninstallation Script
# ==============================================================================
#
# This script uninstalls the Vertica Expert skill from Claude Code.
# It removes all installed files and cleans up the installation directory.
#
# Usage: ./uninstall.sh [claude_path]
#   claude_path: Optional. Custom Claude installation directory (default: ~/.claude)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=============================================================================="
echo "🗑️  Vertica Expert Skill - Uninstallation"
echo "=============================================================================="

# Determine installation path
if [ -z "$1" ]; then
    CLAUDE_PATH="$HOME/.claude"
else
    CLAUDE_PATH="$1"
fi

SKILL_NAME="vertica-expert"
SKILL_INSTALL_PATH="$CLAUDE_PATH/skills/$SKILL_NAME"

# Agent installation path
AGENT_INSTALL_PATH="$CLAUDE_PATH/agents/$SKILL_NAME"

# Check if skill is installed
if [ ! -d "$SKILL_INSTALL_PATH" ]; then
    echo -e "${YELLOW}⚠ Skill not found at: $SKILL_INSTALL_PATH${NC}"
    echo "Checking common installation locations..."

    # Check if running from within the skill directory
    if [ -f "SKILL.md" ] && [ -f "CLAUDE.md" ]; then
        CURRENT_DIR=$(pwd)
        echo -e "${YELLOW}⚠ Found skill files in current directory: $CURRENT_DIR${NC}"
        echo "This appears to be the source directory, not an installation."
        echo "To uninstall an installed skill, run this script from the installation directory."
        exit 1
    fi

    echo -e "${RED}❌ Skill not installed in any known location${NC}"
    exit 1
fi

echo -e "📁 Found installed skill at: ${YELLOW}$SKILL_INSTALL_PATH${NC}"

# Check if agents are installed
AGENTS_INSTALLED=false
if [ -d "$AGENT_INSTALL_PATH" ]; then
    AGENTS_INSTALLED=true
    echo -e "🤖 Found installed agents at: ${YELLOW}$AGENT_INSTALL_PATH${NC}"
fi

# Show what will be removed
echo -e "\n📋 Files to be removed:"
ls -la "$SKILL_INSTALL_PATH/" 2>/dev/null | head -10 || echo "   (Unable to list files)"

if [ "$AGENTS_INSTALLED" = true ]; then
    echo -e "\n🤖 Agent files to be removed:"
    ls -la "$AGENT_INSTALL_PATH/" 2>/dev/null | head -10 || echo "   (Unable to list agent files)"
fi

# Confirm uninstallation
read -p "\nAre you sure you want to uninstall the Vertica Expert skill? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}❌ Uninstallation cancelled${NC}"
    exit 0
fi

# Backup option
read -p "Create backup before uninstalling? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    BACKUP_DIR="$HOME/.claude/backups"
    mkdir -p "$BACKUP_DIR"
    BACKUP_NAME="vertica-expert-$(date +%Y%m%d-%H%M%S)"
    echo -e "📦 Creating backup: ${YELLOW}$BACKUP_DIR/$BACKUP_NAME${NC}"
    cp -r "$SKILL_INSTALL_PATH" "$BACKUP_DIR/$BACKUP_NAME"
    if [ "$AGENTS_INSTALLED" = true ]; then
        cp -r "$AGENT_INSTALL_PATH" "$BACKUP_DIR/$BACKUP_NAME/agents"
    fi
    echo -e "${GREEN}✓ Backup created${NC}"
fi

# Remove the skill directory
echo -e "\n🗑️  Removing skill files..."
rm -rf "$SKILL_INSTALL_PATH"

# Verify removal
if [ ! -d "$SKILL_INSTALL_PATH" ]; then
    echo -e "${GREEN}✅ Skill successfully uninstalled${NC}"
else
    echo -e "${RED}❌ Failed to remove skill directory${NC}"
    exit 1
fi

# Remove agent files if they exist
if [ "$AGENTS_INSTALLED" = true ]; then
    echo -e "\n🗑️  Removing agent files..."
    rm -rf "$AGENT_INSTALL_PATH"

    # Verify agent removal
    if [ ! -d "$AGENT_INSTALL_PATH" ]; then
        echo -e "${GREEN}✅ Agent files successfully uninstalled${NC}"
    else
        echo -e "${RED}❌ Failed to remove agent directory${NC}"
        exit 1
    fi
fi

# Clean up empty parent directory if it's empty
PARENT_DIR="$CLAUDE_PATH/skills"
if [ -d "$PARENT_DIR" ] && [ -z "$(ls -A "$PARENT_DIR" 2>/dev/null)" ]; then
    echo -e "🧹 Cleaning up empty parent directory..."
    rmdir "$PARENT_DIR"
fi

echo -e "\n🎉 Uninstallation Complete!"
echo "=============================================================================="
echo "The Vertica Expert skill has been successfully removed."
echo ""
echo "📝 Summary:"
echo "   • Skill files removed from: $SKILL_INSTALL_PATH"
if [ "$AGENTS_INSTALLED" = true ]; then
    echo "   • Agent files removed from: $AGENT_INSTALL_PATH"
fi
if [[ "$BACKUP_NAME" ]]; then
    echo "   • Backup created at: $BACKUP_DIR/$BACKUP_NAME"
fi
echo ""
echo "ℹ️  Note: This only removes the skill files. Your Claude Code"
echo "    configuration remains unchanged."
echo "=============================================================================="
