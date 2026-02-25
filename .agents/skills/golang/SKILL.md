---
name: golang
description: Expert in building concurrent Go services with clean architecture, error handling, and idiomatic patterns. Covers Go modules, interfaces, and concurrency best practices.
---

# Skill: Go Backend Development

## Overview

This skill guides **production Go development** with:

- Clean Architecture (Domain → Application → Presentation)
- Idiomatic Go error handling (error returns, not exceptions)
- Interface-based design (small, focused interfaces)
- Concurrency patterns (goroutines, channels)
- Multi-tenant isolation via request context

## Build & Dependency Management

### Go Modules (Standard)

```bash
# Initialize project
go mod init github.com/company/project

# Build
go build -o bin/app ./cmd/main.go

# Run tests
go test ./...

# Code quality (must pass before commit)
go fmt ./...        # Format
go vet ./...        # Lint
golangci-lint run   # Comprehensive lint

# Development
go run ./cmd/main.go

# Production
CGO_ENABLED=0 go build -o bin/app ./cmd/main.go
```

**Rules**:

- ✅ Commit `go.sum` to version control
- ✅ Run `go fmt` + `go vet` before commit
- ✅ Use `go mod tidy` to clean dependencies
- ✅ No vendor directory (use GO111MODULE=on)

## Type Safety

### Interfaces & Composition (No Inheritance)

```go
// ❌ WRONG: Catch-all interface
type Handler interface {
  Handle(input interface{}) (interface{}, error)
}

// ✅ CORRECT: Small, focused interfaces
type UserRepository interface {
  FindByID(ctx context.Context, id string) (*User, error)
  Save(ctx context.Context, user *User) error
}

type EventPublisher interface {
  Publish(ctx context.Context, event Event) error
}

// ✅ CORRECT: Type-safe returns (no interface{})
type SendMessageResult struct {
  MessageID string
  Timestamp time.Time
}

func (s *SendMessageService) Execute(
  ctx context.Context,
  companyID string,
  req *SendMessageRequest,
) (*SendMessageResult, error) {
  // ...
}
```

### Error Handling (No Exceptions)

```go
// ❌ WRONG: Silent errors, panic
result, _ := repo.FindByID(ctx, id)  // Ignoring error
if condition {
  panic("something went wrong")       // Never panic in production
}

// ✅ CORRECT: Explicit error handling with context
user, err := repo.FindByID(ctx, id)
if err != nil {
  if errors.Is(err, ErrNotFound) {
    return nil, fmt.Errorf("find user: %w", err)
  }
  return nil, fmt.Errorf("database error: %w", err)
}

// ✅ CORRECT: Wrap errors with context
func (s *service) Process(ctx context.Context, id string) error {
  user, err := s.repo.FindByID(ctx, id)
  if err != nil {
    return fmt.Errorf("process user %s: %w", id, err)
  }
  return nil
}
```

## File Structure

```
project/
├── cmd/
│   └── main.go                 # Entry point
├── internal/
│   ├── domain/
│   │   ├── entity.go           # Domain models
│   │   ├── repository.go       # Repository interfaces
│   │   ├── event.go            # Domain events
│   │   └── error.go            # Domain errors
│   ├── application/
│   │   ├── service/
│   │   │   └── send_message.go # Use case (service)
│   │   ├── dto/
│   │   │   └── send_message.go # Request/Response DTOs
│   │   └── handler/
│   │       └── message_sent.go # Event handlers
│   ├── infrastructure/
│   │   ├── repository/
│   │   │   └── postgres_message.go
│   │   ├── external/
│   │   │   └── channel_client.go
│   │   └── config/
│   │       └── config.go
│   └── presentation/
│       ├── handler/            # HTTP handlers
│       └── middleware/         # Auth, logging
├── pkg/
│   └── public/                 # Public packages (if any)
├── test/
│   └── fixtures.go             # Test helpers
├── go.mod
├── go.sum
└── main.go
```

