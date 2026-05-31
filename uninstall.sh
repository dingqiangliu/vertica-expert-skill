#!/bin/bash

# ==============================================================================
# Vertica Expert Skill - Uninstallation Script
# ==============================================================================
#
# This script uninstalls the Vertica Expert skill from Claude Code.
# It removes all installed files and cleans up the installation directory.
#
# Usage: ./uninstall.sh [install_path]
#   install_path: Optional. Custom installation directory (default: ~/.claude/plugins)

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
    INSTALL_PATH="$HOME/.claude/skills"
else
    INSTALL_PATH="$1"
fi

SKILL_NAME="vertica-expert"
SKILL_PATH="$INSTALL_PATH/$SKILL_NAME"

# Check if skill is installed
if [ ! -d "$SKILL_PATH" ]; then
    echo -e "${YELLOW}⚠ Skill not found at: $SKILL_PATH${NC}"
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

echo -e "📁 Found installed skill at: ${YELLOW}$SKILL_PATH${NC}"

# Show what will be removed
echo -e "\n📋 Files to be removed:"
ls -la "$SKILL_PATH/" 2>/dev/null | head -10 || echo "   (Unable to list files)"

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
    cp -r "$SKILL_PATH" "$BACKUP_DIR/$BACKUP_NAME"
    echo -e "${GREEN}✓ Backup created${NC}"
fi

# Remove the skill directory
echo -e "\n🗑️  Removing skill files..."
rm -rf "$SKILL_PATH"

# Verify removal
if [ ! -d "$SKILL_PATH" ]; then
    echo -e "${GREEN}✅ Skill successfully uninstalled${NC}"
else
    echo -e "${RED}❌ Failed to remove skill directory${NC}"
    exit 1
fi

# Clean up empty parent directory if it's empty
PARENT_DIR="$INSTALL_PATH"
if [ -d "$PARENT_DIR" ] && [ -z "$(ls -A "$PARENT_DIR" 2>/dev/null)" ]; then
    echo -e "🧹 Cleaning up empty parent directory..."
    rmdir "$PARENT_DIR"
fi

echo -e "\n🎉 Uninstallation Complete!"
echo "=============================================================================="
echo "The Vertica Expert skill has been successfully removed."
echo ""
echo "📝 Summary:"
echo "   • Skill files removed from: $SKILL_PATH"
if [[ "$BACKUP_NAME" ]]; then
    echo "   • Backup created at: $BACKUP_DIR/$BACKUP_NAME"
fi
echo ""
echo "ℹ️  Note: This only removes the skill files. Your Claude Code"
echo "    configuration remains unchanged."
echo "=============================================================================="