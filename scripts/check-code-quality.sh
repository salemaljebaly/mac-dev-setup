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

# Find all Nix files
NIX_FILES=$(find . -name "*.nix" -type f ! -path "./result*" ! -path "./.git/*" 2>/dev/null)
FILE_COUNT=$(echo "$NIX_FILES" | wc -l | tr -d ' ')

echo "Found $FILE_COUNT Nix files to check"
echo ""

# Format check
echo -e "${BLUE}1. Checking formatting...${NC}"
FAILED=0
for file in $NIX_FILES; do
    if ! nixfmt --check "$file" >/dev/null 2>&1; then
        echo -e "${RED}   ❌ $file needs formatting${NC}"
        FAILED=1
    fi
done

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}   ✅ All files properly formatted${NC}"
else
    echo -e "${RED}   Run 'make format' to fix formatting${NC}"
fi

# Statix check
echo -e "${BLUE}2. Running statix...${NC}"
if statix check . >/dev/null 2>&1; then
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
if nix flake check --no-build >/dev/null 2>&1; then
    echo -e "${GREEN}   ✅ Flake check passed${NC}"
else
    echo -e "${RED}   ❌ Flake check failed${NC}"
    nix flake check --no-build
    exit 1
fi

echo ""
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All checks completed successfully!${NC}"
else
    echo -e "${RED}❌ Some checks failed!${NC}"
    exit 1
fi