---
name: backend-general-patterns
description: Universal backend development patterns, error handling, and architecture principles applicable across all languages (NestJS, Java, Go, Rust).
---

# Skill: General Backend Patterns

This skill documents **language-agnostic patterns** for backend development that apply across **NestJS, Java, Go, and Rust**.

## Architecture Layers

Every backend system must respect these layers:

```
Presentation Layer (Controllers/Handlers)
  - HTTP handlers / REST controllers
  - Request validation & parameter extraction
  - Response formatting
  - NO business logic here

Application Layer (Use Cases / Services)
  - Orchestrate domain logic
  - Command/Query services
  - Event publishing
  - Error handling (throw exceptions/return errors)
  - Never call repositories across modules

Domain Layer (Entities / Models)
  - Business rules (enforced at model creation)
  - Value objects
  - Repository interfaces (contracts, not implementations)
  - Domain events (define data structure only)
  - Domain exceptions (enums/classes defining errors)

Infrastructure Layer (Repositories / External)
  - Database clients (PostgreSQL, MongoDB, Redis)
  - External API clients / webhooks
  - Repository implementations
  - Caching layers
  - Message brokers (RabbitMQ, Kafka)
```

**Cross-Layer Rule**: Never skip layers. Presentation MUST go through Application which uses Domain.

## Error Handling Pattern

### Standard Error Code Format

All errors must use this format across all languages:

```
{CATEGORY}_{DESCRIPTIVE_NAME}

AUTH_INVALID_TOKEN
AUTH_PERMISSION_DENIED
VAL_MISSING_REQUIRED_FIELD
VAL_INVALID_EMAIL_FORMAT
BIZ_ENTITY_NOT_FOUND
BIZ_ENTITY_ALREADY_EXISTS
INF_DATABASE_ERROR
INF_EXTERNAL_API_ERROR
SYS_CONFIGURATION_ERROR
```

### Error Response Format

Every error response must include:

```json
{
  "errorCode": "BIZ_ENTITY_NOT_FOUND",
  "message": "User 'user-123' not found",
  "statusCode": 404,
  "details": {
    "userId": "user-123",
    "timestamp": "2026-02-24T10:30:00Z"
  }
}
```

## Multi-Tenant Isolation

Every request must validate tenant access:

1. **Extract tenant context** from JWT/headers
2. **Pass through all layers** (never lose context)
3. **Validate at use case level** before any database query
4. **Never filter at database level** (always validate first)

Example flow:

```
Request arrives → Extract companyId from JWT
  ↓
Controller calls UseCase(companyId, dto)
  ↓
UseCase validates: company exists and user has access
  ↓
UseCase queries: find by ID AND companyId
  ↓
Return result (guarantee: belongs to this tenant)
```

### Validation Checklist

- ✅ JWT decoded and companyId extracted
- ✅ UseCase receives companyId parameter
- ✅ UseCase validates user access before any operation
- ✅ All repository queries include companyId filter
- ✅ Error thrown if companyId mismatch
- ❌ Never trust client-provided companyId without JWT validation

## Use Case Contract (Universal)

Every use case follows this contract across all languages:

```
Input: UseCase receives (tenantId, requestDTO)
  ↓
Validation: Input constraints verified
  ↓
Context: Tenant/user access validated
  ↓
Execution: Business logic executed
  ↓
Persistence: Data saved
  ↓
Events: Domain events published
  ↓
Output: Domain object returned (or error thrown)
```

## Event-Driven Cross-Module Communication

**CRITICAL RULE**: Never call repositories directly across module boundaries.

### Event Pattern (3 Steps)

