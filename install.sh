#!/bin/bash

# ==============================================================================
# Vertica Expert Skill - Installation Script
# ==============================================================================
#
# This script installs the Vertica Expert skill for Claude Code.
# It sets up all necessary files and validates the installation.
#
# Usage: ./install.sh [claude_path]
#   claude_path: Optional. Custom Claude installation directory (default: ~/.claude)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=============================================================================="
echo "🔧 Vertica Expert Skill - Installation"
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

# Validate current directory
if [ ! -f "SKILL.md" ] || [ ! -f "CLAUDE.md" ]; then
    echo -e "${RED}❌ Error: Must run installation from the skill directory containing SKILL.md and CLAUDE.md${NC}"
    exit 1
fi

echo -e "📁 Installation path: ${YELLOW}$SKILL_INSTALL_PATH${NC}"
echo -e "🤖 Agent path: ${YELLOW}$AGENT_INSTALL_PATH${NC}"

# Create installation directory
echo -e "\n📂 Creating installation directory..."
mkdir -p "$SKILL_INSTALL_PATH"

# Copy skill files (excluding CLAUDE.md, examples/, slides/, uninstall.sh - not needed for users)
echo -e "📋 Copying skill files..."
cp -r references "$SKILL_INSTALL_PATH/"
cp SKILL.md "$SKILL_INSTALL_PATH/"
cp README.md "$SKILL_INSTALL_PATH/"
cp install.sh "$SKILL_INSTALL_PATH/"

# Install agent files
if [ -d "agents" ]; then
    echo -e "\n🤖 Installing agent files..."
    mkdir -p "$AGENT_INSTALL_PATH"
    cp agents/*.md "$AGENT_INSTALL_PATH/"
    echo -e "${GREEN}✓ Agent files installed${NC}"
fi

# Validate installation
echo -e "\n✅ Validating installation..."
if [ -f "$SKILL_INSTALL_PATH/SKILL.md" ]; then
    echo -e "${GREEN}✓ Core skill files installed${NC}"
else
    echo -e "${RED}❌ Core skill files missing${NC}"
    exit 1
fi

if [ -d "$SKILL_INSTALL_PATH/references" ]; then
    echo -e "${GREEN}✓ Reference directory installed${NC}"
else
    echo -e "${RED}❌ Reference directory missing${NC}"
    exit 1
fi

if [ -d "$AGENT_INSTALL_PATH" ]; then
    echo -e "${GREEN}✓ Agent directory installed${NC}"
else
    echo -e "${YELLOW}⚠ Agent directory not created${NC}"
fi

echo -e "\n🎉 Installation Complete!"
echo "=============================================================================="
echo -e "📍 Skill installed to: ${GREEN}$SKILL_INSTALL_PATH${NC}"
echo -e "🤖 Agents installed to: ${GREEN}$AGENT_INSTALL_PATH${NC}"
echo ""
echo "📋 Installed components:"
echo "   • Main skill definition (SKILL.md)"
echo "   • Reference guides"
echo "   • Agent configurations (requester.md, migrator.md, tester.md)"
echo ""
echo "🚀 Usage:"
echo "   • Ask Claude to convert SQL queries to Vertica"
echo "   • Request migration guidance for stored procedures"
echo "   • Get optimization recommendations for queries"
echo ""
echo "📚 Documentation:"
echo "   • README.md - Overview and getting started"
echo "   • references/ - Detailed technical guides"
echo "   • agents/*.md - Agent system prompts"
echo "=============================================================================="

# Create uninstall script in skill installation directory
cat > "$SKILL_INSTALL_PATH/uninstall.sh" << 'EOF'
#!/bin/bash

# ==============================================================================
# Vertica Expert Skill - Uninstallation Script
# ==============================================================================
#
# This script uninstalls the Vertica Expert skill from Claude Code.
# It removes all installed files including agent configurations.
#
# Usage: ./uninstall.sh
#   Must be run from the skill installation directory

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=============================================================================="
echo "🗑️  Vertica Expert Skill - Uninstallation"
echo "=============================================================================="

# Determine paths from current location
SKILL_INSTALL_PATH="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_PATH="$(dirname "$(dirname "$SKILL_INSTALL_PATH")")"
SKILL_NAME="$(basename "$SKILL_INSTALL_PATH")"
AGENT_INSTALL_PATH="$CLAUDE_PATH/agents/$SKILL_NAME"

echo -e "📁 Skill directory: ${YELLOW}$SKILL_INSTALL_PATH${NC}"

# Check if agents are installed
AGENTS_INSTALLED=false
if [ -d "$AGENT_INSTALL_PATH" ]; then
    AGENTS_INSTALLED=true
    echo -e "🤖 Agent directory: ${YELLOW}$AGENT_INSTALL_PATH${NC}"
fi

# Confirm uninstallation
read -p "\nAre you sure you want to uninstall $SKILL_NAME? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}❌ Uninstallation cancelled${NC}"
    exit 0
fi

# Remove the skill directory
echo -e "\n🗑️  Removing skill files..."
rm -rf "$SKILL_INSTALL_PATH"

# Remove agent files if they exist
if [ "$AGENTS_INSTALLED" = true ]; then
    echo -e "🗑️  Removing agent files..."
    rm -rf "$AGENT_INSTALL_PATH"
    echo -e "${GREEN}✅ Agent files removed${NC}"
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
echo "=============================================================================="
EOF

chmod +x "$SKILL_INSTALL_PATH/uninstall.sh"
echo -e "🔧 Uninstall script created: ${YELLOW}$SKILL_INSTALL_PATH/uninstall.sh${NC}"

# Verify the skill can be detected
echo -e "\n🔍 Verifying skill detection..."
if [ -f "$SKILL_INSTALL_PATH/SKILL.md" ]; then
    SKILL_NAME_FROM_FILE=$(grep -m 1 "^name:" "$SKILL_INSTALL_PATH/SKILL.md" | cut -d' ' -f2)
    if [ "$SKILL_NAME_FROM_FILE" = "vertica-expert" ]; then
        echo -e "${GREEN}✓ Skill properly configured${NC}"
    else
        echo -e "${YELLOW}⚠ Skill name mismatch detected${NC}"
    fi
fi

echo ""
echo "✨ Installation successful! The Vertica Expert skill is ready to use."
