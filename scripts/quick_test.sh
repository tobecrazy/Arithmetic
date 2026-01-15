#!/bin/bash

# ==============================================================================
# Quick Test Script - Fast Unit Tests Only
# ==============================================================================
# This script runs only unit tests for quick feedback during development.
# Skips UI tests and localization checks for faster execution.
#
# Usage:
#   ./scripts/quick_test.sh
#
# ==============================================================================

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT="Arithmetic.xcodeproj"
SCHEME="Arithmetic"

echo -e "${BLUE}=============================================${NC}"
echo -e "${BLUE}Quick Unit Tests - Arithmetic App${NC}"
echo -e "${BLUE}=============================================${NC}\n"

# Build and test
if xcodebuild test \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -destination 'platform=iOS Simulator,name=Any iOS Simulator Device' \
    -only-testing:ArithmeticTests \
    | grep -E "(Test Suite|Test Case|passed|failed|BUILD)" \
    ; then
    echo -e "\n${GREEN}✓ Quick tests passed!${NC}\n"
    exit 0
else
    echo -e "\n${RED}✗ Quick tests failed${NC}\n"
    exit 1
fi
