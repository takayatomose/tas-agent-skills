---
name: nestjs-backend-development
description: Expert in implementing enterprise NestJS applications with Clean Architecture, strict TypeScript, and event-driven design. Supports Yarn build system and production-ready patterns.
---

# Skill: NestJS Backend Development

## Overview

This skill guides development of **enterprise-grade NestJS applications** with:

- Clean Architecture layering (Presentation → Application → Domain → Infrastructure)
- Strict TypeScript (no `any`, explicit types on all variables)
- Exception-based error handling (not Result<T> patterns)
- Event-driven cross-module communication
- Multi-tenant isolation via JWT-extracted context

## Language Specifics

### Build & Package Management

**CRITICAL**: Use **Yarn only** (never npm/pnpm)

```bash
# Linting BEFORE build (non-negotiable)
yarn lint

# Build TypeScript
yarn build

# Development with hot-reload
yarn dev

# Production
yarn start:prod

# Testing
yarn test              # Unit/Integration
yarn test:cov          # Coverage
yarn test:e2e          # End-to-end
```

**Rules**:

- ❌ NEVER `npm install` / `npm run` (lockfile conflicts)
- ❌ NEVER skip linting (will fail in CI)
- ✅ Run `yarn lint` → `yarn build` → deploy

## Core Patterns

### Use Cases (Exception-Based)

Every operation must follow this flow:

```typescript
@Injectable()
export class SendMessageUseCase {
  constructor(
    @Inject("IMessageRepository")
    private readonly messageRepository: IMessageRepository,
    @Inject("EXTERNAL_CONFIG")
    private readonly config: ExternalConfig,
  ) {}

  // Return type: Domain object OR throw exception
  async execute(
    companyId: string, // Multi-tenant context
    dto: SendMessageDto,
  ): Promise<Message> {
    // 1. Validate input
    if (!dto.content?.trim()) throw new InvalidMessageException();

    // 2. Business rules
    const conversation = await this.conversationRepository.findById(
      companyId,
      dto.conversationId,
    );
    if (!conversation)
      throw new ConversationNotFoundException(dto.conversationId);

    // 3. External services (catch & wrap)
    let channelResponse;
    try {
      channelResponse = await externalChannelApi.send(dto);
    } catch (error) {
      const msg = error instanceof Error ? error.message : "Unknown";
      throw new ExternalChannelException(`Send failed: ${msg}`);
    }

    // 4. Persist
    const message = Message.create({
      conversationId: conversation.id,
      content: dto.content,
      externalId: channelResponse.messageId,
    });
    const saved = await this.messageRepository.save(message);

    // 5. Publish event
    await this.eventPublisher.publish(
      new MessageSentEvent(saved.id, companyId, saved),
    );

    // 6. Return (never throw when successful)
    return saved;
  }
}
```

**Rules**:

- ✅ Return domain object on success
- ✅ Throw domain exception on error
- ❌ Never return Result<T> (deprecated)
- ✅ Use `@Inject('IRepository')` pattern
- ✅ Always check `companyId` context
- ✅ Publish events AFTER persistence, BEFORE return

### TypeScript Strict Typing

**No `any` or `as any`** — forbidden everywhere.

```typescript
// ❌ WRONG
const data: any = fetchData();
const result: Record<string, any> = process(input);

// ✅ CORRECT: Concrete types with generics
interface UserResponse {
  id: string;
  name: string;
  email: string;
}

async function getUser(userId: string): Promise<UserResponse> {
  const response = await fetch(`/api/users/${userId}`);
  return response.json() as UserResponse;
}

// ✅ CORRECT: Generic with constraints
function filter<T extends { active: boolean }>(items: T[]): T[] {
  return items.filter((item) => item.active);
}
```

### Error Handling

Define domain exceptions (not HTTP exceptions):

```typescript
// ❌ WRONG: HTTP exception in domain
throw new BadRequestException('Invalid input');

// ✅ CORRECT: Domain exception in application layer
export class InvalidMessageException extends DomainException {
  constructor(content?: string) {
    super(
      ErrorCode.VAL_INVALID_MESSAGE,
      `Message content is invalid`,
      400,
      { content },
    );
  }
}
```

