# 🚀 godev - Quick Start Guide

Get productive with godev in 5 minutes.

---

## ⚡ Installation (30 seconds)

### One command installation:

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USER/godev/main/install.sh | zsh
```

**What happens:**
1. ✅ Downloads godev
2. ✅ Installs to `~/.local/bin`
3. ✅ Adds wrapper function to `~/.zshrc`
4. ✅ Configures base directory
5. ✅ Ready to use!

### During installation you'll see:

```
   __ _  ___     __| | _____   __
  / _` |/ _ \   / _` |/ _ \ \ / /
 | (_| | (_) | | (_| |  __/\ V / 
  \__, |\___/   \__,_|\___| \_/  
  |___/                           
  
  Demystify Your Development Tree
  Navigate 100+ projects in seconds ⚡

godev installer v1.0.0

[1/10] Verificando ZSH...
✓ ZSH detectado

[2/10] Verificando FZF...
✓ FZF instalado

...

✓ ¡Instalación completada!
```

**Important:** If you don't have FZF, install it for best experience:
```bash
# macOS
brew install fzf

# Ubuntu/Debian
sudo apt install fzf
```

---

## 🎯 First Steps

### 1. Reload your shell

```bash
source ~/.zshrc
```

### 2. Verify installation

```bash
godev --version
```

You should see:
```
godev version 1.0.0
```

### 3. Your first command

```bash
godev --list
```

This shows all your development projects:

```
PROJECT                        LAST COMMIT          BRANCH          STATUS       ACTIVITY (30d)
────────────────────────────────────────────────────────────────────────────────────────────────────
webapp                        2 hours ago         main           ● modified   ●●● (35)
api-backend                   1 day ago           develop        ✓ clean      ●●○ (12)
mobile-app                    1 week ago          feature/auth   ✓ clean      ●○○ (4)
────────────────────────────────────────────────────────────────────────────────────────────────────
Summary:
    Total projects: 3
    Git repositories: 3
    Modified: 1
```

**Legend:**
- `●●●` = Very active (20+ commits)
- `●●○` = Active (5-20 commits)
- `●○○` = Some activity (1-5 commits)
- `○○○` = Inactive (0 commits)
- `● modified` = Has uncommitted changes
- `✓ clean` = No pending changes

---

## 💡 Basic Usage

### Navigate to a project

```bash
godev webapp
```

**Result:**
```
✓ You're in webapp
$ pwd
/home/user/dev/webapp
```

**That's it!** You're now in your project directory.

---

### Search for projects

Don't remember the exact name? Just type part of it:

```bash
godev web
```

**If one match:**
```
✓ You're in webapp
```

**If multiple matches:**
```
Múltiples proyectos encontrados con 'web':

┌─────────────────────────────────────────────────────────
 1) webapp                [main - ✓]
 2) web-api               [develop - ●]
 3) website-old           [main - ✓]
└─────────────────────────────────────────────────────────

Selecciona un número (1-3) o Enter para cancelar: 1

✓ Seleccionado: webapp
✓ You're in webapp
```

---

### Interactive mode (with FZF)

Simply type:

```bash
godev
```

**Opens beautiful fuzzy finder:**

```
┌─────────────────────────────────────────────────────────────────────────┐
│ Selecciona proyecto >                                                    │
├─────────────────────────────────────────────────────────────────────────┤
│ > webapp                                                                 │
│   web-api                                                                │
│   mobile-app                                                             │
│   api-backend                                                            │
│                                                                           │
│ ↑↓ navega | Enter selecciona | Esc cancela                              │
└─────────────────────────────────────────────────────────────────────────┘

┌────────────────────────── PREVIEW ──────────────────────────┐
│ 📁 ~/dev/webapp                                              │
│                                                               │
│ Git Info:                                                     │
│ a3b2c1d - Update dependencies (2 hours ago)                  │
│                                                               │
│ Modified files:                                               │
│  M package.json                                               │
│  M src/components/App.tsx                                     │
└───────────────────────────────────────────────────────────────┘
```

**Features:**
- Type to filter in real-time
- See git info before selecting
- Arrow keys to navigate
- Enter to select
- Esc to cancel

---

## 🎨 Visual Workflow

### Typical Day with godev

```
Morning:
┌─────────────────────────────────────┐
│ $ godev --list --modified 1         │
│                                      │
│ See what you worked on yesterday    │
│ ● webapp      (main - modified)     │
│ ● api-backend (develop - modified)  │
└─────────────────────────────────────┘
         ↓
┌─────────────────────────────────────┐
│ $ godev webapp                       │
│                                      │
│ Jump to first project                │
│ ✓ You're in webapp                  │
└─────────────────────────────────────┘
         ↓
┌─────────────────────────────────────┐
│ Work on webapp...                    │
│ $ git status                         │
│ $ npm run dev                        │
└─────────────────────────────────────┘

Afternoon - Context Switch:
┌─────────────────────────────────────┐
│ $ godev api                          │
│                                      │
│ ✓ You're in api-backend             │
└─────────────────────────────────────┘
         ↓
┌─────────────────────────────────────┐
│ Work on api-backend...               │
│ $ git pull                           │
│ $ npm test                           │
└─────────────────────────────────────┘

