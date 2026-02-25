# Enterprise AI-Agents Knowledge Base

A centralized, standardized repository of **Rules**, **Skills**, and **Workflows** designed to empower AI agents with senior-level professional engineering capabilities. Optimized for modern full-stack development using Clean Architecture, Event-Driven patterns, and Agile methodologies.

## 🚀 Core Philosophy

This repository transforms AI agents from simple code assistants into **Senior Engineering Partners**. It achieved this through a strict separation of concerns:
- **Expertise (Skills)**: High-level strategic knowledge and professional personas.
- **Constraints (Rules)**: Enforceable technical standards and project-specific mandates (The "Teeth").
- **Process (Workflows)**: Standardized delivery lifecycles for predictable, high-quality outcomes.

---

## 📂 Repository Structure

### ⚖️ Rules (`.agents/rules/`)
Technical mandates that agents MUST follow. These define the "How" of the codebase.
- **[architecture.instructions.md](.agents/rules/architecture.instructions.md)**: Clean Architecture layering, Dual-ID system, and Event-Driven mandates.
- **[business_logic.instructions.md](.agents/rules/business_logic.instructions.md)**: DDD patterns, Use Case orchestration, and Domain Event standards.
- **[infrastructure.instructions.md](.agents/rules/infrastructure.instructions.md)**: Database persistence (TypeORM/SQL/NoSQL) and external integration patterns.
- **[testing.instructions.md](.agents/rules/testing.instructions.md)**: AAA pattern, TDD, and automated validation standards.
- **[frontend.instructions.md](.agents/rules/frontend.instructions.md)**: React/Next.js (RSC), Vue, Astro, SSR/CSR, and Design System mandates.
- **[typescript.instructions.md](.agents/rules/typescript.instructions.md)** / **[java.instructions.md](.agents/rules/java.instructions.md)**: Language-specific type safety and coding standards.

### 🧠 Skills (`.agents/skills/`)
Expert personas that guide the agent's problem-solving approach.
- **System Architect**: Specialist in distributed systems, scalability, and loose coupling.
- **Database Architect**: Expert in polyglot persistence, migrations, and performance.
- **Software Engineer**: Focus on Clean Code, SOLID, and business value.
- **Frontend Architect**: Senior expert in UI engineering, modern frameworks, and Design Systems.
- **QA Expert**: Expert in testing pyramids, contract testing, and quality culture.

### 🔄 Workflows (`.agents/workflows/`)
Step-by-step lifecycles for end-to-end delivery.
- **[full-lifecycle-delivery.md](.agents/workflows/full-lifecycle-delivery.md)**: The master orchestrator for enterprise projects.
- **[ba-requirement-analysis.md](.agents/workflows/ba-requirement-analysis.md)**: Agile story mapping and MVP slicing.
- **[dev-implementation.md](.agents/workflows/dev-implementation.md)**: Iterative implementation and CI/CD alignment.
- **[qa-testing.md](.agents/workflows/qa-testing.md)**: Acceptance-based verification and regression safety.

---

## 🛠 Strategic Implementation Patterns

### 1. Clean Architecture & DDD
Strict layering: **Presentation → Application → Domain ← Infrastructure**. We prioritize the Domain as the core, with zero external dependencies.

### 2. Reliable Event-Driven Communications
- **Transactional Outbox**: Ensures atomic updates between DB and Event Bus.
- **Idempotency**: Strict mandate for all event handlers to handle duplicate messages safely.
- **Decoupling**: No direct cross-module service calls; only Domain Events.

### 3. Dependency Injection (DI)
- **Interface-First**: Mandated injection of interfaces over concrete classes.
- **constructor-based DI**: Ensure testability and clear dependency graphs.

### 4. Agile Delivery
- **Iterative Approach**: Focus on one User Story at a time.
- **Definition of Done (DoD)**: Objective success criteria for every increment.
- **Acceptance Criteria (AC)**: Gherkin-style testable requirements.

---

## 📖 How to Use for AI Agents

When initialized in this workspace, agents should:
1.  **Read `antigravity.md`**: Load the central rule index.
2.  **Adopt Skills**: Assume relevant personas based on the task (e.g., QA for testing).
3.  **Follow Workflows**: Call the appropriate lifecycle workflow (BA, Dev, or QA) as the very first step of work.
4.  **Enforce Rules**: Validate every code change against the instruction files in `.agents/rules/`.

---

**Last Updated**: February 2026
**Status**: Production Ready for AI-Assisted Engineering