### Configuration (Centralized)

All config must be injected, never direct env var access:

```typescript
// ✅ CORRECT: Inject from config module
@Injectable()
export class ExternalApiClient {
  constructor(
    @Inject("EXTERNAL_CONFIG")
    private readonly config: ExternalConfig,
  ) {
    this.apiUrl = config.externalService.url;
  }
}

// ❌ WRONG: Direct env access
const apiUrl = process.env.EXTERNAL_API_URL;
```

### Multi-Database Pattern

```typescript
// PostgreSQL (metadata, relationships)
const company = await this.companyRepository.findById(companyId);

// MongoDB (messages - append-only)
const messages = await this.messageRepository.findByConversation(
  conversationId,
  { limit: 50 },
);

// Redis (ephemeral state)
const sessionState = await this.redis.get(`session:${sessionId}`);
```

## File Structure & Naming

```
src/modules/{feature}/
├── presentation/
│   └── {feature}.controller.ts         # HTTP handlers
├── application/
│   ├── use-cases/{action}.use-case.ts  # Business logic
│   ├── dtos/{action}.dto.ts            # @ValidateClass rules
│   └── event-handlers/{event}.handler.ts
├── domain/
│   ├── entities/{entity}.orm-entity.ts # @Entity() for PostgreSQL
│   ├── exceptions/{error}.exception.ts # Domain errors (not HTTP)
│   ├── events/{action}.event.ts        # Domain events
│   └── interfaces/I{entity}-repository.ts
└── infrastructure/
    ├── repositories/{entity}.repository.ts
    ├── clients/{service}.client.ts     # External APIs
    └── mappers/
```

## Database Migrations

```bash
# Generate from entity changes
yarn migration:generate AddMessageTable

# Run pending migrations
yarn migration:run

# Revert last migration
yarn migration:revert

# Check status
yarn migration:show
```

**Key Rules**:

- ✅ Always run migrations before deploy
- ❌ Never use `synchronize: true` in production
- ✅ Commit migrations to version control
- ✅ Test migrations locally first

## Common Commands

```bash
# Development
yarn dev                 # Hot-reload on port 3000

# Building
yarn lint && yarn build  # Lint THEN build

# Testing
yarn test              # Run all tests
yarn test --watch      # Watch mode

# Production
yarn build && yarn start:prod

# DevTools (development only)
# Available at http://localhost:8000
```

## Testing Strategy

```bash
# Unit tests (mocked dependencies)
yarn test modules/{feature}/application/use-cases/__tests__/*.spec.ts

# Integration tests (real database)
yarn test --testPathPattern="integration"

# Coverage
yarn test:cov
```

Example test:

```typescript
describe("SendMessageUseCase", () => {
  let useCase: SendMessageUseCase;
  let mockRepository: jest.Mocked<IMessageRepository>;

  beforeEach(() => {
    mockRepository = { save: jest.fn() } as any;
    useCase = new SendMessageUseCase(mockRepository);
  });

  it("should throw InvalidMessageException if content empty", async () => {
    await expect(
      useCase.execute("company-id", { content: "" }),
    ).rejects.toThrow(InvalidMessageException);
  });

  it("should save message and publish event", async () => {
    mockRepository.save.mockResolvedValue({ id: "msg-1" });
    const result = await useCase.execute("company-id", { content: "test" });
    expect(result.id).toBe("msg-1");
    expect(mockRepository.save).toHaveBeenCalled();
  });
});
```

## Quick Checklist

- [ ] Use Yarn (not npm)
- [ ] No `any` types
- [ ] Exceptions instead of Result<T>
- [ ] Validate `companyId` in use cases
- [ ] Publish events for cross-module
- [ ] External APIs wrapped with types
- [ ] Lint passes before build
- [ ] Tests cover happy path + exceptions
- [ ] Multi-tenant context extracted from JWT
- [ ] Configuration injected (not env access)