## Core Patterns

### Use Cases (Services)

```go
type SendMessageService struct {
  repo             MessageRepository
  conversationRepo ConversationRepository
  channelClient    ChannelClient
  publisher        EventPublisher
}

// NewSendMessageService (constructor injection)
func NewSendMessageService(
  repo MessageRepository,
  conversationRepo ConversationRepository,
  channelClient ChannelClient,
  publisher EventPublisher,
) *SendMessageService {
  return &SendMessageService{
    repo:             repo,
    conversationRepo: conversationRepo,
    channelClient:    channelClient,
    publisher:        publisher,
  }
}

// Execute (use case method)
func (s *SendMessageService) Execute(
  ctx context.Context,
  companyID string,
  req *SendMessageRequest,
) (*MessageResponse, error) {
  // 1. Validate input
  if req.Content == "" {
    return nil, &DomainError{
      Code:     ErrCodeValMissingField,
      Message:  "content cannot be empty",
      HTTPCode: 400,
    }
  }

  // 2. Business rules (context isolation)
  conversation, err := s.conversationRepo.FindByIDAndCompanyID(
    ctx,
    req.ConversationID,
    companyID,
  )
  if err != nil {
    return nil, fmt.Errorf("find conversation: %w", err)
  }
  if conversation == nil {
    return nil, &DomainError{
      Code:     ErrCodeBizEntityNotFound,
      Message:  fmt.Sprintf("conversation %s not found", req.ConversationID),
      HTTPCode: 404,
      Details:  map[string]interface{}{"conversationId": req.ConversationID},
    }
  }

  // 3. External service (wrap errors)
  response, err := s.channelClient.Send(ctx, conversation.ChannelID, req)
  if err != nil {
    return nil, fmt.Errorf("send to channel: %w", err)
  }

  // 4. Persist
  message := &Message{
    ID:         uuid.New().String(),
    Content:    req.Content,
    ExternalID: response.MessageID,
    CreatedAt:  time.Now(),
  }
  if err := s.repo.Save(ctx, message); err != nil {
    return nil, fmt.Errorf("save message: %w", err)
  }

  // 5. Publish event
  if err := s.publisher.Publish(ctx, &MessageSentEvent{
    MessageID: message.ID,
    CompanyID: companyID,
    Message:   message,
  }); err != nil {
    // Log but don't fail (async operation)
    // Log error here
  }

  // 6. Return (never error when successful)
  return &MessageResponse{
    MessageID: message.ID,
    Content:   message.Content,
  }, nil
}
```

### Interfaces (Small & Focused)

```go
// Repository interface (thin abstraction)
type MessageRepository interface {
  FindByID(ctx context.Context, id string) (*Message, error)
  Save(ctx context.Context, msg *Message) error
  FindByConversationID(
    ctx context.Context,
    conversationID string,
    limit int,
  ) ([]*Message, error)
}

// Event publisher interface
type EventPublisher interface {
  Publish(ctx context.Context, event Event) error
}

// External client interface
type ChannelClient interface {
  Send(
    ctx context.Context,
    channelID string,
    req *SendMessageRequest,
  ) (*ChannelResponse, error)
}
```

## Common Commands

```bash
# Format & lint
go fmt ./...
go vet ./...
golangci-lint run

# Test
go test ./...
go test -v -cover ./...
go test ./... -run TestName  # Specific test

# Build
go build -o bin/app ./cmd/main.go

# Clean dependencies
go mod tidy
```

## Quick Checklist

- [ ] Return `error` from functions (never ignore)
- [ ] Use interfaces for dependencies
- [ ] Run `go fmt` + `go vet` before commit
- [ ] No panic in production code
- [ ] Validate `companyId` in handlers
- [ ] Wrap errors with context using `fmt.Errorf`
- [ ] Use typed error codes (not strings)
- [ ] Publish events AFTER persistence
- [ ] Document exported functions (uppercase)
- [ ] Use context.Context for cancellation/timeout
