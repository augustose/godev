#!/bin/zsh
#
# Script to increment build number before committing
# Usage: ./increment-build.sh
#

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GODEV_SCRIPT="$SCRIPT_DIR/godev"

if [[ ! -f "$GODEV_SCRIPT" ]]; then
    echo "Error: godev script not found at $GODEV_SCRIPT" >&2
    exit 1
fi

# Get current build number
CURRENT_BUILD=$(grep -E '^BUILD=' "$GODEV_SCRIPT" | sed 's/BUILD="\([0-9]*\)".*/\1/')

if [[ -z "$CURRENT_BUILD" ]]; then
    echo "Error: Could not find BUILD number in godev script" >&2
    exit 1
fi

# Increment build number
NEW_BUILD=$((CURRENT_BUILD + 1))

# Update build number in script
if [[ "$(uname)" == "Darwin" ]]; then
    # macOS
    sed -i '' "s/^BUILD=\"[0-9]*\"/BUILD=\"$NEW_BUILD\"/" "$GODEV_SCRIPT"
else
    # Linux
    sed -i "s/^BUILD=\"[0-9]*\"/BUILD=\"$NEW_BUILD\"/" "$GODEV_SCRIPT"
fi

echo "✓ Build number incremented: $CURRENT_BUILD → $NEW_BUILD"
echo "  Version will be: $(grep -E '^VERSION=' "$GODEV_SCRIPT" | sed 's/VERSION="\(.*\)".*/\1/')+build.$NEW_BUILD"

