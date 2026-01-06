#!/usr/bin/env zsh

# godev Installer
# One-step installation for godev

set -e

# Colors
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
CYAN=$'\033[0;36m'
BOLD=$'\033[1m'
NC=$'\033[0m'

INSTALL_DIR="$HOME/.local/bin"
GODEV_SCRIPT="$INSTALL_DIR/godev"
ZSHRC="$HOME/.zshrc"

# Main script URL
SCRIPT_URL="https://raw.githubusercontent.com/augustose/godev/main/godev"

echo "${BOLD}${CYAN}"
cat << "EOF"
   __ _  ___     __| | _____   __
  / _` |/ _ \   / _` |/ _ \ \ / /
 | (_| | (_) | | (_| |  __/\ V / 
  \__, |\___/   \__,_|\___| \_/  
  |___/                           
  
  Demystify Your Development Tree
  Navigate 100+ projects in seconds ⚡
EOF
echo "${NC}"

echo "${BOLD}godev installer v1.0.0${NC}"
echo ""

# ============================================================================
# CHECKS
# ============================================================================

# Check for existing installation
if [[ -x "$GODEV_SCRIPT" ]]; then
    CURRENT_VERSION=$(~/.local/bin/godev --version 2>/dev/null | grep -o '[0-9.]*' || echo "unknown")
    echo "${YELLOW}⚠ godev is already installed (version $CURRENT_VERSION)${NC}"
    echo -n "Update/reinstall? (y/N): "
    read -k 1 reinstall < /dev/tty
    echo
    echo ""
    if [[ ! "$reinstall" =~ ^[yY]$ ]]; then
        echo "${CYAN}Installation cancelled${NC}"
        exit 0
    fi
fi

echo "${CYAN}[1/10]${NC} Checking for ZSH..."
if [[ -z "$ZSH_VERSION" ]]; then
    echo "${RED}✗ Error: This installer must be run with ZSH${NC}"
    echo "  Run: zsh -c '\$(curl -fsSL INSTALLER_URL)'"
    exit 1
fi
echo "${GREEN}✓ ZSH detected${NC}"

echo ""
echo "${CYAN}[2/10]${NC} Checking for FZF..."
if command -v fzf &> /dev/null; then
    echo "${GREEN}✓ FZF installed${NC}"
    FZF_INSTALLED=true
else
    echo "${YELLOW}⚠ FZF not detected${NC}"
    echo "  ${BOLD}FZF is recommended for better experience:${NC}"
    echo "  • macOS: ${CYAN}brew install fzf${NC}"
    echo "  • Ubuntu/Debian: ${CYAN}sudo apt install fzf${NC}"
    echo "  • Fedora: ${CYAN}sudo dnf install fzf${NC}"
    echo ""
    echo -n "Continue without FZF? (y/N): "
    read -k 1 continue < /dev/tty
    echo
    if [[ ! "$continue" =~ ^[yY]$ ]]; then
        echo "${YELLOW}Installation cancelled. Install FZF and try again.${NC}"
        exit 0
    fi
    FZF_INSTALLED=false
fi

# ============================================================================
# CREATE DIRECTORIES
# ============================================================================

echo ""
echo "${CYAN}[3/10]${NC} Creating required directories..."
mkdir -p "$INSTALL_DIR"
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/godev"
echo "${GREEN}✓ Directories created${NC}"

# ============================================================================
# CHECK PATH
# ============================================================================

echo ""
echo "${CYAN}[4/10]${NC} Checking PATH..."
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "${YELLOW}⚠ $INSTALL_DIR is not in PATH${NC}"
    echo "  Adding to ~/.zshrc..."

    # Backup before modifying
    cp "$ZSHRC" "$ZSHRC.backup-$(date +%s)" 2>/dev/null

    echo "" >> "$ZSHRC"
    echo "# godev - added by installer" >> "$ZSHRC"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$ZSHRC"
    echo "${GREEN}✓ PATH updated${NC}"
else
    echo "${GREEN}✓ PATH correct${NC}"
fi

# ============================================================================
# DOWNLOAD SCRIPT
# ============================================================================

echo ""
echo "${CYAN}[5/10]${NC} Downloading main script..."

# For development/testing: copy from local file if it exists
if [[ -f "./godev" ]]; then
    echo "${YELLOW}  Using local version for development${NC}"
    cp "./godev" "$GODEV_SCRIPT"
else
    # In production: download from URL
    if command -v curl &> /dev/null; then
        curl -fsSL "$SCRIPT_URL" -o "$GODEV_SCRIPT"
    elif command -v wget &> /dev/null; then
        wget -q "$SCRIPT_URL" -O "$GODEV_SCRIPT"
    else
        echo "${RED}✗ Error: You need curl or wget installed${NC}"
        exit 1
    fi
fi

echo "${GREEN}✓ Script downloaded${NC}"

# ============================================================================
# SET PERMISSIONS
# ============================================================================

echo ""
echo "${CYAN}[6/10]${NC} Setting permissions..."
chmod +x "$GODEV_SCRIPT"
echo "${GREEN}✓ Permissions set${NC}"

# ============================================================================
# ADD WRAPPER FUNCTION
# ============================================================================

echo ""
echo "${CYAN}[7/10]${NC} Setting up wrapper function in ZSH..."

# Check if it already exists
if grep -q "^godev()" "$ZSHRC" 2>/dev/null; then
    echo "${YELLOW}⚠ godev function already exists in ~/.zshrc${NC}"
    echo -n "  Replace? (y/N): "
    read -k 1 replace < /dev/tty
    echo

    if [[ "$replace" =~ ^[yY]$ ]]; then
        # Backup before modifying
        cp "$ZSHRC" "$ZSHRC.backup-$(date +%s)"
        # Remove old function (between godev() { and the closing })
        sed -i.backup '/^godev() {$/,/^}$/d' "$ZSHRC"
        echo "${GREEN}✓ Previous function removed (backup created)${NC}"
    else
        echo "${YELLOW}⚠ Using existing function${NC}"
        SKIP_WRAPPER=true
    fi
fi

if [[ "$SKIP_WRAPPER" != "true" ]]; then
    cat >> "$ZSHRC" << 'EOF'

# godev - Function wrapper (added by installer)
godev() {
    local result

    # Commands that don't change directory (start with -)
    if [[ "$1" =~ ^- ]]; then
        command ~/.local/bin/godev "$@"
        return $?
    fi

    # Navigation command
    result=$(command ~/.local/bin/godev "$@")
    local exit_code=$?

    # If result is a valid directory, change to it
    if [[ $exit_code -eq 0 ]] && [[ -d "$result" ]]; then
        cd "$result"
    else
        # Otherwise, show the output (error or message)
        echo "$result"
        return $exit_code
    fi
}
EOF
    echo "${GREEN}✓ Wrapper function added to ~/.zshrc${NC}"
fi

# ============================================================================
# SAVE INSTALLATION INFO
# ============================================================================

echo ""
echo "${CYAN}[8/10]${NC} Saving installation info..."
cat > "${XDG_CONFIG_HOME:-$HOME/.config}/godev/version_info" << EOF
version=2.1.11
install_date=$(date +%s)
install_source=$SCRIPT_URL
fzf_available=$FZF_INSTALLED
EOF
echo "${GREEN}✓ Info saved${NC}"

# ============================================================================
# INITIAL CONFIGURATION
# ============================================================================

echo ""
echo "${CYAN}[9/10]${NC} Initial configuration..."
echo ""

# Ask for base directory
local default_base="$HOME/dev"
echo -n "Base directory for projects [${CYAN}${default_base}${NC}]: "
read base_dir < /dev/tty
base_dir="${base_dir:-$default_base}"
base_dir="${base_dir/#\~/$HOME}"

# Create if not exists
if [[ ! -d "$base_dir" ]]; then
    echo -n "Directory does not exist. Create it? (Y/n): "
    read -k 1 create < /dev/tty
    echo
    if [[ ! "$create" =~ ^[nN]$ ]]; then
        mkdir -p "$base_dir"
        echo "${GREEN}✓ Directory created: $base_dir${NC}"
    else
        echo "${RED}✗ You need a valid base directory${NC}"
        exit 1
    fi
fi

# Save configuration
cat > "${XDG_CONFIG_HOME:-$HOME/.config}/godev/config" << EOF
# godev configuration
GODEV_BASE_DIR="$base_dir"
GODEV_FZF_ENABLED="$FZF_INSTALLED"
EOF

echo "${GREEN}✓ Configuration saved${NC}"

# ============================================================================
# POST-INSTALLATION CHECK
# ============================================================================

echo ""
echo "${CYAN}[10/11]${NC} Verifying installation..."

# Verify script exists and is executable
if [[ -x "$GODEV_SCRIPT" ]]; then
    echo "${GREEN}✓ Script installed correctly${NC}"
else
    echo "${RED}✗ Error: Script not found or no permissions${NC}"
    exit 1
fi

# Verify wrapper function exists in .zshrc
if grep -q "^godev()" "$ZSHRC"; then
    echo "${GREEN}✓ Wrapper function configured${NC}"
else
    echo "${YELLOW}⚠ Wrapper function not found in .zshrc${NC}"
fi

# Verify configuration
if [[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/godev/config" ]]; then
    echo "${GREEN}✓ Configuration created${NC}"
else
    echo "${RED}✗ Error: Configuration file not found${NC}"
    exit 1
fi

# ============================================================================
# FINALIZE
# ============================================================================

echo ""
echo "${CYAN}[11/11]${NC} Finalizing installation..."
echo ""

cat << EOF
${GREEN}${BOLD}✓ Installation completed!${NC}

${BOLD}Next steps:${NC}

1. Reload your configuration:
   ${CYAN}source ~/.zshrc${NC}

2. Try godev:
   ${CYAN}godev${NC}                 ${GRAY}# Interactive menu${NC}
   ${CYAN}godev --list${NC}          ${GRAY}# List your projects${NC}
   ${CYAN}godev <name>${NC}        ${GRAY}# Navigate to a project${NC}

3. For help:
   ${CYAN}godev --help${NC}

${BOLD}Configuration:${NC}
   Base directory: ${CYAN}$base_dir${NC}
   FZF available: ${CYAN}$FZF_INSTALLED${NC}
   
EOF

if [[ "$FZF_INSTALLED" == "false" ]]; then
    echo "${YELLOW}${BOLD}💡 Recommendation:${NC}"
    echo "   Install FZF for a premium experience:"
    echo "   ${CYAN}brew install fzf${NC} (macOS)"
    echo "   ${CYAN}sudo apt install fzf${NC} (Ubuntu/Debian)"
    echo ""
fi

echo "${BOLD}Enjoy godev! 🚀${NC}"
echo ""
