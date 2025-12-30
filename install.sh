#!/bin/zsh
#
# godev Installation Script
# Installs godev to a directory in PATH
#

set -e

# Cleanup function for temp directory
cleanup() {
    if [[ -n "$TEMP_DIR" ]] && [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
}
trap cleanup EXIT

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Installation directory
INSTALL_DIR="${HOME}/.local/bin"
BIN_NAME="godev"

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}  ${GREEN}🚀 godev Installation${NC}                                    ${BLUE}║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check for ZSH
if [[ -z "$ZSH_VERSION" ]]; then
    echo -e "${RED}Error: This script requires ZSH${NC}"
    echo "Please run with: zsh install.sh"
    exit 1
fi

# Configuration file location
CONFIG_DIR="${HOME}/.config/godev"
CONFIG_FILE="${CONFIG_DIR}/config"

# Load configuration if it exists (for INSTALL_URL)
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
fi

# GitHub repository URL (fallback)
# Default official GitHub URL and command:
# curl -fsSL https://raw.githubusercontent.com/augustose/godev/main/install.sh | zsh
GITHUB_REPO="https://raw.githubusercontent.com/augustose/godev/main"

# Use INSTALL_URL from config if set, otherwise use GITHUB_REPO
INSTALL_REPO="${INSTALL_URL:-$GITHUB_REPO}"

# Initialize TEMP_DIR variable for cleanup
TEMP_DIR=""

# Determine if we're running from a piped curl command or local file
# When piped, $0 is usually "-zsh" or similar, not a file path
if [[ "$0" == -* ]] || [[ ! -f "$0" ]]; then
    # Running from piped curl - try to download from same source
    TEMP_DIR=$(mktemp -d)
    GODEV_SCRIPT="$TEMP_DIR/godev"
    
    # Try common local development server URLs first
    # Check if SCRIPT_SOURCE_URL is set (can be passed via env var)
    SOURCE_URL="${SCRIPT_SOURCE_URL:-}"
    
    # If not set, try to detect from common local server patterns
    if [[ -z "$SOURCE_URL" ]]; then
        # Common local development server URLs to try
        for local_url in "http://host.docker.internal:8000" "http://localhost:8000" "http://127.0.0.1:8000"; do
            if curl -fsSL --max-time 1 "$local_url/godev" -o /dev/null 2>/dev/null; then
                SOURCE_URL="$local_url"
                break
            fi
        done
    fi
    
    # Priority order:
    # 1. INSTALL_URL from config file (if set)
    # 2. Local server detection (if available)
    # 3. INSTALL_REPO (which defaults to GITHUB_REPO)
    
    # Try to download from local server if detected (unless INSTALL_URL is explicitly set)
    if [[ -n "$SOURCE_URL" ]] && [[ "$SOURCE_URL" != *"github.com"* ]] && [[ -z "$INSTALL_URL" ]]; then
        echo -e "${BLUE}Downloading godev script from local server ($SOURCE_URL)...${NC}"
        if curl -fsSL "$SOURCE_URL/godev" -o "$GODEV_SCRIPT" 2>/dev/null; then
            chmod +x "$GODEV_SCRIPT"
        else
            # Fallback to configured INSTALL_REPO
            echo -e "${YELLOW}Local server not available, downloading from configured source...${NC}"
            if ! curl -fsSL "$INSTALL_REPO/godev" -o "$GODEV_SCRIPT"; then
                echo -e "${RED}Error: Failed to download godev script${NC}"
                exit 1
            fi
            chmod +x "$GODEV_SCRIPT"
        fi
    else
        # Use INSTALL_REPO (from config or default GitHub)
        local source_name="GitHub"
        if [[ -n "$INSTALL_URL" ]]; then
            source_name="configured source"
        fi
        echo -e "${BLUE}Downloading godev script from $source_name...${NC}"
        if ! curl -fsSL "$INSTALL_REPO/godev" -o "$GODEV_SCRIPT"; then
            echo -e "${RED}Error: Failed to download godev script from $source_name${NC}"
            exit 1
        fi
        chmod +x "$GODEV_SCRIPT"
    fi
else
    # Running from local file - use local godev script
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    GODEV_SCRIPT="$SCRIPT_DIR/godev"
    
    # Check if godev script exists locally
    if [[ ! -f "$GODEV_SCRIPT" ]]; then
        echo -e "${RED}Error: godev script not found at $GODEV_SCRIPT${NC}"
        exit 1
    fi
fi

# Create install directory if it doesn't exist
if [[ ! -d "$INSTALL_DIR" ]]; then
    echo -e "${YELLOW}Creating installation directory: $INSTALL_DIR${NC}"
    mkdir -p "$INSTALL_DIR"
fi

# Function to extract version from script
get_version_from_script() {
    local script_path="$1"
    if [[ -f "$script_path" ]]; then
        # Try to get version by running the script
        local version_output=$("$script_path" version 2>/dev/null || echo "")
        if [[ -n "$version_output" ]]; then
            echo "$version_output" | sed 's/.*version //'
        else
            # Fallback: extract from script directly
            local version=$(grep -E '^VERSION=' "$script_path" 2>/dev/null | sed 's/VERSION="\(.*\)".*/\1/' || echo "")
            local build=$(grep -E '^BUILD=' "$script_path" 2>/dev/null | sed 's/BUILD="\(.*\)".*/\1/' || echo "")
            if [[ -n "$version" ]] && [[ -n "$build" ]]; then
                echo "${version}+build.${build}"
            elif [[ -n "$version" ]]; then
                echo "$version"
            fi
        fi
    fi
}

