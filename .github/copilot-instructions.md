---
name: global-instructions
description: Global project rules and architecture patterns (Synced from .github/copilot-instructions.md)
applyTo: "**/*"
---

# Copilot Instructions - AI-Agents Development System

This is a **unified AI Agent system** for VS Code Copilot designed to guide development across **multiple languages and frameworks** with consistent, maintainable code standards.

## 🎯 System Overview

You are working in a **multi-codebase workspace** with:

- **omi-channel-be**: NestJS multi-tenant omnichannel backend (PostgreSQL + MongoDB + Redis)
- **crm_be**: Spring Boot CRM backend
- **packageTourApi**: Java REST API
- **packageTourAdmin** & **findtourgoUI**: Next.js/React frontends
- **ai-agents**: AI development guidance system (current)

## 🛡️ Workspace Safety & Sandbox

To ensure system stability and security, the following rules apply to all AI Agent operations:

1. **Sandbox Execution**: Strictly forbid reading or modifying files outside of the defined project repositories (`/Users/trungtran/ai-agents/` and its sub-packages).
2. **Forbidden Directories**: NEVER access or write to system directories, including but not limited to: `/tmp`, `/etc`, `/var`, `/usr`, `~/.ssh`, `~/.config`, or OS-specific sensitive paths.
3. **Path Validation**: Before any `write_to_file` or `replace_file_content` operation, verify that the `TargetFile` absolute path resides within the approved workspace.
4. **Tool usage**: Only use tools on files that you have explicitly identified as part of the project structure via `list_dir` or `find_by_name`.

---

All projects follow **Clean Architecture + Event-Driven Design** with standardized error codes and patterns.

---

## 📋 Language-Specific Rules

Detailed instructions for each language are in `.agents/rules/`:

### Backend Languages

| Language       | Rules File                                                                              | Primary Projects                               |
| -------------- | --------------------------------------------------------------------------------------- | ---------------------------------------------- |
| **TypeScript** | [.agents/rules/typescript.instructions.md](../.agents/rules/typescript.instructions.md) | omi-channel-be, findtourgoUI, packageTourAdmin |
| **Java**       | [.agents/rules/java.instructions.md](../.agents/rules/java.instructions.md)             | crm_be, packageTourApi                         |
| **Go**         | [.agents/rules/golang.instructions.md](../.agents/rules/golang.instructions.md)         | (reference for future services)                |
| **Rust**       | [.agents/rules/rust.instructions.md](../.agents/rules/rust.instructions.md)             | (reference for future services)                |
| **Python**     | [.agents/rules/python.instructions.md](../.agents/rules/python.instructions.md)         | (reference for utilities/scripts)              |
| **C**          | [.agents/rules/c.instructions.md](../.agents/rules/c.instructions.md)                   | (reference, if needed)                         |
| **Dart**       | [.agents/rules/dart.instructions.md](../.agents/rules/dart.instructions.md)             | (reference, if needed)                         |

### Architecture & Domain Rules

| Topic                             | Rules File                                                                                      | Focus                                                                         |
| --------------------------------- | ----------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| **Architecture Patterns**         | [.agents/rules/architecture.instructions.md](../.agents/rules/architecture.instructions.md)     | Clean Architecture, layers, module structure, DDD                             |
| **Business Logic Patterns**       | [.agents/rules/business_logic.instructions.md](../.agents/rules/business_logic.instructions.md) | Use cases, domain events, exception handling                                  |
| **Infrastructure & Integrations** | [.agents/rules/infrastructure.instructions.md](../.agents/rules/infrastructure.instructions.md) | Repositories, external APIs, messaging, databases                             |
| **Error Codes & Exceptions**      | [.agents/rules/error-codes.instructions.md](../.agents/rules/error-codes.instructions.md)       | Error code standards, exception patterns, HTTP status codes, recovery actions |

---

## 🚀 Quick Start for AI Agents

### 1. Identify the Project & Language + Error Handling Rules

```bash
# Example: Working in omi-channel-be (TypeScript)
→ Load: .agents/rules/typescript.instructions.md (primary)
→ Reference: .agents/rules/error-codes.instructions.md (exceptions & error codes)
→ Reference: .agents/rules/architecture.instructions.md
→ Reference: .agents/rules/business_logic.instructions.md

# Example: Working in crm_be (Java)
→ Load: .agents/rules/java.instructions.md (primary)
→ Reference: .agents/rules/error-codes.instructions.md (exceptions & error codes)
→ Reference: .agents/rules/architecture.instructions.md
→ Reference: .agents/rules/infrastructure.instructions.md
```

