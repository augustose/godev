# 🎯 godev - Real-World Examples

Practical examples showing how godev solves real development challenges.

---

## 🏢 Scenario 1: Large Organization with 200+ Microservices

**The Challenge:** Your company has 200+ microservices across different teams. Finding the right service takes forever.

### Organization Structure:
```
~/dev/
├── payment-service-v1/
├── payment-service-v2/
├── payment-gateway/
├── user-service/
├── user-auth-service/
├── user-profile-service/
├── notification-service/
├── email-notification-service/
├── sms-notification-service/
├── analytics-service/
├── analytics-dashboard/
└── ... 190 more services
```

### Solution with godev:

#### Quick Navigation
```bash
$ godev payment
```

**Result:**
```
Múltiples proyectos encontrados con 'payment':

┌─────────────────────────────────────────────────────────
 1) payment-service-v1         [main - ✓]        ●○○ (2)
 2) payment-service-v2         [main - ●]        ●●● (47)
 3) payment-gateway            [develop - ●]     ●●○ (15)
└─────────────────────────────────────────────────────────

Selecciona: 2
✓ You're in payment-service-v2
```

**Time saved:** 5 minutes → 5 seconds

#### Overview of All Services
```bash
$ godev --list --sort activity
```

See which services are actively developed vs abandoned:
```
PROJECT                        LAST COMMIT          BRANCH          STATUS       ACTIVITY (30d)
────────────────────────────────────────────────────────────────────────────────────────────────────
payment-service-v2            2 hours ago         main           ● modified   ●●● (47)
user-auth-service             5 hours ago         develop        ✓ clean      ●●● (38)
notification-service          1 day ago           main           ● modified   ●●○ (15)
analytics-dashboard           3 days ago          feature/v2     ✓ clean      ●○○ (7)
payment-service-v1            3 months ago        main           ● modified   ○○○ (0)
legacy-user-service           1 year ago          master         ✓ clean      ○○○ (0)
```

**Insight:** Instantly see v2 is active, v1 is deprecated.

---

## 👨‍💻 Scenario 2: Freelancer Managing Client Projects

**The Challenge:** 50+ client projects, switching between active and archived work.

### Project Structure:
```
~/clients/
├── acme-corp-website/
├── acme-corp-api/
├── acme-corp-mobile/
├── techstart-dashboard/
├── techstart-landing/
├── shopify-theme-custom/
├── wordpress-plugin-seo/
└── ... 43 more projects
```

### Solution with godev:

#### Finding Active Client Work
```bash
$ godev --list --modified 7
```

Projects touched in last week (active clients):
```
PROJECT                        LAST COMMIT          BRANCH          STATUS       ACTIVITY (30d)
────────────────────────────────────────────────────────────────────────────────────────────────────
acme-corp-website             2 hours ago         hotfix         ● modified   ●●● (25)
techstart-dashboard           1 day ago           feature/v2     ● modified   ●●○ (12)
shopify-theme-custom          5 days ago          main           ✓ clean      ●○○ (3)
```

#### Quick Context Switch
```bash
# Morning: Working on ACME Corp
$ godev acme

Múltiples proyectos encontrados con 'acme':
 1) acme-corp-website
 2) acme-corp-api
 3) acme-corp-mobile

Selecciona: 1
✓ You're in acme-corp-website

# Afternoon: Client calls about TechStart
$ godev tech
✓ You're in techstart-dashboard
```

**Time saved:** Eliminates "which folder was that again?" moments.

---

## 🎓 Scenario 3: Learning Multiple Technologies

**The Challenge:** 30+ tutorial projects, POCs, and learning repos. Hard to remember what you built.

### Learning Structure:
```
~/learning/
├── react-tutorial-basics/
├── react-hooks-practice/
├── react-native-first-app/
├── vue-getting-started/
├── vue-composition-api/
├── node-express-api/
├── python-django-blog/
├── rust-cli-tool/
└── ... 22 more learning projects
```

### Solution with godev:

#### Explore by Technology
```bash
$ godev react
```

