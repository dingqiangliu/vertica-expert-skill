#!/bin/bash

# ==============================================================================
# Vertica Expert Skill - Installation Script
# ==============================================================================
#
# This script installs the Vertica Expert skill for Claude Code.
# It sets up all necessary files and validates the installation.
#
# Usage: ./install.sh [install_path]
#   install_path: Optional. Custom installation directory (default: ~/.claude/plugins)

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
    INSTALL_PATH="$HOME/.claude/skills"
else
    INSTALL_PATH="$1"
fi

SKILL_NAME="vertica-expert"
SKILL_PATH="$INSTALL_PATH/$SKILL_NAME"

# Validate current directory
if [ ! -f "SKILL.md" ] || [ ! -f "CLAUDE.md" ]; then
    echo -e "${RED}❌ Error: Must run installation from the skill directory containing SKILL.md and CLAUDE.md${NC}"
    exit 1
fi

echo -e "📁 Installation path: ${YELLOW}$SKILL_PATH${NC}"

# Create installation directory
echo -e "\n📂 Creating installation directory..."
mkdir -p "$SKILL_PATH"

# Copy skill files (excluding CLAUDE.md, examples/, slides/ - not needed for users)
echo -e "📋 Copying skill files..."
cp -r references "$SKILL_PATH/"
cp SKILL.md "$SKILL_PATH/"
cp README.md "$SKILL_PATH/"
cp install.sh "$SKILL_PATH/"
cp uninstall.sh "$SKILL_PATH/"

# No scripts to make executable

# Validate installation
echo -e "\n✅ Validating installation..."
if [ -f "$SKILL_PATH/SKILL.md" ]; then
    echo -e "${GREEN}✓ Core skill files installed${NC}"
else
    echo -e "${RED}❌ Core skill files missing${NC}"
    exit 1
fi

if [ -d "$SKILL_PATH/references" ]; then
    echo -e "${GREEN}✓ Reference directory installed${NC}"
else
    echo -e "${RED}❌ Reference directory missing${NC}"
    exit 1
fi

# No scripts to test

echo -e "\n🎉 Installation Complete!"
echo "=============================================================================="
echo -e "📍 Skill installed to: ${GREEN}$SKILL_PATH${NC}"
echo ""
echo "📋 Installed components:"
echo "   • Main skill definition (SKILL.md)"
echo "   • Reference guides"
echo ""
echo "🚀 Usage:"
echo "   • Ask Claude to convert SQL queries to Vertica"
echo "   • Request migration guidance for stored procedures"
echo "   • Get optimization recommendations for queries"
echo ""
echo "📚 Documentation:"
echo "   • README.md - Overview and getting started"
echo "   • references/ - Detailed technical guides"
echo "=============================================================================="

# Create a simple uninstall script
cat > "$SKILL_PATH/uninstall.sh" << 'EOF'
#!/bin/bash
# Vertica Expert Skill - Uninstallation Script

echo "Uninstalling Vertica Expert skill..."
INSTALL_PATH="$(cd "$(dirname "$0")" && pwd)"
SKILL_PATH="$(dirname "$INSTALL_PATH")"
SKILL_NAME="$(basename "$INSTALL_PATH")"

read -p "Are you sure you want to uninstall $SKILL_NAME? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf "$INSTALL_PATH"
    echo "✅ Skill uninstalled successfully"
else
    echo "❌ Uninstallation cancelled"
fi
EOF

chmod +x "$SKILL_PATH/uninstall.sh"

echo -e "🔧 Uninstall script created: ${YELLOW}$SKILL_PATH/uninstall.sh${NC}"

# Verify the skill can be detected
echo -e "\n🔍 Verifying skill detection..."
if [ -f "$SKILL_PATH/SKILL.md" ]; then
    SKILL_NAME_FROM_FILE=$(grep -m 1 "^name:" "$SKILL_PATH/SKILL.md" | cut -d' ' -f2)
    if [ "$SKILL_NAME_FROM_FILE" = "vertica-expert" ]; then
        echo -e "${GREEN}✓ Skill properly configured${NC}"
    else
        echo -e "${YELLOW}⚠ Skill name mismatch detected${NC}"
    fi
fi

echo ""
echo "✨ Installation successful! The Vertica Expert skill is ready to use."
