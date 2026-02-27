# tas-agent-skills

A centralized, standardized repository of **Rules**, **Skills**, and **Workflows** designed to empower AI agents with senior-level professional engineering capabilities. Optimized for modern full-stack development using Clean Architecture, Event-Driven patterns, and Agile methodologies.

## 🎯 Core Philosophy

This repository transforms AI agents from simple code assistants into **Senior Engineering Partners**. It achieves this through a structured system of:
- **Expertise (Skills)**: Personas with deep strategic knowledge (e.g., `nestjs`, `architecture`, `ui-ux-pro-max`).
- **Constraints (Rules)**: Technical standards and project-specific mandates (e.g., `general.instructions.md`).
- **Processes (Workflows)**: Standardized delivery lifecycles (e.g., `full-lifecycle-delivery`).

---

## 📂 System Structure

### ⚖️ Rules (`.agents/rules/`)
Global technical mandates that enforce quality across the workspace.
- **[general.instructions.md](.agents/rules/general.instructions.md)**: The single source of truth for all projects. This file is symlinked to `.github/copilot-instructions.md` to ensure context consistency between Antigravity, VSCode, and GitHub Copilot.

### 🧠 Skills (`.agents/skills/`)
Expert personas and deep knowledge domains. These are loaded by name (e.g., `@nestjs`).
- **`architecture`**: Specialist in Clean Architecture, layers, and module structure.
- **`development`**: Expert in business logic, use cases, and SOLID principles.
- **`database`**: Specialist in schema design, migrations, and performance (Postgres, Mongo, Redis).
- **`ui-ux-pro-max`**: (Premium) Advanced design system generator and UI/UX reasoning engine.
- **Language Skills**: `nestjs` (TS), `java` (Spring), `golang`, `rust`, `python`, `dart`.

### 🔄 Workflows (`.agents/workflows/`)
Step-by-step lifecycles for predictable delivery.
- **`/ba-requirement-analysis`**: Story mapping and MVP slicing.
- **`/dev-implementation`**: Iterative implementation and CI/CD alignment.
- **`/qa-testing`**: Acceptance-based verification.
- **`/full-lifecycle-delivery`**: The master orchestrator for complex features.

---

## ✨ Featured: UI/UX Pro Max

The system includes a specialized **UI/UX Reasoning Engine** that uses Python-based search to generate tailored design systems:
- **67+ UI Styles**: Glassmorphism, Bento Grid, AI-Native UI, etc.
- **96+ Color Palettes**: Industry-specific for SaaS, Fintech, Healthcare.
- **Reasoning Rules**: Industry-appropriate patterns and anti-patterns.
- **Pre-delivery Checklists**: Ensuring professional quality and accessibility.

**Usage:**
```bash
python3 .agents/skills/ui-ux-pro-max/scripts/search.py "Healthcare SaaS" --design-system
```

---

## 🏗️ Technical Methodologies

### 1. Clean Architecture & DDD
Strict layering: **Presentation → Application → Domain ← Infrastructure**. We prioritize the Domain as the core, with zero external dependencies.

### 2. Event-Driven Architecture
- **Transactional Outbox**: Atomic updates between DB and Event Bus.
- **Loose Coupling**: No direct cross-module service calls; communication via Domain Events.

### 3. Multi-Tenant Isolation
- **Context-Aware**: Every request carries tenant context (company_id).
- **Security**: Mandatory tenant validation at the Application and Repository layers.

---

## 📖 How to Use

### For Antigravity & AI Agents
1. **Initialize**: The agent automatically loads `general.instructions.md`.
2. **Leverage Skills**: Call skills by name to inherit deep patterns.
3. **Follow Workflows**: Start complex tasks using slash commands (e.g., `/ba-requirement-analysis`).

### For GitHub Copilot
The system is automatically enabled via `.github/copilot-instructions.md`. To refresh context, just mention the desired skill in your prompt.

### Cross-Platform Support
The symlink between `.agents/rules/general.instructions.md` and `.github/copilot-instructions.md` uses relative paths, ensuring it works seamlessly on **macOS, Linux, and Windows**.

---

## 🛡️ Workspace Safety
- **Sandbox**: Agents are restricted to the workspace root.
- **Forbidden Paths**: No access to OS-sensitive directories or user configs.
- **Validation**: All file operations are validated against project-safe structures.

---

**Last Updated**: February 2026
**System**: tas-agent-skills (Unified AI Development Guidance)
**Status**: Production Ready
