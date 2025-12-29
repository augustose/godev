#!/bin/zsh
#
# -----------------------------------------------------------------------------
# Welcome to govap-cursor!
#
# This software is free and open source.
# Feel free to use, modify, and share it as you wish.
#
# (See full Apache 2.0 License at the end of this file)
# -----------------------------------------------------------------------------
#
# govap-cursor - Verificador Avanzado de Actividad de Proyectos
#
# DESCRIPTION
#   Analiza todos los repositorios Git en un directorio base y muestra un
#   resumen detallado de la actividad de cada proyecto, incluyendo:
#   - Fecha del último commit (relativa y absoluta)
#   - Branch actual
#   - Estado del repositorio (clean, modified, ahead, behind)
#   - Estadísticas de commits
#   - Ordenamiento por actividad reciente
#
# INSTALLATION
#   1. Save this script to a folder (e.g., ~/bin/govap-cursor)
#   2. Make it executable: chmod +x ~/bin/govap-cursor
#   3. Add to PATH or use with full path
#
# USAGE
#   govap-cursor [OPTIONS]
#
# OPTIONS
#   -d, --dir <path>      Base directory to scan (default: ~/DEV)
#   -s, --sort <mode>     Sort mode: date|name|activity (default: date)
#   -f, --filter <days>   Show only projects active in last N days
#   -a, --all             Show all projects, including non-Git directories
#   -v, --version         Show version
#   -h, --help            Show help
#
# EXAMPLES
#   govap-cursor                    # Scan ~/DEV and show all Git repos
#   govap-cursor -d ~/Projects      # Scan custom directory
#   govap-cursor -f 30              # Show only projects active in last 30 days
#   govap-cursor -s activity        # Sort by activity level
# -----------------------------------------------------------------------------

VERSION="1.0.0"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Default base directory
DEV_BASE="${HOME}/DEV"

# Configuration
SHOW_ALL=false
SORT_MODE="date"
FILTER_DAYS=""
BASE_DIR=""

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--dir)
                BASE_DIR="$2"
                shift 2
                ;;
            -s|--sort)
                SORT_MODE="$2"
                shift 2
                ;;
            -f|--filter)
                FILTER_DAYS="$2"
                shift 2
                ;;
            -a|--all)
                SHOW_ALL=true
                shift
                ;;
            -v|--version)
                echo "govap-cursor version $VERSION"
                exit 0
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                echo "Use 'govap-cursor -h' for help"
                exit 1
                ;;
        esac
    done
    
    # Set base directory
    if [[ -z "$BASE_DIR" ]]; then
        BASE_DIR="$DEV_BASE"
    fi
}

show_help() {
    cat << EOF
govap-cursor - Verificador Avanzado de Actividad de Proyectos

USAGE
    govap-cursor [OPTIONS]

OPTIONS
    -d, --dir <path>      Base directory to scan (default: ~/DEV)
    -s, --sort <mode>     Sort mode: date|name|activity (default: date)
    -f, --filter <days>   Show only projects active in last N days
    -a, --all             Show all projects, including non-Git directories
    -v, --version         Show version
    -h, --help            Show this help

EXAMPLES
    govap-cursor                    # Scan ~/DEV and show all Git repos
    govap-cursor -d ~/Projects      # Scan custom directory
    govap-cursor -f 30              # Show only projects active in last 30 days
    govap-cursor -s activity        # Sort by activity level

EOF
}

