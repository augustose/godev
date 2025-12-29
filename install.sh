#!/bin/zsh
#
# godev Installation Script
# Installs godev to a directory in PATH
#

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
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

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GODEV_SCRIPT="$SCRIPT_DIR/godev"

# Check if godev script exists
if [[ ! -f "$GODEV_SCRIPT" ]]; then
    echo -e "${RED}Error: godev script not found at $GODEV_SCRIPT${NC}"
    exit 1
fi

# Create install directory if it doesn't exist
if [[ ! -d "$INSTALL_DIR" ]]; then
    echo -e "${YELLOW}Creating installation directory: $INSTALL_DIR${NC}"
    mkdir -p "$INSTALL_DIR"
fi

# Check if already installed
if [[ -f "$INSTALL_DIR/$BIN_NAME" ]]; then
    echo -e "${YELLOW}godev is already installed at $INSTALL_DIR/$BIN_NAME${NC}"
    read "?Do you want to overwrite it? (y/N): " overwrite
    if [[ "$overwrite" != "y" ]] && [[ "$overwrite" != "Y" ]]; then
        echo "Installation cancelled."
        exit 0
    fi
fi

# Copy script
echo -e "${BLUE}Installing godev...${NC}"
cp "$GODEV_SCRIPT" "$INSTALL_DIR/$BIN_NAME"
chmod +x "$INSTALL_DIR/$BIN_NAME"

# Check if directory is in PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo ""
    echo -e "${YELLOW}⚠️  $INSTALL_DIR is not in your PATH${NC}"
    echo ""
    echo "Add this to your ~/.zshrc:"
    echo -e "${GREEN}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
    echo ""
    read "?Add to PATH now? (y/N): " add_path
    if [[ "$add_path" == "y" ]] || [[ "$add_path" == "Y" ]]; then
        if [[ -f "$HOME/.zshrc" ]]; then
            if ! grep -q "$INSTALL_DIR" "$HOME/.zshrc"; then
                echo "" >> "$HOME/.zshrc"
                echo "# godev" >> "$HOME/.zshrc"
                echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.zshrc"
                echo -e "${GREEN}✓ Added to ~/.zshrc${NC}"
                echo -e "${YELLOW}Run: source ~/.zshrc${NC}"
            else
                echo -e "${GREEN}✓ Already in ~/.zshrc${NC}"
            fi
        else
            echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" > "$HOME/.zshrc"
            echo -e "${GREEN}✓ Created ~/.zshrc${NC}"
        fi
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
    else
        echo -e "${YELLOW}⚠️  Add $INSTALL_DIR to your PATH or use full path${NC}"
    fi
else
    echo -e "${RED}Installation may have failed. Please check manually.${NC}"
    exit 1
fi

