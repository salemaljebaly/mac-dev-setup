#!/usr/bin/env bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Running comprehensive code quality checks...${NC}"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required tools
MISSING_TOOLS=()
for tool in nixfmt statix deadnix; do
    if ! command_exists "$tool"; then
        MISSING_TOOLS+=("$tool")
    fi
done

if [ ${#MISSING_TOOLS[@]} -ne 0 ]; then
    echo -e "${YELLOW}⚠️  Missing tools: ${MISSING_TOOLS[*]}${NC}"
    echo "Run 'nix develop' to enter development shell with all tools."
    exit 1
fi

# Format check
echo -e "${BLUE}1. Checking formatting...${NC}"
if find . -name "*.nix" -type f -not -path "./result/*" -exec nixfmt --check {} \; > /dev/null 2>&1; then
    echo -e "${GREEN}   ✅ Format check passed${NC}"
else
    echo -e "${RED}   ❌ Format check failed${NC}"
    echo "   Run 'make format' to fix"
    exit 1
fi

# Statix check
echo -e "${BLUE}2. Running statix...${NC}"
if statix check . > /dev/null 2>&1; then
    echo -e "${GREEN}   ✅ Statix check passed${NC}"
else
    echo -e "${YELLOW}   ⚠️  Statix found issues${NC}"
    statix check . || true
fi

# Deadnix check
echo -e "${BLUE}3. Running deadnix...${NC}"
DEADNIX_OUTPUT=$(deadnix . 2>&1 || true)
if [ -z "$DEADNIX_OUTPUT" ]; then
    echo -e "${GREEN}   ✅ No dead code found${NC}"
else
    echo -e "${YELLOW}   ⚠️  Dead code found:${NC}"
    echo "$DEADNIX_OUTPUT"
fi

# Flake check
echo -e "${BLUE}4. Checking flake...${NC}"
if nix flake check --no-build > /dev/null 2>&1; then
    echo -e "${GREEN}   ✅ Flake check passed${NC}"
else
    echo -e "${RED}   ❌ Flake check failed${NC}"
    nix flake check --no-build
    exit 1
fi

echo ""
echo -e "${GREEN}✅ All checks completed!${NC}"