End of Day:
┌─────────────────────────────────────┐
│ $ godev --list                       │
│                                      │
│ Review all project states            │
│ See what has uncommitted changes     │
└─────────────────────────────────────┘
```

---

## 🔥 Power User Tips (Day 1)

### Tip 1: Fuzzy matching is smart

```bash
# All of these work:
godev web
godev webapp
godev app
godev wa
```

**godev finds:** `webapp`, `web-api`, `my-web-app`, etc.

---

### Tip 2: Create projects on-the-fly

```bash
godev new-project
```

**Result:**
```
⚠ Proyecto 'new-project' no encontrado

¿Crear nuevo proyecto 'new-project' en ~/dev? (s/N): s

✓ Proyecto creado
✓ You're in new-project

$ ls -la
total 0
drwxr-xr-x  2 user  staff   64 Jan  1 10:00 .
drwxr-xr-x 50 user  staff 1600 Jan  1 10:00 ..
```

**Now you can:**
```bash
git init
npm init -y
code .
```

---

### Tip 3: Check recent activity

```bash
# What did I work on this week?
godev --list --modified 7
```

```
PROJECT                        LAST COMMIT          BRANCH          STATUS       ACTIVITY (30d)
────────────────────────────────────────────────────────────────────────────────────────────────────
webapp                        2 hours ago         main           ● modified   ●●● (35)
api-backend                   1 day ago           develop        ● modified   ●●○ (12)
mobile-app                    5 days ago          feature/new    ✓ clean      ●○○ (3)
```

**Perfect for:**
- Sprint planning
- Standup prep
- Time tracking
- Remembering what you did

---

### Tip 4: Get help anytime

```bash
godev --help
```

Shows full command reference.

---

## 🎯 Common Workflows

### Workflow 1: Start your work day

```bash
# 1. See what needs attention
godev --list --modified 1

# 2. Jump to most urgent project
godev urgent-project

# 3. Start working
git pull
npm run dev
```

**Time:** 10 seconds vs 5 minutes of "where was that folder?"

---

### Workflow 2: Context switching

```bash
# Working on frontend
godev webapp

# Client calls about API
godev api    # ⚡ Instant switch

# Back to frontend
godev web    # ⚡ Back instantly
```

**No more `cd ../../../somewhere/else`**

---

### Workflow 3: Code review prep

```bash
# See all projects and their states
godev --list

# Identify projects with uncommitted changes
# (marked with ●)

# Check each one
godev project-with-changes
git status
```

---

### Workflow 4: Finding old projects

```bash
# All projects with "old" or "legacy"
godev old
godev legacy

# Or use list
godev --list | grep old
```

---

## 🛠️ Configuration

### View your config

```bash
cat ~/.config/godev/config
```

```bash
GODEV_BASE_DIR="/home/user/dev"
GODEV_FZF_ENABLED="true"
GODEV_CACHE_TTL=3600
```

### Reconfigure

```bash
godev --setup
```

**Change:**
- Base directory
- FZF integration
- Cache settings

---

## 🐛 Troubleshooting (Quick Fixes)

### Problem: "command not found: godev"

**Solution:**
```bash
# Reload shell
source ~/.zshrc

# If still not working, check PATH
echo $PATH | grep ".local/bin"

# Add to PATH if missing (installer should do this)
export PATH="$HOME/.local/bin:$PATH"
```

---

### Problem: godev doesn't change directory

**Solution:**
```bash
# Make sure wrapper function exists
type godev

# Should show: "godev is a shell function..."
# If not, run:
godev --setup
```

---

### Problem: FZF not working

**Solution:**
```bash
# Install FZF
brew install fzf  # macOS
sudo apt install fzf  # Ubuntu

# Reconfigure
godev --setup
```

---

## 📚 Next Steps

Now that you're set up:

1. **Read the full README** → [README.md](README.md)
   - All features explained
   - Advanced usage
   - Configuration options

2. **Check real examples** → [EXAMPLES.md](EXAMPLES.md)
   - 8+ real-world scenarios
   - Industry-specific workflows
   - Power user tips

3. **Learn multiple match selection** → [MULTIPLE_MATCHES.md](MULTIPLE_MATCHES.md)
   - Detailed guide on fuzzy matching
   - Selection strategies
   - Edge cases

4. **Test thoroughly** → [TESTING.md](TESTING.md)
   - Comprehensive test guide
   - Edge cases
   - Performance testing

---

## 🎓 5-Minute Challenge

Can you complete these tasks?

- [ ] ✓ Install godev
- [ ] ✓ Run `godev --list`
- [ ] ✓ Navigate to a project with `godev <name>`
- [ ] ✓ Try fuzzy search with partial name
- [ ] ✓ Create a new project
- [ ] ✓ Use interactive mode (if FZF installed)
- [ ] ✓ Check projects modified today

**Congratulations! You're now a godev user.** 🎉

---

## 💬 Get Help

- 📖 **Documentation**: [README.md](README.md)
- 🐛 **Issues**: [GitHub Issues](https://github.com/YOUR_USER/godev/issues)
- 💡 **Discussions**: [GitHub Discussions](https://github.com/YOUR_USER/godev/discussions)
- 📧 **Email**: your.email@example.com

---

<div align="center">

**Welcome to godev! Navigate 100+ projects in seconds.** ⚡

**Made with ❤️ for developers who value their time**

[Full Documentation](README.md) • [Examples](EXAMPLES.md) • [GitHub](https://github.com/YOUR_USER/godev)

</div>