# Get project information
get_project_info() {
    local dir="$1"
    local project_name="${dir##*/}"
    
    if [[ ! -d "$dir/.git" ]]; then
        if [[ "$SHOW_ALL" == true ]]; then
            echo "$project_name|NO_GIT|N/A|N/A|N/A|N/A|N/A|N/A"
        fi
        return
    fi
    
    pushd "$dir" > /dev/null 2>&1 || return
    
    # Get last commit date (relative and absolute)
    local last_commit_relative=""
    local last_commit_absolute=""
    local last_commit_timestamp=""
    
    if git rev-parse --git-dir > /dev/null 2>&1; then
        last_commit_relative=$(git log -1 --format="%ar" 2>/dev/null)
        last_commit_absolute=$(git log -1 --format="%ci" 2>/dev/null)
        last_commit_timestamp=$(git log -1 --format="%ct" 2>/dev/null)
        
        # Get current branch
        local branch=$(git branch --show-current 2>/dev/null || echo "detached")
        
        # Get repository status
        local status=""
        local git_status=$(git status --porcelain 2>/dev/null)
        local ahead=$(git status -sb 2>/dev/null | grep -o 'ahead [0-9]*' | grep -o '[0-9]*')
        local behind=$(git status -sb 2>/dev/null | grep -o 'behind [0-9]*' | grep -o '[0-9]*')
        
        if [[ -n "$git_status" ]]; then
            status="modified"
        elif [[ -n "$ahead" ]] && [[ -n "$behind" ]]; then
            status="diverged"
        elif [[ -n "$ahead" ]]; then
            status="ahead"
        elif [[ -n "$behind" ]]; then
            status="behind"
        else
            status="clean"
        fi
        
        # Get commit count (last 30 days)
        local commit_count=$(git log --since="30 days ago" --oneline 2>/dev/null | wc -l | tr -d ' ')
        
        # Get total commits
        local total_commits=$(git rev-list --count HEAD 2>/dev/null || echo "0")
        
        echo "$project_name|$last_commit_relative|$last_commit_absolute|$last_commit_timestamp|$branch|$status|$commit_count|$total_commits"
    fi
    
    popd > /dev/null 2>&1
}

# Calculate days since last commit
days_since_commit() {
    local timestamp="$1"
    if [[ -z "$timestamp" ]] || [[ "$timestamp" == "N/A" ]]; then
        echo "999999"
        return
    fi
    local now=$(date +%s)
    local diff=$((now - timestamp))
    echo $((diff / 86400))
}

# Format status with color
format_status() {
    local status="$1"
    case "$status" in
        clean)
            echo -e "${GREEN}✓ clean${NC}"
            ;;
        modified)
            echo -e "${RED}● modified${NC}"
            ;;
        ahead)
            echo -e "${YELLOW}↑ ahead${NC}"
            ;;
        behind)
            echo -e "${BLUE}↓ behind${NC}"
            ;;
        diverged)
            echo -e "${MAGENTA}↕ diverged${NC}"
            ;;
        NO_GIT)
            echo -e "${GRAY}○ no git${NC}"
            ;;
        *)
            echo -e "${GRAY}$status${NC}"
            ;;
    esac
}

