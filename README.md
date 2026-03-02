# tas-agent

A **CLI tool** for installing AI agent skills, rules, and workflows into any project for GitHub Copilot & Antigravity.

Built in Go, cross-platform, zero dependencies. Single binary (~7MB) with embedded skills + rules + workflows.

```bash
# Install
curl -fsSL https://raw.githubusercontent.com/hiimtrung/ai-agent-ide/main/install.sh | sh
# or (Windows PowerShell)
irm https://raw.githubusercontent.com/hiimtrung/ai-agent-ide/main/install.ps1 | iex

# Use
cd /path/to/your/project
tas-agent install be        # backend
tas-agent install fe        # frontend
tas-agent install fullstack # full-stack
tas-agent update            # re-sync skills (reads last profile from manifest)
tas-agent check-update      # check for CLI updates
tas-agent self-update       # auto-upgrade to latest CLI version
```

---

## 🎯 What It Does

The **tas-agent CLI** distributes a **centralized engineering knowledge system** to your projects:

- **20+ Skills**: Language-specific expertise (NestJS, Java, Go, Python, Rust, C, Dart, React, Vue, etc.)
- **Architecture Guidance**: Clean Architecture, event-driven design, multi-tenancy patterns
- **Professional Standards**: Error codes, testing, documentation, UI/UX design systems
- **AI Agent Workflows**: BA analysis, development, QA, full lifecycle delivery
- **One-command setup**: `tas-agent install be` → project gets `.agents/` + `.github/copilot-instructions.md`

---

## 📦 Installation

### Quick Start (macOS / Linux)
```bash
curl -fsSL https://raw.githubusercontent.com/hiimtrung/ai-agent-ide/main/install.sh | sh
```

### Windows (PowerShell)
```powershell
irm https://raw.githubusercontent.com/hiimtrung/ai-agent-ide/main/install.ps1 | iex
```

