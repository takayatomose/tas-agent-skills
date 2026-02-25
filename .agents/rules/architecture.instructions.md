---
name: clean-architecture-general
description: Universal structure and layering rules for Clean Architecture across modules
applyTo: "src/**/*"
---

# Universal Clean Architecture Rules

## 1. Core Layering Principles

All modules must strictly adhere to the following dependency direction:
**Presentation → Application → Domain ← Infrastructure**

### Layers Description:

1. **Domain Layer (Core)**: Contains Enterprise Business Rules. Zero dependencies on external libraries (Web, DB, Frameworks).
2. **Application Layer**: Contains Application-specific Business Rules (Use Cases). Orchestrates the flow of data to and from the Domain layer.
3. **Infrastructure Layer**: Technical implementations (DB Repositories, API Clients, File System).
4. **Presentation Layer**: Entry points (Controllers, CLIs, UI, Webhooks).

## 2. Dependency Rule

Dependencies must only point **INWARDS**.

- Application can depend on Domain.
- Infrastructure depends on Domain (via interfaces).
- Domain MUST NOT depend on anything.

## 4. Pattern: Dual-ID System Architecture

**Importance**: 🔴 CRITICAL

All systems must distinguish between **External ID** (used for API contracts, JWTs, and external lookups) and **Internal ID** (the primary key in the database, usually UUID).

| ID Type         | Format                | Source                  | Usage                                 |
| --------------- | --------------------- | ----------------------- | ------------------------------------- |
| **External ID** | Usually a number/long | JWT token, API requests | API contracts, Auth Server            |
| **Internal ID** | UUID (string)         | Database primary key    | All database queries, event listeners |

### Conversion Rule:
Controllers or early application layers must convert the External ID to an Internal ID before passing it to use cases or repositories.

---

## 5. Pattern: Event-Driven Cross-Module Communication

**Importance**: 🔴 CRITICAL

**Golden Rule**: NEVER call repositories or private services directly across modules. Always use Domain Events + Event Bus.

### Benefits:
- **Loose Coupling**: Modules are independent.
- **Async Processing**: Improves response times and resiliency.
- **Scalability**: Can be distributed via message brokers (RabbitMQ, Bull, Kafka).

### Flow:
1. **Source Module**: Finishes execution, publishes a `DomainEvent`.
2. **Target Module**: Listens for the event and triggers a handler.

---

## 6. Detailed Layer Breakdown

Each module `src/modules/{feature}/` should follow this structure:

- `presentation/`: Controllers, route handling, HTTP entry points.
- `application/`:
  - `use-cases/`: Business logic orchestration.
  - `dtos/`: Input validation.
  - `event-handlers/`: Async domain event handlers.
- `domain/`:
  - `entities/`: ORM entities or aggregate roots.
  - `events/`: Domain event definitions.
  - `exceptions/`: Domain-specific business exceptions.
  - `interfaces/`: Repository contracts (`I{Entity}Repository`).
- `infrastructure/`:
  - `repositories/`: Database implementations.
  - `clients/`: External API/Service clients.
  - `mappers/`: Object conversion logic.

---

## 7. Global Architectural Mandates

- **Enforce Layering**: Presentation → Application → Domain → Infrastructure. Never bypass layers.
- **Exception Safety**: Use domain-specific exceptions in business logic; never let infrastructure or HTTP details leak into the domain.
- **Multi-Tenant Isolation**: Every operation must validate the requesting tenant/company access. Usually via `companyId` from context.
- **Repository Isolation**: Repositories are private to modules. External access is strictly via events or exported application-level interfaces.

---

## 8. Object Types

- **Entities**: Business objects with a unique identity and lifecycle.
- **Value Objects**: Objects defined by their attributes (immutable).
- **Repositories**: Boundary interfaces for persistence.
- **DTOs (Data Transfer Objects)**: Simple objects for data crossing boundaries.
- **Mappers**: Pure functions converting objects between layers (e.g., Persistence Entity ↔ DTO).

## 9. Violation Checklist

- [ ] Does a Domain Entity import a database library? (FAIL)
- [ ] Does a Controller contain business logic? (FAIL)
- [ ] Does a Use Case know about HTTP status codes? (FAIL)
- [ ] Does one module access another's private folders (e.g., `infrastructure`)? (FAIL)
- [ ] Is an External ID stored directly in a database field for identity? (FAIL)