# Check if already installed
INSTALLED_VERSION=""
INSTALLED_FULL_VERSION=""
if [[ -f "$INSTALL_DIR/$BIN_NAME" ]]; then
    INSTALLED_FULL_VERSION=$(get_version_from_script "$INSTALL_DIR/$BIN_NAME")
    INSTALLED_VERSION=$(echo "$INSTALLED_FULL_VERSION" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "unknown")
    
    echo -e "${YELLOW}godev is already installed at $INSTALL_DIR/$BIN_NAME${NC}"
    if [[ -n "$INSTALLED_FULL_VERSION" ]]; then
        echo -e "  Installed version: ${BLUE}$INSTALLED_FULL_VERSION${NC}"
    fi
    
    # Get new version for comparison
    NEW_FULL_VERSION=$(get_version_from_script "$GODEV_SCRIPT")
    NEW_VERSION=$(echo "$NEW_FULL_VERSION" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "")
    
    if [[ -n "$NEW_FULL_VERSION" ]] && [[ -n "$INSTALLED_FULL_VERSION" ]]; then
        if [[ "$NEW_FULL_VERSION" != "$INSTALLED_FULL_VERSION" ]]; then
            echo -e "  Available version: ${GREEN}$NEW_FULL_VERSION${NC}"
            echo ""
            echo -e "${CYAN}An update is available!${NC}"
        else
            echo -e "  Available version: ${GRAY}$NEW_FULL_VERSION${NC} (same as installed)"
            echo ""
            echo -e "${GRAY}You already have the latest version.${NC}"
        fi
    fi
    
    echo ""
    # Check if running non-interactively (from pipe) and versions differ
    if [[ ! -t 0 ]] && [[ "$NEW_FULL_VERSION" != "$INSTALLED_FULL_VERSION" ]]; then
        # Non-interactive mode: auto-update if versions differ
        echo -e "${BLUE}Auto-updating to $NEW_FULL_VERSION (non-interactive mode)...${NC}"
        overwrite="y"
    else
        # Interactive mode: ask user
        read "?Do you want to update/overwrite it? (y/N): " overwrite
        if [[ "$overwrite" != "y" ]] && [[ "$overwrite" != "Y" ]]; then
            echo "Installation cancelled."
            exit 0
        fi
    fi
    
    if [[ "$overwrite" == "y" ]] || [[ "$overwrite" == "Y" ]]; then
        echo -e "${BLUE}Updating godev...${NC}"
    fi
fi

# Copy script
echo -e "${BLUE}Installing godev...${NC}"
cp "$GODEV_SCRIPT" "$INSTALL_DIR/$BIN_NAME"
chmod +x "$INSTALL_DIR/$BIN_NAME"

# Determine which URL was actually used for installation and save to config
# This allows future updates to use the same source
ACTUAL_INSTALL_URL=""
if [[ -n "$SOURCE_URL" ]] && [[ "$SOURCE_URL" != *"github.com"* ]] && [[ -z "$INSTALL_URL" ]]; then
    # Local server was detected and used (not from config)
    ACTUAL_INSTALL_URL="$SOURCE_URL"
elif [[ -z "$INSTALL_URL" ]]; then
    # GitHub was used (default) - don't save to config
    ACTUAL_INSTALL_URL=""
else
    # INSTALL_URL from config was used - already in config, no need to save again
    ACTUAL_INSTALL_URL=""
fi

# Save INSTALL_URL to config file if we detected a non-default source
# and it's not already in the config
if [[ -n "$ACTUAL_INSTALL_URL" ]] && [[ "$ACTUAL_INSTALL_URL" != *"github.com"* ]]; then
    mkdir -p "$CONFIG_DIR"
    # Read existing config if it exists
    local existing_config=""
    if [[ -f "$CONFIG_FILE" ]]; then
        existing_config=$(cat "$CONFIG_FILE")
    fi
    
    # Only update INSTALL_URL if it's not already set in config
    if ! echo "$existing_config" | grep -q "^INSTALL_URL="; then
        # Append INSTALL_URL to config file
        if [[ -f "$CONFIG_FILE" ]]; then
            echo "" >> "$CONFIG_FILE"
            echo "# Installation URL (auto-detected during installation)" >> "$CONFIG_FILE"
            echo "INSTALL_URL=\"$ACTUAL_INSTALL_URL\"" >> "$CONFIG_FILE"
        else
            cat > "$CONFIG_FILE" <<EOF
# godev configuration
# Installation URL (auto-detected during installation)
INSTALL_URL="$ACTUAL_INSTALL_URL"
EOF
        fi
    fi
fi

# Verify installation
if command -v "$BIN_NAME" &>/dev/null || [[ -x "$INSTALL_DIR/$BIN_NAME" ]]; then
    echo -e "${GREEN}✓ Installation successful!${NC}"
    echo ""
    if command -v "$BIN_NAME" &>/dev/null; then
        echo -e "Run: ${GREEN}godev --setup${NC}"
    else
        echo -e "Run:"
        echo -e "  ${GREEN}$INSTALL_DIR/$BIN_NAME --setup${NC}"
    fi
else
    echo -e "${RED}Installation failed.${NC}"
    exit 1
fi