# Main function
main() {
    parse_args "$@"
    
    # Verify base directory exists
    if [[ ! -d "$BASE_DIR" ]]; then
        echo -e "${RED}Error: Base directory $BASE_DIR does not exist${NC}" >&2
        exit 1
    fi
    
    echo -e "${WHITE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}  Verificador de Actividad de Proyectos${NC}"
    echo -e "${WHITE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GRAY}Scanning: ${BASE_DIR}${NC}"
    echo ""
    
    # Collect project information
    local projects=()
    local project_count=0
    local git_count=0
    
    for dir in "$BASE_DIR"/*/; do
        if [[ -d "$dir" ]]; then
            local info=$(get_project_info "$dir")
            if [[ -n "$info" ]]; then
                projects+=("$info")
                ((project_count++))
                if [[ "$info" != *"NO_GIT"* ]]; then
                    ((git_count++))
                fi
            fi
        fi
    done
    
    if [[ $project_count -eq 0 ]]; then
        echo -e "${YELLOW}No projects found in $BASE_DIR${NC}"
        exit 0
    fi
    
    # Filter by days if specified
    if [[ -n "$FILTER_DAYS" ]]; then
        local filtered=()
        for project in "${projects[@]}"; do
            IFS='|' read -r name rel abs timestamp branch status commits total <<< "$project"
            local days=$(days_since_commit "$timestamp")
            if [[ $days -le $FILTER_DAYS ]]; then
                filtered+=("$project")
            fi
        done
        projects=("${filtered[@]}")
    fi
    
    # Sort projects
    case "$SORT_MODE" in
        name)
            # Sort by name
            projects=($(printf '%s\n' "${projects[@]}" | sort -t'|' -k1))
            ;;
        activity)
            # Sort by commit count (descending)
            projects=($(printf '%s\n' "${projects[@]}" | sort -t'|' -k7 -rn))
            ;;
        date|*)
            # Sort by timestamp (descending - most recent first)
            projects=($(printf '%s\n' "${projects[@]}" | sort -t'|' -k4 -rn))
            ;;
    esac
    
    # Display results
    local active_count=0
    local modified_count=0
    local ahead_count=0
    local behind_count=0
    
    printf "%-30s %-20s %-15s %-12s %s\n" \
        "PROJECT" "LAST COMMIT" "BRANCH" "STATUS" "ACTIVITY (30d)"
    echo -e "${GRAY}$(printf '%.0s─' {1..100})${NC}"
    
    for project in "${projects[@]}"; do
        IFS='|' read -r name rel abs timestamp branch status commits total <<< "$project"
        
        # Skip if no git and not showing all
        if [[ "$status" == "NO_GIT" ]] && [[ "$SHOW_ALL" != true ]]; then
            continue
        fi
        
        # Truncate long names
        local display_name="$name"
        if [[ ${#display_name} -gt 28 ]]; then
            display_name="${display_name:0:25}..."
        fi
        
        # Format branch
        local display_branch="$branch"
        if [[ ${#display_branch} -gt 13 ]]; then
            display_branch="${display_branch:0:10}..."
        fi
        
        # Format relative date
        local display_date="$rel"
        if [[ ${#display_date} -gt 18 ]]; then
            display_date="${display_date:0:15}..."
        fi
        
        # Status icon and color
        local status_display=$(format_status "$status")
        
        # Activity indicator
        local activity_display=""
        if [[ "$commits" != "N/A" ]] && [[ "$commits" != "" ]]; then
            if [[ $commits -gt 10 ]]; then
                activity_display="${GREEN}●●●${NC} ($commits)"
            elif [[ $commits -gt 5 ]]; then
                activity_display="${YELLOW}●●○${NC} ($commits)"
            elif [[ $commits -gt 0 ]]; then
                activity_display="${GRAY}●○○${NC} ($commits)"
            else
                activity_display="${GRAY}○○○${NC} (0)"
            fi
        else
            activity_display="${GRAY}○○○${NC}"
        fi
        
        printf "%-30s %-20s %-15s %-30s %s\n" \
            "$display_name" \
            "$display_date" \
            "$display_branch" \
            "$status_display" \
            "$activity_display"
        
        # Count statistics
        case "$status" in
            clean|ahead|behind|diverged)
                ((active_count++))
                ;;
            modified)
                ((modified_count++))
                ((active_count++))
                ;;
        esac
        
        if [[ "$status" == "ahead" ]] || [[ "$status" == "diverged" ]]; then
            ((ahead_count++))
        fi
        if [[ "$status" == "behind" ]] || [[ "$status" == "diverged" ]]; then
            ((behind_count++))
        fi
    done
    
    echo ""
    echo -e "${WHITE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GRAY}Summary:${NC}"
    echo -e "  Total projects: ${WHITE}$project_count${NC}"
    echo -e "  Git repositories: ${WHITE}$git_count${NC}"
    echo -e "  Active repos: ${GREEN}$active_count${NC}"
    if [[ $modified_count -gt 0 ]]; then
        echo -e "  Modified: ${YELLOW}$modified_count${NC}"
    fi
    if [[ $ahead_count -gt 0 ]]; then
        echo -e "  Ahead of remote: ${YELLOW}$ahead_count${NC}"
    fi
    if [[ $behind_count -gt 0 ]]; then
        echo -e "  Behind remote: ${BLUE}$behind_count${NC}"
    fi
    echo -e "${WHITE}═══════════════════════════════════════════════════════════════${NC}"
}

# Run main function
main "$@"

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