### Manual Download
Download binary from [GitHub Releases](https://github.com/hiimtrung/ai-agent-ide/releases) and add to `PATH`.

### From Source
```bash
git clone https://github.com/hiimtrung/ai-agent-ide.git
cd ai-agent-ide
make build
make install-user  # or 'make install' for /usr/local/bin (requires sudo)
```

---

## 🚀 Usage

### Profiles

| Profile | For | Skills Included |
|---------|-----|---|
| `be` | Backend (NestJS, Java, Go, Python, Rust, C, Dart) | Core + language-specific |
| `fe` | Frontend (React, Next.js, Vue, Svelte, React Native) | Core + UI frameworks + design |
| `fullstack` | Full-stack projects | be + fe |
| `all` | Everything | All skills, rules, workflows |

Or install **individual skills** by name:
```bash
tas-agent install golang
tas-agent install nestjs
tas-agent install react-best-practices
```

### Commands

```bash
# Install skills to a project
tas-agent install <profile> [flags]
  --target, -t <dir>  Target directory (default: current directory)
  --force, -f         Overwrite existing files
  --dry-run           Preview without modifying

# Update installed skills (reads from manifest if no profile given)
tas-agent update [profile] [flags]
  --target, -t <dir>
  --dry-run

# List profiles and skills
tas-agent list              # all profiles + skills
tas-agent list be           # details for 'be' profile

# Version & updates
tas-agent version           # show version + commit + build date
tas-agent check-update      # check for new CLI version on GitHub
tas-agent self-update       # download and auto-upgrade CLI

# Help
tas-agent help
```

### Examples

```bash
# Install backend stack to current directory
tas-agent install be

# Install frontend to a specific path
tas-agent install fe --target ./frontend-app

# Preview without making changes
tas-agent install fullstack --dry-run --target /tmp/test

# Update all skills to latest (from last install)
cd /my/project
tas-agent update

# Update to a different profile
tas-agent update fe --force

# Check for CLI updates
tas-agent check-update
```

---

## 📂 What Gets Installed

After `tas-agent install be`, your project structure includes:

```
.agents/
  skills/
    architecture/
      SKILL.md
      rules/
        principles.md
    nestjs/
      SKILL.md
      rules/
        typescript.md
        errors.md
    golang/
      ...
    [19 more skills]
  rules/
    general.instructions.md  # unified coding standards
  workflows/
    ba-requirement-analysis.md
    dev-implementation.md
    qa-testing.md
    full-lifecycle-delivery.md
  .tas-agent.json           # manifest: version, profile, skills, installed_at

.github/
  copilot-instructions.md   # GitHub Copilot context (auto-generated from rules)
  agents/
    tas-agent.agent.md      # custom agent definition
```

**Manifest** (`.agents/.tas-agent.json`):
```json
{
  "version": "v0.1.0",
  "profile": "be",
  "skills": [
    "architecture",
    "general-patterns",
    ...
  ],
  "installed_at": "2026-03-02T03:45:34Z"
}
```

This allows `tas-agent update` to re-sync skills without specifying a profile.

---

## 🛠️ Development & Building

### Prerequisites
- Go 1.26.0+
- Make (optional, but recommended)

### Build for current platform
```bash
make build          # creates dist/tas-agent
```

### Build for all platforms
```bash
make build-all      # creates:
                    # - dist/tas-agent-darwin-amd64
                    # - dist/tas-agent-darwin-arm64
                    # - dist/tas-agent-linux-amd64
                    # - dist/tas-agent-linux-arm64
                    # - dist/tas-agent-windows-amd64.exe
```

### Create a release (push to GitHub)
```bash
make tag VERSION=v0.1.0  # creates git tag and pushes
                         # GitHub Actions automatically builds & releases
```

### Clean up
```bash
make clean
```

---

## 🔄 Continuous Integration

GitHub Actions automatically builds and releases on tag push:

1. **Trigger**: Push a tag matching `v*.*.*` (e.g., `v0.1.0`)
2. **Build**: Compiles for 5 platforms (macOS arm64/amd64, Linux arm64/amd64, Windows amd64)
3. **Release**: Creates GitHub Release with binaries, checksums, and install instructions
4. **Details**: See [.github/workflows/release.yml](.github/workflows/release.yml)

---

## 📚 Included Skills

### Core (All Profiles)
- **architecture** — Clean Architecture, layers, DDD
- **general-patterns** — Error codes, exceptions, HTTP status, cross-language patterns
- **development** — Use cases, domain events, validation
- **database** — PostgreSQL, MongoDB, Redis, migrations, repositories
- **testing** — Unit, integration, E2E, Jest, Mockito
- **docs-analysis** — Documentation standards

### Backend
- **nestjs** — NestJS, TypeScript, type safety
- **java** — Spring Boot, Gradle, enterprise patterns
- **golang** — Concurrent Go services, interfaces, idioms
- **python** — Type hints, Pydantic, Clean Architecture
- **rust** — Ownership, Result types, Actix/Axum
- **c** — Memory safety, modular development
- **dart** — Flutter, sound null safety

### Frontend
- **frontend** — UI engineering, SSR/CSR, design systems
- **react-best-practices** — React 19, Next.js performance, bundle optimization
- **react-native-skills** — React Native, Expo, mobile performance
- **composition-patterns** — Component architecture, render props, compound components
- **web-design-guidelines** — Accessibility, Web Interface Guidelines
- **ui-ux-pro-max** — Design system generator, 96+ color palettes, 67+ UI styles

---

## 🎓 System Philosophy

This is not just a skill library—it's a **unified engineering knowledge system** built for AI agents (Copilot, Antigravity, etc.):

- **Consistency**: One source of truth for architecture, error codes, and patterns
- **Reusability**: Embed the entire system into any project with a single command
- **Scalability**: 20+ skills, 99+ UX guidelines, standardized workflows
- **Autonomy**: AI agents inherit senior-level decision-making without human intervention
- **Transparency**: All rules, skills, and workflows are version-controlled and auditable

---

## 📝 License

MIT

---

## 🤝 Contributing

Issues and pull requests welcome! For major changes, open a discussion first.

---

**Last Updated**: March 2026
**System**: tas-agent (Unified AI Development Guidance CLI)
**Status**: Production Ready
**Built with**: Go 1.26.0
