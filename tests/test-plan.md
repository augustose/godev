# Test Plan for godev

## Overview
This test plan ensures godev works correctly in readonly mode without modifying the development folder structure.

## Test Environment
- **Mode**: Readonly (READONLY_MODE=true)
- **Base Directory**: Uses ${HOME}/DEV (or custom with -d)
- **Shell**: ZSH required

## Test Categories

### 1. Basic Commands

#### 1.1 Help Command
- [ ] `godev help` - Shows help
- [ ] `godev -h` - Shows help
- [ ] `godev --help` - Shows help
- [ ] Help text is complete and formatted correctly

#### 1.2 Version Command
- [ ] `godev version` - Shows version
- [ ] `godev -v` - Shows version
- [ ] `godev --version` - Shows version
- [ ] Version format is correct (e.g., "godev version 2.0.0")

### 2. Nav Command Tests

#### 2.1 Basic Navigation
- [ ] `godev nav <pattern>` - Searches for projects
- [ ] `godev <pattern>` - Defaults to nav command
- [ ] Single match shows path (readonly mode)
- [ ] Multiple matches show interactive list
- [ ] No matches shows appropriate message

#### 2.2 Readonly Mode Behavior
- [ ] Does NOT create directories when pattern not found
- [ ] Shows "[READONLY MODE]" message when appropriate
- [ ] Shows "Would create" message instead of creating
- [ ] Shows "Would navigate to" instead of changing directory
- [ ] Outputs "Run: cd <path>" for user to execute manually

#### 2.3 Pattern Matching
- [ ] Case-insensitive matching works
- [ ] Partial matches work
- [ ] Excludes node_modules, .git, dist, build, etc.
- [ ] Handles nested project structures (e.g., senetca/my-web-app)

#### 2.4 Edge Cases
- [ ] Empty pattern shows usage
- [ ] Invalid options show error
- [ ] Non-existent base directory shows error
- [ ] Special characters in pattern handled correctly

### 3. Status Command Tests

#### 3.1 Basic Status
- [ ] `godev status` - Shows project status
- [ ] `godev status -d <path>` - Uses custom directory
- [ ] Finds all Git repositories recursively
- [ ] Shows correct project names (nested paths)
- [ ] Excludes build/dependency directories

#### 3.2 Status Information
- [ ] Shows last commit date (relative)
- [ ] Shows current branch
- [ ] Shows repository status (clean, modified, ahead, behind, diverged)
- [ ] Shows activity indicators (30 days)
- [ ] Shows summary statistics

#### 3.3 Filtering and Sorting
- [ ] `godev status -f <days>` - Filters by days
- [ ] `godev status -s date` - Sorts by date (default)
- [ ] `godev status -s name` - Sorts by name
- [ ] `godev status -s activity` - Sorts by activity
- [ ] `godev status -a` - Shows all (including non-Git)

#### 3.4 Readonly Mode
- [ ] Does NOT modify any Git repositories
- [ ] Does NOT change directory
- [ ] Only reads Git information
- [ ] Safe to run on any directory structure

### 4. List Command Tests
- [ ] `godev list` - Lists all projects
- [ ] Shows project paths
- [ ] Excludes build/dependency directories
- [ ] Handles nested structures

### 5. AI Status Command Tests
- [ ] `godev ai-status` - Checks AI tools (when implemented)
- [ ] Detects installed tools
- [ ] Shows context files in projects
- [ ] Does NOT modify any files

### 6. Integration Tests

#### 6.1 Command Chaining
- [ ] Multiple commands work sequentially
- [ ] Options are parsed correctly
- [ ] Error handling doesn't break subsequent commands

#### 6.2 Real-World Scenarios
- [ ] Works with actual DEV directory structure
- [ ] Handles projects with special characters
- [ ] Works with deeply nested structures
- [ ] Performance is acceptable with many projects

### 7. Safety Tests (Critical)

#### 7.1 Readonly Mode Verification
- [ ] NO directories created during tests
- [ ] NO files modified during tests
- [ ] NO Git operations that modify state
- [ ] All operations are read-only

#### 7.2 Error Handling
- [ ] Invalid commands show helpful errors
- [ ] Missing directories handled gracefully
- [ ] Permission errors handled correctly
- [ ] Script doesn't crash on edge cases

## Test Execution

### Manual Testing
Run tests manually following this plan and check each item.

### Automated Testing (Future)
Create test scripts that:
- Set up test directories
- Run commands
- Verify output
- Check readonly mode compliance
- Clean up test data

## Success Criteria
- All basic commands work
- Readonly mode is enforced
- No modifications to development folders
- Output is clear and helpful
- Error handling is robust