### 2. Follow the Hierarchy

1. **Language-specific rules** (e.g., TypeScript rules) - type safety, syntax, idioms
2. **Error codes & exceptions** (error-codes.instructions.md) - standardized error codes, HTTP status, recovery actions
3. **Architecture rules** - folder structure, Clean Architecture layers
4. **Business logic rules** - use cases, domain events, exception handling
5. **Infrastructure rules** - database operations, external integrations

### 3. When in Doubt

- Check the relevant rule file for patterns
- Check error codes reference for exception patterns
- Look for examples in the codebase
- Ask for specific files that exemplify the pattern (e.g., "show me a use case implementation in omi-channel-be")

---

## 🏗️ Unified Architecture Principles

### Clean Architecture (All Languages)

```
Presentation Layer (Controllers/Handlers)
    ↓ (calls)
Application Layer (Use Cases, Services, DTOs)
    ↓ (uses)
Domain Layer (Entities, Exceptions, Interfaces)
    ↓ (implements)
Infrastructure Layer (Repositories, External APIs)
```

### Error Handling (Standardized Across All Projects)

**Error Code Format**: `{CATEGORY}_{DESCRIPTIVE_NAME}`

```
Categories:
- AUTH_*     : Authentication/Authorization (401, 403)
- VAL_*      : Validation errors (400)
- BIZ_*      : Business logic errors (400, 404, 409)
- INF_*      : Infrastructure errors (500, 502, 503)
- SYS_*      : System errors (500)

Examples:
- AUTH_INVALID_TOKEN
- VAL_MISSING_REQUIRED_FIELD
- BIZ_ENTITY_NOT_FOUND
- INF_DATABASE_ERROR
- SYS_INTERNAL_ERROR
```

### Multi-Tenancy Pattern

Every request includes tenant context (company_id from JWT):

- **Extract** in controller from JWT
- **Pass** through all use cases/services
- **Validate** at use case level (never in database)
- **Use** in all repository queries for data isolation

---

## 🔧 Key Development Commands

### omi-channel-be (TypeScript/NestJS)

```bash
# Build & Quality
yarn lint          # ESLint with auto-fix
yarn build         # Compile TypeScript
yarn dev           # Development with hot reload
yarn start:prod    # Production server

# Databases
yarn migration:generate CreateTableName  # TypeORM migrations
yarn migration:run                       # Apply migrations

# Tests
yarn test          # Unit & integration tests
yarn test:cov      # Coverage report
yarn test:e2e      # End-to-end tests
```

### crm_be (Java/Spring)

```bash
./gradlew build    # Build project
./gradlew test     # Run tests
./gradlew run      # Run application
```

### packageTourApi (Java/Maven)

```bash
./mvnw clean build # Build with Maven
./mvnw test        # Run tests
./mvnw spring-boot:run  # Run application
```

---

## 📚 Documentation References

### omi-channel-be Core Docs

- [INSTRUCTIONS.md](../../back-end/omi-channel-be/docs/INSTRUCTIONS.md) - Complete dev guide, patterns, testing
- [ARCHITECTURE.md](../../back-end/omi-channel-be/docs/ARCHITECTURE.md) - System overview, dual-ID system, module status
- [DATABASE_SCHEMA.md](../../back-end/omi-channel-be/docs/DATABASE_SCHEMA.md) - PostgreSQL/MongoDB/Redis schemas
- [DIAGRAMS.md](../../back-end/omi-channel-be/docs/DIAGRAMS.md) - Architecture diagrams, module dependencies

### Integration & Pattern Docs

- [EXTERNAL_API_PATTERN_IMPLEMENTATION.md](../../back-end/omi-channel-be/docs/patterns/EXTERNAL_API_PATTERN_IMPLEMENTATION.md) - External API integration
- [WEBHOOK_FLOWS.md](../../back-end/omi-channel-be/docs/webhooks/WEBHOOK_FLOWS.md) - Webhook handling across channels

---

## ⚠️ Critical Rules (ALL Languages)

1. **Type Safety**: NO `any` types, explicit typing everywhere
2. **Error Handling**: Throw domain exceptions with standardized error codes (see [error-codes.instructions.md](../.agents/rules/error-codes.instructions.md))
   - **AUTH\_\*** (401, 403): Authentication & authorization failures
   - **VAL\_\*** (400): Input validation failures
   - **BIZ\_\*** (400, 404, 409): Business logic violations
   - **INF\_\*** (500, 502, 503): Infrastructure/external failures
   - **SYS\_\*** (500): System/configuration errors
