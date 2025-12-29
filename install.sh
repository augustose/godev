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

# GitHub repository URL
GITHUB_REPO="https://raw.githubusercontent.com/augustose/godev/main"

# Initialize TEMP_DIR variable for cleanup
TEMP_DIR=""

# Determine if we're running from a piped curl command or local file
# When piped, $0 is usually "-zsh" or similar, not a file path
if [[ "$0" == -* ]] || [[ ! -f "$0" ]]; then
    # Running from piped curl - download godev script from GitHub
    echo -e "${BLUE}Downloading godev script from GitHub...${NC}"
    TEMP_DIR=$(mktemp -d)
    GODEV_SCRIPT="$TEMP_DIR/godev"
    
    if ! curl -fsSL "$GITHUB_REPO/godev" -o "$GODEV_SCRIPT"; then
        echo -e "${RED}Error: Failed to download godev script from GitHub${NC}"
        exit 1
    fi
    
    chmod +x "$GODEV_SCRIPT"
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

# Check if already installed
INSTALLED_VERSION=""
if [[ -f "$INSTALL_DIR/$BIN_NAME" ]]; then
    INSTALLED_VERSION=$("$INSTALL_DIR/$BIN_NAME" version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "unknown")
    echo -e "${YELLOW}godev is already installed at $INSTALL_DIR/$BIN_NAME${NC}"
    if [[ -n "$INSTALLED_VERSION" ]] && [[ "$INSTALLED_VERSION" != "unknown" ]]; then
        echo -e "  Installed version: ${BLUE}$INSTALLED_VERSION${NC}"
    fi
    echo ""
    read "?Do you want to update/overwrite it? (y/N): " overwrite
    if [[ "$overwrite" != "y" ]] && [[ "$overwrite" != "Y" ]]; then
        echo "Installation cancelled."
        exit 0
    fi
    echo -e "${BLUE}Updating godev...${NC}"
fi

# Copy script
echo -e "${BLUE}Installing godev...${NC}"
cp "$GODEV_SCRIPT" "$INSTALL_DIR/$BIN_NAME"
chmod +x "$INSTALL_DIR/$BIN_NAME"

# Function to check if directory is in PATH
check_path() {
    # Check current session PATH
    if [[ ":$PATH:" == *":$INSTALL_DIR:"* ]]; then
        return 0
    fi
    # Check ~/.zshrc
    if [[ -f "$HOME/.zshrc" ]] && grep -q "$INSTALL_DIR" "$HOME/.zshrc"; then
        return 0
    fi
    # Check other common shell config files
    for config_file in "$HOME/.zshenv" "$HOME/.zprofile" "$HOME/.profile"; do
        if [[ -f "$config_file" ]] && grep -q "$INSTALL_DIR" "$config_file"; then
            return 0
        fi
    done
    return 1
}

# Check if directory is in PATH
if ! check_path; then
    echo ""
    echo -e "${YELLOW}⚠️  $INSTALL_DIR is not in your PATH${NC}"
    echo ""
    echo "To add it, run one of these commands:"
    echo ""
    echo -e "${CYAN}Option 1: Add to ~/.zshrc (recommended)${NC}"
    echo -e "  ${GREEN}echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.zshrc${NC}"
    echo -e "  ${GREEN}source ~/.zshrc${NC}"
    echo ""
    echo -e "${CYAN}Option 2: Add for current session only${NC}"
    echo -e "  ${GREEN}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
    echo ""
    read "?Add to ~/.zshrc automatically? (y/N): " add_path
    if [[ "$add_path" == "y" ]] || [[ "$add_path" == "Y" ]]; then
        if [[ -f "$HOME/.zshrc" ]]; then
            if ! grep -q "$INSTALL_DIR" "$HOME/.zshrc"; then
                echo "" >> "$HOME/.zshrc"
                echo "# godev" >> "$HOME/.zshrc"
                echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.zshrc"
                echo -e "${GREEN}✓ Added to ~/.zshrc${NC}"
                echo -e "${YELLOW}Run: source ~/.zshrc${NC}"
                echo -e "${YELLOW}Or open a new terminal session${NC}"
            else
                echo -e "${GREEN}✓ Already in ~/.zshrc${NC}"
                echo -e "${YELLOW}You may need to run: source ~/.zshrc${NC}"
            fi
        else
            echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" > "$HOME/.zshrc"
            echo -e "${GREEN}✓ Created ~/.zshrc${NC}"
            echo -e "${YELLOW}Run: source ~/.zshrc${NC}"
        fi
    else
        echo ""
        echo -e "${YELLOW}Remember to add $INSTALL_DIR to your PATH${NC}"
    fi
else
    # Check if it's in current session PATH
    if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
        echo ""
        echo -e "${YELLOW}⚠️  $INSTALL_DIR is configured but not in current PATH${NC}"
        echo -e "${YELLOW}Run: source ~/.zshrc${NC}"
        echo -e "${YELLOW}Or open a new terminal session${NC}"
    fi
fi

# Verify installation
if command -v "$BIN_NAME" &>/dev/null || [[ -x "$INSTALL_DIR/$BIN_NAME" ]]; then
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}  ${GREEN}✓ Installation successful!${NC}                                    ${GREEN}║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "godev has been installed to: $INSTALL_DIR/$BIN_NAME"
    echo ""
    echo "Try it out:"
    echo -e "  ${BLUE}godev help${NC}        # Show help"
    echo -e "  ${BLUE}godev status${NC}      # Check project status"
    echo -e "  ${BLUE}godev nav <pattern>${NC}  # Navigate to project"
    echo ""
    
    # Check if in PATH
    if command -v "$BIN_NAME" &>/dev/null; then
        echo -e "${GREEN}✓ godev is in your PATH${NC}"
        NEW_VERSION=$("$INSTALL_DIR/$BIN_NAME" version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "")
        if [[ -n "$NEW_VERSION" ]]; then
            echo -e "  Version: ${BLUE}$NEW_VERSION${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  $INSTALL_DIR is not in your current PATH${NC}"
        echo ""
        echo "To use godev now, run:"
        echo -e "  ${GREEN}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
        echo ""
        echo "Or use the full path:"
        echo -e "  ${GREEN}$INSTALL_DIR/$BIN_NAME help${NC}"
    fi
    echo ""
    echo -e "${CYAN}To update godev in the future, simply run:${NC}"
    echo -e "  ${GREEN}curl -fsSL https://raw.githubusercontent.com/augustose/godev/main/install.sh | zsh${NC}"
else
    echo -e "${RED}Installation may have failed. Please check manually.${NC}"
    exit 1
fi

