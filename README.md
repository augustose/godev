<div align="center">

# 🚀 godev

### Navigate 100+ projects in seconds. Demystify your development tree.

[![Version](https://img.shields.io/badge/version-2.1.11-blue.svg)](https://github.com/augustose/godev/releases)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![ZSH](https://img.shields.io/badge/shell-ZSH-1f425f.svg)](https://www.zsh.org/)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey.svg)](#)

**Lightning-fast project navigation** • **Git-aware** • **Zero configuration** • **FZF-powered**

[Quick Start](#-quick-start) • [Features](#-features) • [Installation](#-installation) • [Usage](#-usage) • [Documentation](#-documentation)

</div>

---

## 🎯 The Problem

Managing dozens or hundreds of development projects is chaos:

```bash
# The old way 😫
cd ~/dev
ls
cd some-project... wait, which one?
cd ../
ls | grep "web"
cd webapp... or was it web-app?
# ... 5 minutes later ...
pwd
```

**There has to be a better way.**

## ✨ The Solution

```bash
# The godev way 🚀
godev web
```

**Instant results** with beautiful, interactive selection:

<div align="center">

```
┌─────────────────────────────────────────────────────────
 1) webapp                [main - ✓]         ●●● (45 commits)
 2) web-api               [develop - ●]      ●●○ (12 commits)
 3) website-redesign      [feature/new - ✓]  ●○○ (3 commits)
 4) webserver-old         [no git]           ○○○
└─────────────────────────────────────────────────────────

Selecciona: 1
✓ You're in webapp
```

</div>

**One command. Zero friction. Maximum productivity.**

---

## ⚡ Quick Start

### One-line installation

```bash
curl -fsSL https://raw.githubusercontent.com/augustose/godev/main/installer.sh | zsh
```

That's it! Start using immediately:

```bash
godev                # Interactive fuzzy finder
godev myproject      # Jump to project instantly
godev --list         # See all projects with Git info
```

---

## 🎨 Features

<table>
<tr>
<td width="50%">

### 🔍 **Smart Search**
- Fuzzy project matching
- Case-insensitive search
- Multi-match interactive selection
- Powered by [**FZF**](https://github.com/junegunn/fzf)

### 📊 **Git Intelligence**
- Branch and status at a glance
- Commit activity tracking (30 days)
- Modified files detection
- Works with non-Git projects too

</td>
<td width="50%">

### ⚡ **Lightning Fast**
- Navigate in milliseconds
- Efficient project scanning
- Handles 500+ projects easily
- Minimal resource usage

### 🎯 **Zero Config**
- Works out of the box
- Auto-detects project structure
- One-line installation
- Intelligent defaults

</td>
</tr>
</table>

### 🌟 Powered by FZF

godev integrates seamlessly with [**junegunn/fzf**](https://github.com/junegunn/fzf), the legendary command-line fuzzy finder with **60k+ stars**. FZF provides:

- ⚡ Blazing-fast interactive filtering
- 🎨 Beautiful, customizable UI
- 📋 Live preview with Git info
- ⌨️ Intuitive keyboard navigation

> **Note:** godev works without FZF, but the experience is *premium* with it. We highly recommend installing FZF for the best experience.

---

## 📦 Installation

### Automatic (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/augustose/godev/main/installer.sh | zsh
```

**What it does:**
- ✅ Installs godev to `~/.local/bin`
- ✅ Configures ZSH wrapper function
- ✅ Detects and integrates with FZF
- ✅ Sets up your projects directory
- ✅ Creates backups automatically

### Manual Installation

<details>
<summary>Click to expand manual installation steps</summary>

```bash
# 1. Download the script
mkdir -p ~/.local/bin
curl -fsSL https://raw.githubusercontent.com/augustose/godev/main/godev -o ~/.local/bin/godev
chmod +x ~/.local/bin/godev

# 2. Add wrapper function to ~/.zshrc
cat >> ~/.zshrc << 'EOF'

# godev - Function wrapper
godev() {
    local result
    if [[ "$1" =~ ^- ]]; then
        command ~/.local/bin/godev "$@"
        return $?
    fi
    result=$(command ~/.local/bin/godev "$@")
    local exit_code=$?
    if [[ $exit_code -eq 0 ]] && [[ -d "$result" ]]; then
        cd "$result"
    else
        echo "$result"
        return $exit_code
    fi
}
EOF

# 3. Reload and configure
source ~/.zshrc
godev --setup
```

</details>

### Installing FZF (Optional but Recommended)

```bash
# macOS
brew install fzf

# Ubuntu/Debian
sudo apt install fzf

# Fedora
sudo dnf install fzf
```

---

## 🚀 Usage

### Basic Commands

```bash
# Navigation
godev                     # Interactive fuzzy finder (with FZF)
godev <project>           # Jump to project
godev <partial-name>      # Fuzzy search with selection

# Listing
godev --list              # List ALL projects with Git stats
godev -l                  # Short form
godev <pattern> -l        # List projects matching pattern

# Other
godev --setup             # Configure or reconfigure
godev --version, -v       # Show version
godev --help, -h          # Show help
```

### Real-World Examples

#### Example 1: Quick Navigation

```bash
$ godev react

Múltiples proyectos encontrados con 'react':

 1) react-dashboard         [main - ✓]         ●●● (45 commits)
 2) react-native-app        [develop - ●]      ●●○ (12 commits)
 3) react-admin-panel       [feature/auth - ✓] ●○○ (3 commits)

Selecciona: 2
✓ You're in react-native-app
```

#### Example 2: List All Projects

```bash
$ godev -l
# or
$ godev --list

PROJECT                    LAST COMMIT      BRANCH       STATUS       ACTIVITY (30d)
─────────────────────────────────────────────────────────────────────────────────────
godev                     5 hours ago      main         ● modified   ●●● (35)
webapp                    2 days ago       develop      ✓ clean      ●●○ (12)
api-backend               1 week ago       main         ✓ clean      ●○○ (4)
mobile-app                3 weeks ago      feature/auth ● modified   ○○○ (0)
```

#### Example 2b: **NEW** - List Projects by Pattern

```bash
$ godev web -l

Proyectos que coinciden con 'web':

PROJECT                  LAST COMMIT      BRANCH       STATUS       ACTIVITY (30d)
────────────────────────────────────────────────────────────────────────────────
webapp                  2 hours ago      main         ● modified   ●●● (45)
web-api                 1 day ago        develop      ✓ clean      ●●○ (12)
website-redesign        3 days ago       feature/new  ✓ clean      ●○○ (3)

Total: 3 proyecto(s)
```

#### Example 3: Interactive Mode with FZF

```bash
$ godev

# Opens beautiful FZF interface with:
# - Live fuzzy search
# - Real-time preview
# - Git status and commits
# - Keyboard navigation (↑↓ arrows, Enter to select)
```

#### Example 4: Create New Project

```bash
$ godev my-new-project

⚠ Proyecto 'my-new-project' no encontrado

¿Crear nuevo proyecto 'my-new-project' en ~/dev? (s/N): s

✓ Proyecto creado
✓ You're in my-new-project
```

---

## 📊 Git Information

godev shows rich Git information for each project:

| Indicator | Meaning |
|-----------|---------|
| `✓` | Clean working tree |
| `●` | Modified files (uncommitted changes) |
| `●●●` | High activity (20+ commits in 30 days) |
| `●●○` | Medium activity (5-20 commits) |
| `●○○` | Low activity (1-5 commits) |
| `○○○` | No recent activity |
| `NO_GIT` | Not a Git repository |

---

## ⚙️ Configuration

Edit `~/.config/godev/config`:

```bash
GODEV_BASE_DIR="/home/user/dev"    # Your projects directory
GODEV_FZF_ENABLED="true"            # Enable FZF integration
```

---

## 🎓 Advanced Usage

### Filtering Project Lists

**NEW:** Use the `-l` flag with a pattern for built-in filtering:

```bash
# List projects matching pattern
godev web -l              # Projects with "web"
godev api -l              # Projects with "api"
godev alithya -l          # Projects in "alithya" folder

# Quick check before navigating
godev webapp -l           # See status of webapp
godev webapp              # Then navigate to it
```

You can also use `grep` for more complex filtering:

```bash
# Only Git repositories
godev -l | grep -v "NO_GIT"

# Only modified projects
godev -l | grep "modified"

# Combine filters
godev -l | grep -v "NO_GIT" | grep "modified"
```

### Combine with Other Tools

```bash
# Open in VS Code after navigating
godev webapp && code .

# Check Git status
godev api && git status

# Start dev server
godev frontend && npm run dev

# Create aliases for common projects
alias gw="godev webapp"
alias ga="godev api-backend"
```

---

## 🏗️ Architecture

godev uses a unique **two-part architecture** to enable directory changes in the parent shell:

1. **ZSH Wrapper Function** (in `~/.zshrc`)
   - Intercepts godev commands
   - Executes `cd` in the current shell
   - Handles flag-based commands differently

2. **Main Script** (`~/.local/bin/godev`)
   - Project scanning and filtering
   - Git information extraction
   - FZF integration
   - Configuration management

This design allows godev to actually change your shell's directory, which is impossible for a standalone script.

---

## 🚄 Performance

Benchmarks on a laptop with 127 projects:

| Operation | Time | Notes |
|-----------|------|-------|
| Navigate to project | <100ms | Instant |
| List all projects | ~2s | Real-time scan |
| Fuzzy search | <50ms | Real-time |

**Tested with 500+ projects** - still blazing fast! ⚡

---

## 🤖 AI Development Ready

Perfect for modern AI-assisted development workflows:

- **Clear structure** - AI tools understand your project layout
- **Fast context switching** - Jump between projects instantly
- **Rich metadata** - Git info helps AI understand project state
- **Scriptable** - Easy to integrate with AI workflows

Works great with:
- [GitHub Copilot](https://github.com/features/copilot)
- [Claude Code](https://claude.ai/code)
- [Cursor](https://cursor.sh/)
- [Aider](https://github.com/paul-gauthier/aider)

---

## 🛠️ Requirements

### Required
- **ZSH** - The Z shell (default on macOS, available on all Linux distros)
- **Git** - For repository information

### Recommended
- **[FZF](https://github.com/junegunn/fzf)** - For beautiful interactive mode ⭐

### Platforms
- ✅ macOS (Intel & Apple Silicon)
- ✅ Linux (Ubuntu, Debian, Fedora, Arch, etc.)
- ✅ WSL2 (Windows Subsystem for Linux)

---

## 🐛 Troubleshooting

<details>
<summary><strong>Command not found: godev</strong></summary>

1. Check installation:
```bash
ls -la ~/.local/bin/godev
```

2. Check PATH:
```bash
echo $PATH | grep ".local/bin"
```

3. Reload shell:
```bash
source ~/.zshrc
```
</details>

<details>
<summary><strong>godev doesn't change directory</strong></summary>

You need the wrapper function in `~/.zshrc`. Run:
```bash
godev --setup
```

Or reinstall:
```bash
curl -fsSL https://raw.githubusercontent.com/augustose/godev/main/installer.sh | zsh
```
</details>

<details>
<summary><strong>FZF not working</strong></summary>

Install FZF:
```bash
brew install fzf  # macOS
sudo apt install fzf  # Ubuntu
```

Then reconfigure:
```bash
godev --setup
```
</details>

<details>
<summary><strong>Colors not showing correctly</strong></summary>

Make sure you're using a terminal that supports ANSI colors. Most modern terminals do. If using tmux, add to `~/.tmux.conf`:
```
set -g default-terminal "screen-256color"
```
</details>

---

## 🤝 Contributing

Contributions are welcome! Here's how:

1. Fork the repo
2. Create your feature branch: `git checkout -b feature/amazing`
3. Test thoroughly
4. Commit your changes: `git commit -m 'feat: Add amazing feature'`
5. Push to the branch: `git push origin feature/amazing`
6. Open a Pull Request

### Development Setup

```bash
# Clone repo
git clone https://github.com/augustose/godev.git
cd godev

# Test locally
zsh installer.sh

# Make changes to godev script
# Test your changes
~/.local/bin/godev --version
```

---

## 📚 Documentation

- **Architecture** - See [architecture.md](architecture.md) for detailed design
- **Testing** - See [testing_guide.md](testing_guide.md) for testing procedures
- **Examples** - See [examples.md](examples.md) for more use cases

---

## 🙏 Acknowledgments

- **[FZF](https://github.com/junegunn/fzf)** by [@junegunn](https://github.com/junegunn) - The incredible fuzzy finder that powers godev's interactive mode
- **ZSH Community** - For the best shell
- All contributors and users who make godev better

---

## 📄 License

MIT License - Use freely, modify, distribute.

See [LICENSE](LICENSE) file for details.

---

## ⭐ Star History

If godev saves you time, give it a star! ⭐

It helps other developers discover this tool.

---

<div align="center">

**Made with ❤️ for developers who value their time**

**Navigate 100+ projects in seconds. Make sense of complexity.**

[⬆ Back to Top](#-godev)

</div>
