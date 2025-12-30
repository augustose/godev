# Changelog

All notable changes to godev will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2024-12-29

### Added
- Unified script with subcommand structure
- `godev nav` command for project navigation
- `godev status` command for project activity monitoring
- `godev list` command (placeholder)
- `godev ai-status` command (placeholder)
- Readonly mode for safe testing
- Installation script
- Comprehensive documentation
- Test plan and basic test suite

### Changed
- Refactored from multiple scripts (godev.sh, govap.sh) to unified script
- Improved project name display to show nested paths (e.g., `senetca/my-web-app`)
- Enhanced help system with better formatting

### Security
- Added .gitignore to exclude personal files
- Readonly mode prevents accidental modifications

## [Unreleased]

### Fixed
- `godev --setup` now always prompts user for base directory and readonly mode, even when values exist
- Setup command now uses `/dev/tty` for prompts to work correctly when stdout is captured by wrapper functions

### Changed
- `godev update` now displays the source URL used for downloading updates
- Updated documentation to reflect new setup and update behaviors

### Planned
- AI tool detection implementation
- Interactive mode with fzf
- Export formats (JSON, HTML, CSV)
- Theme customization
- Plugin system

[2.0.0]: https://github.com/augustose/godev/releases/tag/v2.0.0