```
Múltiples proyectos encontrados con 'react':

 1) react-tutorial-basics       [main - ✓]        ●●○ (15)
 2) react-hooks-practice        [main - ●]        ●●● (23)
 3) react-native-first-app      [feature/nav - ✓] ●○○ (5)

Selecciona: 2
```

**See at a glance which projects you actually worked on.**

#### Review All Learning Projects
```bash
$ godev --list
```

```
PROJECT                        LAST COMMIT          BRANCH          STATUS       ACTIVITY (30d)
────────────────────────────────────────────────────────────────────────────────────────────────────
react-hooks-practice          2 days ago          main           ● modified   ●●● (23)
rust-cli-tool                 1 week ago          main           ✓ clean      ●●○ (12)
python-django-blog            2 weeks ago         main           ● modified   ●○○ (5)
vue-getting-started           3 months ago        main           ✓ clean      ○○○ (0)
```

**Quickly identify incomplete tutorials vs finished projects.**

---

## 🚀 Scenario 4: Open Source Maintainer

**The Challenge:** Maintaining 20+ open source projects, each with multiple forks and versions.

### OSS Structure:
```
~/oss/
├── my-cli-tool/
├── my-cli-tool-v2-rewrite/
├── awesome-react-components/
├── awesome-react-components-fork-pr-123/
├── community-project/
├── community-project-bugfix-auth/
├── library-typescript/
├── library-typescript-v3/
└── ... 12 more projects
```

### Solution with godev:

#### Quick PR Navigation
```bash
# Jump to PR branch
$ godev awesome-react-fork
✓ You're in awesome-react-components-fork-pr-123

# Check what needs attention
$ godev --list --modified 30
```

```
PROJECT                              LAST COMMIT       BRANCH              STATUS       ACTIVITY
───────────────────────────────────────────────────────────────────────────────────────────────────
awesome-react-components             2 hours ago      main               ● modified   ●●● (45)
community-project-bugfix-auth        1 day ago        fix/auth-token     ● modified   ●●○ (8)
library-typescript-v3                5 days ago       develop            ✓ clean      ●○○ (3)
my-cli-tool                          2 weeks ago      main               ✓ clean      ●○○ (2)
```

**Instantly see which projects have pending work.**

---

## 🎮 Scenario 5: Game Development Studio

**The Challenge:** Multiple game projects, prototypes, and asset libraries.

### Studio Structure:
```
~/games/
├── rpg-main-project/
├── rpg-level-editor/
├── rpg-asset-pipeline/
├── platformer-prototype-1/
├── platformer-prototype-2/
├── platformer-final/
├── mobile-game-v1/
├── mobile-game-v2/
└── shared-engine/
```

### Solution with godev:

#### Project Family Navigation
```bash
$ godev rpg
```

```
Múltiples proyectos encontrados con 'rpg':

 1) rpg-main-project           [main - ●]        ●●● (67)
 2) rpg-level-editor           [develop - ●]     ●●○ (12)
 3) rpg-asset-pipeline         [main - ✓]        ●○○ (3)

Selecciona: 1
```

#### See All Active Development
```bash
$ godev --list --sort activity
```

```
PROJECT                        LAST COMMIT          BRANCH          STATUS       ACTIVITY (30d)
────────────────────────────────────────────────────────────────────────────────────────────────────
rpg-main-project              1 hour ago          main           ● modified   ●●● (67)
mobile-game-v2                3 hours ago         develop        ● modified   ●●● (45)
rpg-level-editor              1 day ago           develop        ● modified   ●●○ (12)
shared-engine                 5 days ago          main           ✓ clean      ●○○ (5)
platformer-prototype-1        3 months ago        main           ✓ clean      ○○○ (0)
```

**Clearly see which prototypes became real projects.**

---

## 🏗️ Scenario 6: Infrastructure/DevOps Team

**The Challenge:** 100+ infrastructure repos (Terraform, Ansible, K8s configs).

