#!/bin/zsh
#
# -----------------------------------------------------------------------------
# Welcome to godev!
#
# This software is free and open source.
# Feel free to use, modify, and share it as you wish.
#
# (See full Apache 2.0 License at the end of this file)
# -----------------------------------------------------------------------------
#
# godev - Intelligent Project Navigator
#
# DESCRIPTION
#   Fast navigation to development projects. Searches for directories matching
#   a pattern within your DEV_BASE folder. Handles single matches (auto-cd),
#   multiple matches (interactive menu), and no matches (create option).
#
# INSTALLATION
#   Note: This script requires ZSH (default on macOS) due to array indexing.
#   It will NOT work correctly in Bash.
#
#   1. Save this script to a folder (e.g., ~/bin/godev)
#   2. Make it executable: chmod +x ~/bin/godev
#   3. Add this alias to your ~/.zshrc to source it:
#      alias godev="source ~/bin/godev"
#      (Sourcing is required to change the current shell directory)
#
# USAGE
#   godev <pattern>      Search for project matching pattern
#   godev -f <name>      Force creation of a new project directory
#   godev -v             Show version
#   godev -h             Show help
#
# EXAMPLES
#   godev react          # Jumps to ~/DEV/react-project if unique
#   godev api            # Shows menu if multiple 'api' projects exist
#   godev -f new-app     # Creates ~/DEV/new-app and cd into it
# -----------------------------------------------------------------------------

VERSION="1.1.0"

# Base projects directory (adjust according to your configuration)
DEV_BASE="${HOME}/DEV"

# Verify that the base directory exists
if [[ ! -d "$DEV_BASE" ]]; then
    echo "Error: Base directory $DEV_BASE does not exist"
    return 1
fi

# Temporarily disable alias if it exists
if alias godev &>/dev/null; then
    unalias godev
fi

# Main function
_godev_func() {
    local pattern=""
    local force_create=false
    
    # Process arguments
    for arg in "$@"; do
        case "$arg" in
            -v|--version)
                echo "godev version $VERSION"
                return 0
                ;;
            -f|--force)
                force_create=true
                ;;
            -h|--help)
                echo "godev - Navigate to development project directories"
                echo ""
                echo "Usage: godev <pattern> [-f] [-v]"
                echo ""
                echo "Options:"
                echo "  <pattern>       Directory search pattern"
                echo "  -f, --force     Force directory creation if it doesn't exist"
                echo "  -v, --version   Show script version"
                echo "  -h, --help      Show this help"
                return 0
                ;;
            -*)
                echo "Unknown option: $arg"
                echo "Use 'godev -h' to see help"
                return 1
                ;;
            *)
                pattern="$arg"
                ;;
        esac
    done
    
    # Verify that a pattern was provided
    if [[ -z "$pattern" ]]; then
        echo "Usage: godev <pattern> [-f] [-v]"
        echo "  -f, --force     Force directory creation if it doesn't exist"
        echo "  -v, --version   Show version"
        echo "  -h, --help      Show full help"
        return 1
    fi
    
    # Search for directories matching the pattern
    # Exclude: node_modules, .git, dist, build, vendor, .next, etc.
    local matches=()
    while IFS= read -r -d '' dir; do
        matches+=("$dir")
    done < <(find "$DEV_BASE" -maxdepth 3 -type d \
        -not -path "*/node_modules/*" \
        -not -path "*/.git/*" \
        -not -path "*/dist/*" \
        -not -path "*/build/*" \
        -not -path "*/vendor/*" \
        -not -path "*/.next/*" \
        -not -path "*/target/*" \
        -not -path "*/__pycache__/*" \
        -not -path "*/.venv/*" \
        -iname "*${pattern}*" -print0 2>/dev/null)
    
    local count=${#matches[@]}
    
    if [[ $count -eq 0 ]]; then
        # No matches found
        if [[ "$force_create" == true ]]; then
            local new_dir="${DEV_BASE}/${pattern}"
            mkdir -p "$new_dir"
            echo "✓ Directory created: $new_dir"
            cd "$new_dir"
        else
            echo "No directory found matching pattern: $pattern"
            echo "Use 'godev $pattern -f' to create the directory"
            return 1
        fi
    elif [[ $count -eq 1 ]]; then
        # Single match - change to directory
        cd "${matches[1]}"
        echo "→ ${matches[1]}"
    else
        # Multiple matches - show list
        echo "Found $count directories:"
        echo ""
        local i=1
        for dir in "${matches[@]}"; do
            echo "  [$i] ${dir#$DEV_BASE/}"
            ((i++))
        done
        echo ""
        echo -n "Select a number (1-$count) or press Enter to cancel: "
        read selection
        
        if [[ "$selection" =~ ^[0-9]+$ ]] && [[ "$selection" -ge 1 ]] && [[ "$selection" -le $count ]]; then
            cd "${matches[$selection]}"
            echo "→ ${matches[$selection]}"
        else
            echo "Cancelled"
            return 1
        fi
    fi
}

# Execute the function
_godev_func "$@"

# -----------------------------------------------------------------------------
# LICENSE (Apache 2.0)
#
# Copyright 2024 Augusto Sosa Escalada
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# -----------------------------------------------------------------------------