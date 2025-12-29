#!/bin/zsh

# godev - Navigate to development project directories
# Usage: godev <pattern> [-f] [-v]
# Version: 1.1.0

VERSION="1.0.0"

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