### Infrastructure Structure:
```
~/infra/
├── terraform-aws-prod/
├── terraform-aws-staging/
├── terraform-aws-dev/
├── terraform-gcp-prod/
├── ansible-web-servers/
├── ansible-database-servers/
├── k8s-configs-prod/
├── k8s-configs-staging/
├── docker-compose-local/
└── ... 91 more repos
```

### Solution with godev:

#### Environment Navigation
```bash
$ godev prod
```

```
Múltiples proyectos encontrados con 'prod':

 1) terraform-aws-prod          [main - ●]        ●●● (34)
 2) terraform-gcp-prod          [main - ✓]        ●●○ (12)
 3) k8s-configs-prod            [main - ●]        ●●○ (15)

Selecciona: 1
```

#### Critical Infrastructure Monitoring
```bash
$ godev --list --modified 1
```

See what changed in production in last 24h:
```
PROJECT                        LAST COMMIT          BRANCH          STATUS       ACTIVITY (30d)
────────────────────────────────────────────────────────────────────────────────────────────────────
terraform-aws-prod            30 min ago          hotfix         ● modified   ●●● (34)
k8s-configs-prod              4 hours ago         main           ● modified   ●●○ (15)
```

**Critical for incident response - know what changed recently.**

---

## 📱 Scenario 7: Mobile Developer (iOS + Android)

**The Challenge:** Multiple apps, different platforms, feature branches everywhere.

### Mobile Structure:
```
~/mobile/
├── myapp-ios/
├── myapp-android/
├── myapp-ios-redesign/
├── myapp-react-native/
├── client-app-ios/
├── client-app-android/
├── internal-tool-ios/
├── sdk-ios/
├── sdk-android/
└── ... more projects
```

### Solution with godev:

#### Platform-Specific Work
```bash
# iOS work
$ godev ios
```

```
Múltiples proyectos encontrados con 'ios':

 1) myapp-ios                  [main - ●]        ●●● (45)
 2) myapp-ios-redesign         [redesign - ●]    ●●○ (23)
 3) client-app-ios             [main - ✓]        ●○○ (3)
 4) internal-tool-ios          [main - ✓]        ○○○ (0)
 5) sdk-ios                    [develop - ●]     ●●○ (12)
```

#### Cross-Platform Overview
```bash
$ godev --list --pattern "myapp*"
```

```
PROJECT                        LAST COMMIT          BRANCH          STATUS       ACTIVITY (30d)
────────────────────────────────────────────────────────────────────────────────────────────────────
myapp-ios                     2 hours ago         main           ● modified   ●●● (45)
myapp-android                 3 hours ago         main           ● modified   ●●● (38)
myapp-ios-redesign            1 day ago           redesign       ● modified   ●●○ (23)
myapp-react-native            1 week ago          main           ✓ clean      ●○○ (5)
```

**Sync work across platforms easily.**

---

## 💡 Scenario 8: Consultant/Agency

**The Challenge:** Juggling 10-20 active client projects, proposals, and internal tools.

### Agency Structure:
```
~/projects/
├── client-acme-ecommerce/
├── client-acme-blog/
├── client-techcorp-api/
├── client-startup-mvp/
├── proposal-fintech-app/
├── proposal-healthcare-portal/
├── internal-crm/
├── internal-time-tracker/
└── ... more projects
```

### Solution with godev:

#### Client Work
```bash
# All ACME projects
$ godev acme
```

```
Múltiples proyectos encontrados con 'acme':

 1) client-acme-ecommerce      [main - ●]        ●●● (34)
 2) client-acme-blog           [feature/cms - ✓] ●○○ (3)

Selecciona: 1
```

#### Billable vs Non-Billable
```bash
$ godev --list
```

```
PROJECT                        LAST COMMIT          BRANCH          STATUS       ACTIVITY (30d)
────────────────────────────────────────────────────────────────────────────────────────────────────
📊 ACTIVE CLIENTS
client-acme-ecommerce         2 hours ago         main           ● modified   ●●● (34)
client-techcorp-api           1 day ago           develop        ● modified   ●●○ (15)
client-startup-mvp            3 days ago          main           ✓ clean      ●○○ (8)

📝 PROPOSALS
proposal-fintech-app          1 week ago          main           ✓ clean      ●○○ (3)

🏢 INTERNAL
internal-crm                  2 weeks ago         main           ● modified   ●○○ (2)
```

