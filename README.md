# 🚀 godev - Demystify Your Multi-Folder Development Tree

> **Navigate 100+ projects in seconds. Make sense of complex development structures.** ⚡

[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![ZSH](https://img.shields.io/badge/shell-zsh-blue.svg)](https://www.zsh.org/)

## ✨ Why developers love godev

- 🔍 **Demystify complexity** - Make sense of multi-folder development trees
- ⚡ **Lightning fast** - Navigate projects in milliseconds
- 🚀 **Zero config** - Works out of the box, start immediately
- 🌳 **Tree visualization** - See your development structure clearly
- 🎨 **Beautiful output** - Your terminal deserves better
- 🔧 **Highly customizable** - Make it yours
- 📊 **Git insights** - Know your projects at a glance
- 🤖 **AI-ready** - Detects and integrates with AI dev tools

## 🚀 Quick Start

### One-line Install

```bash
curl -fsSL https://raw.githubusercontent.com/tu-usuario/godev/main/install.sh | zsh
```

### Manual Install

```bash
# 1. Clone the repository
git clone https://github.com/tu-usuario/godev.git
cd godev

# 2. Make executable
chmod +x godev

# 3. Add to PATH (optional)
# Add to ~/.zshrc:
export PATH="$HOME/path/to/godev:$PATH"
```

## 📖 Usage

### Navigate to Projects

```bash
# Navigate to a project (default command)
godev nav react
godev react              # Same (nav is default)

# Multiple matches show interactive menu
godev api

# Force create new project (when not in readonly mode)
godev nav new-project -f
```

### Check Project Status

```bash
# Show all project statuses
godev status

# Show only active projects (last 7 days)
godev status -f 7

# Sort by activity
godev status -s activity

# Sort by name
godev status -s name

# Show all projects including non-Git
godev status -a

# Custom directory
godev status -d ~/Projects
```

### List All Projects

```bash
godev list
```

### Check AI Tools Status

```bash
# Check installed AI development tools
godev ai-status

# Scan all projects for AI context files
godev ai-status --all
```

## 🎯 Features

### Navigation
- **Fast search** - Find projects instantly
- **Interactive selection** - Choose from multiple matches
- **Nested support** - Works with organizational folders (e.g., `company/project`)
- **Smart exclusions** - Skips `node_modules`, `dist`, `build`, etc.

### Status Monitoring
- **Git activity** - See last commit, branch, and status
- **Activity indicators** - Visual indicators for project activity
- **Filtering** - Show only active projects
- **Sorting** - By date, name, or activity level
- **Summary stats** - Overview of all projects

### AI Integration
- **Tool detection** - Detects Gemini CLI, Cursor, Windsurf, etc.
- **Context files** - Finds `.gemini`, `AGENTS.md`, `.cursorrules`, etc.
- **Setup assistance** - Helps configure AI context files

## 📋 Requirements

- **ZSH** (Z Shell) - Required, will NOT work with Bash
- **Git** - For status monitoring features
- **macOS/Linux** - Tested on macOS, should work on Linux

## 🛠️ Commands

| Command | Description | Alias |
|---------|-------------|-------|
| `godev nav <pattern>` | Navigate to project | `godev <pattern>`, `godev n` |
| `godev status [options]` | Show project status | `godev s`, `godev stats` |
| `godev list` | List all projects | `godev l` |
| `godev ai-status` | Check AI tools | `godev ai` |
| `godev help` | Show help | `godev h` |
| `godev version` | Show version | `godev v` |

## 🆚 Why godev vs alternatives?

| Feature | godev | fzf | autojump | z |
|---------|-------|-----|----------|---|
| Git activity | ✅ | ❌ | ❌ | ❌ |
| Zero config | ✅ | ⚠️ | ⚠️ | ⚠️ |
| Beautiful UI | ✅ | ⚠️ | ❌ | ❌ |
| Project health | ✅ | ❌ | ❌ | ❌ |
| Interactive mode | ✅ | ✅ | ❌ | ❌ |
| Fast navigation | ✅ | ✅ | ✅ | ✅ |
| AI tool detection | ✅ | ❌ | ❌ | ❌ |
| Dependencies | None | fzf | Python | None |

**godev** combines the best of all worlds:
- Fast navigation like `z`/`autojump`
- Interactive selection like `fzf`
- Git insights you won't find elsewhere
- AI tool integration
- Beautiful output that makes you smile 😊

## 📚 Documentation

- [Full Documentation](docs/RUNBOOK.md)
- [Contributing Guide](CONTRIBUTING.md)
- [Changelog](CHANGELOG.md)

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📝 License

Licensed under the Apache License 2.0 - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with ❤️ for developers who manage multiple projects
- Inspired by tools like `fzf`, `autojump`, and `z`

---

**Made with ❤️ by [Augusto Sosa Escalada](https://github.com/tu-usuario)**