**Step 1: Define Event** (in source module's domain)

Event class with all necessary data (CompanyId, Entity IDs, Changed data).

**Step 2: Publish Event** (in source use case, after persistence)

Save to database → Publish event → Return to caller

**Step 3: Subscribe** (in target module's application layer)

Listen for event → Query target module's repository → Save/update target entity

### Benefits

- ✅ Loose coupling (modules don't know about each other)
- ✅ Async processing (don't block main request)
- ✅ Scalability (can be distributed to message broker)
- ✅ Auditability (event log of all changes)
- ✅ Retry mechanism (event bus handles failures)

## Data Persistence Strategy

### Three-Database Architecture

```
PostgreSQL (ACID, Relationships)
├── Companies (tenants)
├── Channels (platform configurations)
├── Contacts (unified directory)
├── Conversations (1:1 chats)
└── Configurations (settings per channel)

MongoDB (Append-Only, Time-Series)
├── Messages (high-volume, never update)
├── Chat sessions (activity tracking)
└── Webhook events (audit trail)

Redis (Ephemeral, Cache)
├── Session state (user->connection mapping)
├── Rate limits (counters per minute)
└── Real-time presence (who's online)
```

### Data Type → Storage Mapping

| Data Type                    | Storage           | Reason                        |
| ---------------------------- | ----------------- | ----------------------------- |
| Configuration, relationships | PostgreSQL        | ACID, complex queries         |
| High-volume logs, messages   | MongoDB           | Append-only, fast writes      |
| Session state, cache         | Redis             | In-memory, auto-expire        |
| Real-time state              | Redis + Event Bus | Broadcast to multiple clients |

## Type Safety Standards

### Forbidden Patterns (All Languages)

- ❌ Any/Object/dynamic types (use generics or explicit types)
- ❌ Untyped external API responses (always define interface)
- ❌ Missing error context (always include relevant details)
- ❌ Direct DB access in controllers (always use repository)
- ❌ Casting without guards (validate types before cast)

### Required Patterns

- ✅ Explicit types on all variables
- ✅ Typed interfaces for external APIs
- ✅ Error codes with standardized format
- ✅ Domain exceptions with business context
- ✅ Dependency injection via constructor
- ✅ Repository interfaces (no concrete classes in contracts)

## Configuration Management

### Rules

- ✅ All config from environment variables (no hardcoding)
- ✅ Centralized config module/class (single source of truth)
- ✅ Typed config objects (not string keys)
- ✅ Validate config on startup (fail fast)
- ✅ Never access env vars directly in application code

## Testing Strategy

### Unit Tests (Isolated)

- Mock all dependencies
- Test happy path + all exception paths
- No database, no external APIs
- Fast execution (< 100ms per test)

### Integration Tests (Real Database)

- Use test database (isolated from dev/prod)
- Reset state before each test
- Test end-to-end flow
- Slower but catch real issues

### E2E Tests (Full System)

- Test realistic workflows (user journey)
- Real database, real external APIs (or mocked)
- Verify entire event chain
- Longest execution time, highest confidence

### Test Naming Convention

```
test_[Unit|Integration|E2E]_{entity}_{use_case}_{condition}_{expected}

Examples:
- test_unit_send_message_valid_content_returns_message_id
- test_integration_send_message_end_to_end_creates_in_database
- test_e2e_send_message_publishes_webhook_to_external_service
```

## Deployment Workflow

### Build → Test → Deploy

1. **Build**: Compile code
2. **Lint**: Check code quality (must pass)
3. **Test**: Run all test suites
4. **Archive**: Create deployable artifact
5. **Deploy**: Push to target environment
6. **Verify**: Health checks, smoke tests

### Database Migrations

- Generated from entity changes (not manual SQL)
- Version controlled (commit alongside code)
- Tested locally before deploying
- Applied automatically or manual approval
- Can be rolled back if needed

### Checklist Before Deploy

- [ ] Linting passes (no warnings)
- [ ] All tests pass (unit + integration + E2E)
- [ ] Code coverage meets threshold (80%+)
- [ ] No hardcoded secrets (all from env)
- [ ] Database migrations tested
- [ ] Configuration validated for target environment
- [ ] Rollback plan documented
- [ ] Team aware of deploy (Slack notification)

## Common Pitfalls & Solutions

| Pitfall                          | Solution                                    |
| -------------------------------- | ------------------------------------------- |
| Direct repo calls across modules | Use domain events + event handlers          |
| No tenant validation             | Always pass `tenantId` to use case          |
| Generic error messages           | Use error codes with details                |
| Skipped unit tests               | Aim for 80%+ coverage                       |
| Environmental secrets in code    | Load from env, validate on startup          |
| Tight coupling to frameworks     | Depend on interfaces, not implementations   |
| N+1 query problems               | Batch loads, use repository optimizations   |
| Long transactions                | Keep transactions short (< 1 second)        |
| Missing error handling           | Wrap external calls, propagate with context |
| Untyped external APIs            | Always define interface for external data   |

## Instructions for the Agent

- **Multi-Tenant Safety**: Extract `tenantId` from JWT, pass through all layers, validate before querying, always filter by tenant.
- **Error Handling**: Use error codes (AUTH*, VAL*, BIZ*, INF*, SYS\_), include details, let exceptions bubble, log without exposing sensitive data.
- **Cross-Module Calls**: Always use domain events, never direct repos, publish after persistence, subscribe asynchronously.
- **Type Safety**: No `any`/`Object`/`dynamic`, explicit generics, wrap external responses, guard before casting.
- **Testing**: Unit=mocks/isolated, Integration=real DB/full flow, E2E=realistic scenarios, 80%+ coverage target.
