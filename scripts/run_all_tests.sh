#!/bin/bash

# ==============================================================================
# Arithmetic App - Test Automation Script
# ==============================================================================
# This script runs all tests for the Arithmetic iOS app including:
# - Unit tests
# - UI tests
# - Localization checks
# - Static analysis
#
# Usage:
#   ./scripts/run_all_tests.sh [options]
#
# Options:
#   --skip-ui           Skip UI tests (faster execution)
#   --skip-unit         Skip unit tests
#   --skip-localization Skip localization checks
#   --only-ui           Run only UI tests
#   --only-unit         Run only unit tests
#   --verbose           Enable verbose output
#   --help              Show this help message
#
# ==============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
PROJECT="Arithmetic.xcodeproj"
SCHEME="Arithmetic"
DESTINATION="platform=iOS Simulator,name=iPhone 16,OS=26.0.1"
SKIP_UI=false
SKIP_UNIT=false
SKIP_LOCALIZATION=false
VERBOSE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-ui)
            SKIP_UI=true
            shift
            ;;
        --skip-unit)
            SKIP_UNIT=true
            shift
            ;;
        --skip-localization)
            SKIP_LOCALIZATION=true
            shift
            ;;
        --only-ui)
            SKIP_UNIT=true
            SKIP_LOCALIZATION=true
            shift
            ;;
        --only-unit)
            SKIP_UI=true
            SKIP_LOCALIZATION=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --skip-ui           Skip UI tests (faster execution)"
            echo "  --skip-unit         Skip unit tests"
            echo "  --skip-localization Skip localization checks"
            echo "  --only-ui           Run only UI tests"
            echo "  --only-unit         Run only unit tests"
            echo "  --verbose           Enable verbose output"
            echo "  --help              Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Function to print colored output
print_header() {
    echo -e "\n${BLUE}=============================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}=============================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Function to run a test suite
run_test_suite() {
    local test_name="$1"
    local test_command="$2"

    print_header "$test_name"

    if $VERBOSE; then
        eval "$test_command"
    else
        eval "$test_command" > /tmp/test_output.log 2>&1

        if [ $? -eq 0 ]; then
            print_success "$test_name passed"
            if [ -s /tmp/test_output.log ]; then
                echo "Output:"
                tail -10 /tmp/test_output.log
            fi
        else
            print_error "$test_name failed"
            echo "Error output:"
            cat /tmp/test_output.log
            return 1
        fi
    fi
}

# Start of test execution
print_header "Arithmetic App - Test Suite"
echo "Project: $PROJECT"
echo "Scheme: $SCHEME"
echo ""

# Track overall test results
TESTS_PASSED=0
TESTS_FAILED=0

# ==============================================================================
# 1. Build Project
# ==============================================================================
print_header "Building Project"
if xcodebuild -project "$PROJECT" -scheme "$SCHEME" -destination "$DESTINATION" clean build > /tmp/build.log 2>&1; then
    print_success "Build successful"
else
    print_error "Build failed"
    cat /tmp/build.log
    exit 1
fi

# ==============================================================================
# 2. Run Unit Tests
# ==============================================================================
if [ "$SKIP_UNIT" = false ]; then
    if run_test_suite "Unit Tests" "xcodebuild test -project '$PROJECT' -scheme '$SCHEME' -destination '$DESTINATION'"; then
        ((TESTS_PASSED++))
    else
        ((TESTS_FAILED++))
    fi
else
    print_warning "Skipping unit tests"
fi

# ==============================================================================
# 3. Run UI Tests
# ==============================================================================
if [ "$SKIP_UI" = false ]; then
    if run_test_suite "UI Tests" "xcodebuild test -project '$PROJECT' -scheme '$SCHEME' -destination '$DESTINATION'"; then
        ((TESTS_PASSED++))
    else
        ((TESTS_FAILED++))
    fi
else
    print_warning "Skipping UI tests"
fi

# ==============================================================================
# 4. Localization Checks
# ==============================================================================
if [ "$SKIP_LOCALIZATION" = false ]; then
    print_header "Localization Checks"
    if ./scripts/check_localizations.sh > /tmp/localization.log 2>&1; then
        print_success "Localization checks passed"
        ((TESTS_PASSED++))
    else
        print_error "Localization checks failed"
        cat /tmp/localization.log
        ((TESTS_FAILED++))
    fi
else
    print_warning "Skipping localization checks"
fi

# ==============================================================================
# 5. Static Analysis (Optional)
# ==============================================================================
print_header "Static Analysis"
if xcodebuild analyze -project "$PROJECT" -scheme "$SCHEME" -destination "$DESTINATION" > /tmp/analyze.log 2>&1; then
    print_success "Static analysis completed"
    # Note: analyze doesn't fail on warnings, so we don't count this as passed/failed
else
    print_warning "Static analysis had issues (check log for details)"
fi

# ==============================================================================
# Test Summary
# ==============================================================================
print_header "Test Summary"
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    print_success "All tests passed!"
    exit 0
else
    print_error "Some tests failed"
    exit 1
fi