3. **Multi-Tenancy**: ALWAYS validate company_id on queries
4. **Events**: Publish AFTER persistence, NOT before (event-driven architecture)
5. **Build**: Run lint → build → test before commit
6. **Package Manager**: Use `yarn` for NestJS, `gradle` for Java (never npm for Node projects)

---

## 🔄 Cross-Module Communication

### Right Way: Event-Driven

```typescript
// Module A: Publish event after persistence
await this.repository.save(entity);
await this.eventPublisher.publish(new DomainEvent(...));

// Module B: Subscribe to event in handler
@EventsHandler(DomainEvent)
export class DomainEventHandler { ... }
```

### Wrong Way: Direct Repository Calls

```typescript
// ❌ FORBIDDEN: Module A calling Module B's repository
private readonly moduleB_Repository: IRepository; // ← Cross-module!
```

---

## 📖 How to Use These Rules

**For Copilot/AI Agents**:

1. When asked to work on a file, check its extension (`.ts`, `.java`, etc.)
2. Load the corresponding language rule file from `.agents/rules/`
3. Cross-reference error codes rules as needed
4. Reference architecture/business logic rules for patterns
5. Ask for specific code examples from the codebase if clarification needed

**For Developers**:

1. Keep `.agents/rules/` bookmarked when developing
2. Refer to the language-specific rule file for your project
3. Check error-codes.instructions.md for exception patterns
4. Reference architecture.md for folder structure questions
5. Reference business_logic.md for use case/domain patterns

---

## 🔍 Complete Rules Reference Map

### Core Rules (All Languages)

1. **[error-codes.instructions.md](../.agents/rules/error-codes.instructions.md)** - Standardized error codes (AUTH*\*, VAL*_, BIZ\__, INF*\*, SYS*\*), exception patterns, HTTP status codes, recovery actions
2. **[architecture.instructions.md](../.agents/rules/architecture.instructions.md)** - Clean Architecture, layer structure, module organization, design patterns
3. **[business_logic.instructions.md](../.agents/rules/business_logic.instructions.md)** - Use cases, domain events, exception handling, validation patterns
4. **[infrastructure.instructions.md](../.agents/rules/infrastructure.instructions.md)** - Repositories, external APIs, database operations, messaging

### Language-Specific Rules

- **[typescript.instructions.md](../.agents/rules/typescript.instructions.md)** - Type safety, NestJS patterns, module structure (for omi-channel-be, findtourgoUI, packageTourAdmin)
- **[java.instructions.md](../.agents/rules/java.instructions.md)** - Spring Boot patterns, annotations, dependency injection (for crm_be, packageTourApi)
- **[golang.instructions.md](../.agents/rules/golang.instructions.md)** - Interfaces, error handling, concurrency (reference for future Go services)
- **[rust.instructions.md](../.agents/rules/rust.instructions.md)** - Ownership, Result types, async/await (reference for future Rust services)
- **[python.instructions.md](../.agents/rules/python.instructions.md)** - Type hints, best practices (reference for scripts/utilities)
- **[dart.instructions.md](../.agents/rules/dart.instructions.md)** - Classes, async patterns (reference for mobile/Flutter apps)
- **[c.instructions.md](../.agents/rules/c.instructions.md)** - Memory management, C conventions (reference if needed)

### Rule Selection Guide

| Scenario                                       | Load First                     | Then Reference                                       |
| ---------------------------------------------- | ------------------------------ | ---------------------------------------------------- |
| Creating new TypeScript file in omi-channel-be | typescript.instructions.md     | error-codes, architecture, business_logic            |
| Creating new Java file in crm_be               | java.instructions.md           | error-codes, architecture, infrastructure            |
| Implementing new exception                     | error-codes.instructions.md    | business_logic, language-specific rules              |
| Designing new module architecture              | architecture.instructions.md   | error-codes, business_logic, language-specific rules |
| Building cross-module integration              | business_logic.instructions.md | architecture, error-codes, infrastructure            |
| Integrating external API                       | infrastructure.instructions.md | error-codes, language-specific, business_logic       |

---

## 🎓 Learning Path for New Developers

1. **Day 1**: Read the project's main `README.md`
2. **Day 2-3**: Read language-specific rule file (e.g., typescript.instructions.md)
3. **Day 3**: Read architecture.instructions.md
4. **Day 4**: Read project docs (e.g., omi-channel-be/docs/ARCHITECTURE.md)
5. **Day 5+**: Reference business_logic.md and infrastructure.instructions.md as needed

---

**Last Updated**: February 2026
**System**: AI-Agents Unified Development Guidance
**Status**: Production Ready
