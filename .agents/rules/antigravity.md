---
trigger: always_on
priority: "critical"
---

# AI-Agents Rules System

This file provides a complete reference to all development rules across the multi-codebase workspace. Rules are organized by category and apply to specific file patterns.

## Core Architecture & Patterns

These rules apply to all projects and define the foundational structure.

### @architecture.instructions.md

Universal Clean Architecture rules - layering principles, dependency direction, module structure for all languages.
**Applies to**: `src/**/*`

### @business_logic.instructions.md

Domain-driven design patterns - use cases, domain events, exception handling, validation patterns.
**Applies to**: `src/modules/**/*`, `src/**/application/**/*`, `src/**/domain/**/*`

### @infrastructure.instructions.md

External integration patterns - repositories, external APIs, messaging, database operations.
**Applies to**: `src/**/infrastructure/**/*`, `src/**/database/**/*`

### @error-codes.instructions.md

Standardized error codes and exception handling - error code categories (AUTH*, VAL*, BIZ*, INF*, SYS*), HTTP status codes, recovery actions, implementation examples.
**Applies to**: `src/**/{exceptions,errors}/**/*`, `src/**/*.exception.ts`, `src/**/*.error.ts`

### @testing.instructions.md

Testing standards & patterns - AAA structure, mocking strategies, NestJS integration/E2E setups, test database lifecycle, and data factories.
**Applies to**: `**/*.spec.ts`, `**/*.test.ts`

---

## Language-Specific Rules

Select the rule matching your primary development language.

### TypeScript/Node.js/NestJS

### @typescript.instructions.md

Type safety, NestJS patterns, module structure, decorators, middleware.
**Applies to**: `**/*.{ts,tsx}` in omi-channel-be, findtourgoUI, packageTourAdmin

### Java (Spring Boot / Quarkus)

### @java.instructions.md

Spring Boot patterns, annotations, dependency injection, generics, error handling.
**Applies to**: `**/*.java` in crm_be, packageTourApi

### Go

### @golang.instructions.md

Interfaces, error handling, concurrency patterns, struct composition.
**Applies to**: `**/*.go` (reference for future services)

### Rust

### @rust.instructions.md

Ownership system, Result types, trait-based design, async/await patterns.
**Applies to**: `**/*.rs` (reference for future services)

### Python

### @python.instructions.md

Type hints, best practices, virtual environments, testing patterns.
**Applies to**: `**/*.py` (reference for utilities/scripts)

### Dart

### @dart.instructions.md

Classes, async patterns, null safety, Flutter conventions.
**Applies to**: `**/*.dart` (reference if needed)

### C

### @c.instructions.md

Memory management, C conventions, header organization, build patterns.
**Applies to**: `**/*.{c,h}` (reference if needed)

## Global Rules

### @global.instructions.md

Global development standards applying to all languages and all workspaces.
**Applies to**: Everything

## How to Use These Rules

1. **Always-On**: Rules with `trigger: always_on` apply to all matching file patterns automatically
2. **Language Selection**: When working in a specific language, load that language-specific rule file
3. **Architecture First**: Start with architecture rules to understand the overall structure
4. **Error Handling**: Reference error-codes rules when implementing exceptions
5. **Testing**: Consult testing rules before writing or reviewing tests
6. **Cross-References**: Use @mentions to reference other rule files as needed

## Rule Priority

**CRITICAL (Always Apply)**:

- `error-codes.instructions.md` - Standardized error handling across all services
- `architecture.instructions.md` - Clean Architecture layering

**HIGH (Engineering/Language)**:

- `testing.instructions.md` - Testing standards
- `typescript.instructions.md` (for NestJS projects)
- `java.instructions.md` (for Spring Boot projects)
- `golang.instructions.md` (for Go services)
- `rust.instructions.md` (for Rust services)

**MEDIUM (Domain-Specific)**:

- `business_logic.instructions.md` - Use case patterns
- `infrastructure.instructions.md` - Integration patterns

**REFERENCE (As Needed)**:

- `python.instructions.md` - Utilities/scripts
- `dart.instructions.md` - Mobile/Flutter
- `c.instructions.md` - Low-level components

## Quick Navigation

**For TypeScript/NestJS Development**:

1. @typescript.instructions.md (primary)
2. @error-codes.instructions.md
3. @architecture.instructions.md
4. @business_logic.instructions.md
5. @testing.instructions.md

**For Java Development**:

1. @java.instructions.md (primary)
2. @error-codes.instructions.md
3. @architecture.instructions.md
4. @infrastructure.instructions.md
5. @testing.instructions.md

**For Setting Up New Module**:

1. @architecture.instructions.md
2. @business_logic.instructions.md
3. Language-specific rule
4. @error-codes.instructions.md
5. @testing.instructions.md

**For Error Handling**:

1. @error-codes.instructions.md (always)
2. Language-specific exceptions section
3. @business_logic.instructions.md (exception patterns)

## File Character Limit

Each rule file is limited to 12,000 characters. If a rule exceeds this, it will be split into multiple files with cross-references using @mentions.

---

**Last Updated**: February 2026
**System**: Antigravity-Compatible Rules Reference
**Status**: Production Ready