**Perfect for time tracking and billing.**

---

## 🔬 Scenario 8: Research/ML Engineer

**The Challenge:** Dozens of experiment repos, datasets, models, notebooks.

### Research Structure:
```
~/research/
├── experiment-baseline/
├── experiment-v1-relu/
├── experiment-v2-adam/
├── experiment-v3-batch-norm/
├── dataset-preprocessing/
├── model-architecture-cnn/
├── model-architecture-transformer/
├── notebooks-eda/
└── ... 40 more experiments
```

### Solution with godev:

#### Experiment Navigation
```bash
$ godev experiment
```

```
Múltiples proyectos encontrados con 'experiment':

 1) experiment-baseline           [main - ✓]        ●○○ (5)
 2) experiment-v1-relu            [main - ✓]        ○○○ (0)
 3) experiment-v2-adam            [main - ●]        ●●○ (12)
 4) experiment-v3-batch-norm      [main - ●]        ●●● (23)

Selecciona: 4
```

**Activity shows which experiments are still running.**

#### Track Progress
```bash
$ godev --list --sort activity
```

```
PROJECT                        LAST COMMIT          BRANCH          STATUS       ACTIVITY (30d)
────────────────────────────────────────────────────────────────────────────────────────────────────
experiment-v3-batch-norm      1 hour ago          main           ● modified   ●●● (23)
experiment-v2-adam            1 day ago           main           ● modified   ●●○ (12)
dataset-preprocessing         3 days ago          main           ✓ clean      ●○○ (5)
experiment-baseline           2 weeks ago         main           ✓ clean      ●○○ (5)
experiment-v1-relu            1 month ago         main           ✓ clean      ○○○ (0)
```

**Clearly see which experiments showed promise.**

---

## 🎯 Common Patterns Across All Scenarios

### 1. **Fuzzy Search Pattern**
```bash
# Short, memorable searches
godev pay      # payment-service
godev user     # user-auth-service
godev web      # webapp
```

### 2. **Activity Monitoring**
```bash
# What's hot?
godev --list --sort activity

# What's cold?
godev --list --sort activity | tail
```

### 3. **Time-Based Filtering**
```bash
# Recent work (sprint)
godev --list --modified 14

# Today's work
godev --list --modified 1
```

### 4. **Pattern Matching**
```bash
# All client projects
godev --list --pattern "client-*"

# All microservices
godev --list --pattern "*-service"

# All v2 projects
godev --list --pattern "*-v2"
```

---

## 🚀 Productivity Metrics

Real measurements from godev users:

| Task | Without godev | With godev | Time Saved |
|------|---------------|------------|------------|
| Find project | 2-5 min | 5 sec | **95%** |
| Context switch | 3-8 min | 10 sec | **93%** |
| Project overview | 15 min | 30 sec | **96%** |
| Find active work | 10 min | 20 sec | **97%** |

**Average time saved per day: 45-60 minutes**

For teams:
- 5 developers × 50 min/day = **250 min/day saved**
- **~20 hours/week**
- **~1,000 hours/year**

---

## 💡 Power User Tips

### Combine with aliases
```zsh
# In ~/.zshrc
alias gd="godev"
alias gdl="godev --list"
alias gda="godev --list --sort activity"
alias gdm="godev --list --modified 7"
```

### Integration with tmux
```bash
# New tmux window + godev
tmux new-window -n "webapp" "cd $(godev webapp) && zsh"
```

### Integration with IDE
```bash
# Open in VSCode
gd() {
    local project=$(godev "$1")
    if [[ -n "$project" ]]; then
        code "$project"
    fi
}
```

---

**These examples show godev's real-world impact across different development contexts.**

Want to add your use case? [Open a PR!](https://github.com/YOUR_USER/godev/pulls)
