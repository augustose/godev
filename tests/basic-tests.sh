#!/bin/zsh
#
# Basic tests for godev
# These tests verify basic functionality in readonly mode
#

set -e

# Colors for test output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GODEV_SCRIPT="$SCRIPT_DIR/../godev"

# Test function
test_command() {
    local test_name="$1"
    local command="$2"
    local expected_contains="${3:-}"
    
    echo -n "Testing: $test_name... "
    
    if output=$($command 2>&1); then
        if [[ -z "$expected_contains" ]] || [[ "$output" == *"$expected_contains"* ]]; then
            echo -e "${GREEN}✓ PASS${NC}"
            ((TESTS_PASSED++))
            return 0
        else
            echo -e "${RED}✗ FAIL${NC} (expected to contain: $expected_contains)"
            echo "  Output: $output"
            ((TESTS_FAILED++))
            return 1
        fi
    else
        echo -e "${RED}✗ FAIL${NC} (command failed)"
        echo "  Output: $output"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Run tests
echo "Running basic tests for godev..."
echo "=================================="
echo ""

# Help command tests
test_command "help command" "$GODEV_SCRIPT help" "godev"
test_command "help with -h" "$GODEV_SCRIPT -h" "godev"
test_command "help with --help" "$GODEV_SCRIPT --help" "godev"

# Version command tests
test_command "version command" "$GODEV_SCRIPT version" "version"
test_command "version with -v" "$GODEV_SCRIPT -v" "version"
test_command "version with --version" "$GODEV_SCRIPT --version" "version"

# Status command tests (basic)
test_command "status command" "$GODEV_SCRIPT status" "Project Activity Status"
test_command "status with help" "$GODEV_SCRIPT status -h" "godev status"

# Nav command tests (basic - readonly mode)
test_command "nav command help" "$GODEV_SCRIPT nav -h" "godev nav"

# List command (placeholder)
test_command "list command" "$GODEV_SCRIPT list" "being implemented"

# AI status command (placeholder)
test_command "ai-status command" "$GODEV_SCRIPT ai-status" "being implemented"

# Summary
echo ""
echo "=================================="
echo "Test Summary:"
echo -e "  ${GREEN}Passed: $TESTS_PASSED${NC}"
if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "  ${RED}Failed: $TESTS_FAILED${NC}"
    exit 1
else
    echo -e "  ${GREEN}Failed: $TESTS_FAILED${NC}"
    exit 0
fi

