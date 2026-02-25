---
name: rust-backend-development
description: Expert in building type-safe, concurrent Rust services with ownership patterns, error handling, and clean architecture. Covers Actix, Axum, Rocket, and memory-safe patterns.
---

# Skill: Rust Backend Development

## Overview

This skill guides **production Rust development** (Actix, Axum, Rocket) with:

- Clean Architecture (Domain → Application → Presentation)
- Ownership & borrowing (no null, memory safe)
- Result/Option types (not exceptions)
- Trait-based design (composition over inheritance)
- Multi-tenant isolation via request context

## Build & Dependency Management

### Cargo (Standard)

```bash
# Initialize project
cargo init --name my_app

# Build
cargo build --release

# Run tests
cargo test

# Code quality (must pass before commit)
cargo fmt --all       # Format
cargo clippy          # Lint (warnings = quality issues)

# Development
cargo run

# Production
cargo build --release
./target/release/app
```

**Rules**:

- ✅ Commit `Cargo.lock` for binary projects
- ✅ Run `cargo fmt --all` before commit
- ✅ Fix all `cargo clippy` warnings
- ✅ Use workspace for multi-crate projects

## Type Safety (Ownership System)

### No Null, No Panics

```rust
// ❌ WRONG: Panicking on unwrap
let result = some_function().unwrap();  // Crash if None
let value = data["key"].unwrap();       // Panic on error

// ✅ CORRECT: Explicit Option/Result handling
match some_function() {
  Some(value) => { /* use value */ }
  None => { /* handle missing */ }
}

// ✅ CORRECT: Question mark operator (early return)
let value = some_function()?;  // Returns error early if None

// ✅ CORRECT: Using Option::ok_or
let user = save_user(&user)
  .ok_or_else(|| DomainError::UserNotFound(user_id))?;
```

### Result-Based Error Handling

```rust
// ✅ CORRECT: Result with detailed errors
#[derive(Debug)]
pub enum DomainError {
  ValidationError(String),
  EntityNotFound { entity: String, id: String },
  ExternalServiceError(String),
  DatabaseError(String),
}

type DomainResult<T> = Result<T, DomainError>;

pub async fn send_message(
  company_id: &str,
  req: SendMessageRequest,
) -> DomainResult<Message> {
  // Validation
  if req.content.is_empty() {
    return Err(DomainError::ValidationError(
      "content cannot be empty".to_string(),
    ));
  }

  // Business logic (error propagation with ?)
  let conversation = find_conversation(&company_id, &req.conversation_id)
    .await
    .ok_or_else(|| DomainError::EntityNotFound {
      entity: "Conversation".to_string(),
      id: req.conversation_id.clone(),
    })?;

  // External service with error wrapping
  let channel_response = send_to_channel(&conversation.channel_id, &req)
    .await
    .map_err(|e| DomainError::ExternalServiceError(e.to_string()))?;

  // Persist with error wrapping
  let message = Message {
    id: uuid::Uuid::new_v4().to_string(),
    content: req.content.clone(),
    external_id: channel_response.message_id,
    created_at: chrono::Utc::now(),
  };

  save_message(&message)
    .await
    .map_err(|e| DomainError::DatabaseError(e.to_string()))?;

  // Publish event (async, don't block)
  publish_event(&MessageSentEvent {
    message_id: message.id.clone(),
    company_id: company_id.to_string(),
    message: message.clone(),
  })
  .await
  .ok(); // Log but don't fail on event publish

  Ok(message)
}
```

## File Structure

```
project/
├── src/
│   ├── main.rs              # Entry point
│   ├── lib.rs               # Library root
│   ├── domain/
│   │   ├── mod.rs
│   │   ├── entity.rs        # Domain models
│   │   ├── repository.rs    # Repository traits
│   │   ├── event.rs         # Domain events
│   │   └── error.rs         # Domain errors (enum)
│   ├── application/
│   │   ├── mod.rs
│   │   ├── service/
│   │   │   └── send_message.rs  # Use case
│   │   ├── dto.rs           # Request/Response DTOs
│   │   └── event_handler.rs # Event handlers
│   ├── infrastructure/
│   │   ├── mod.rs
│   │   ├── repository/
│   │   │   └── postgres.rs
│   │   ├── external/
│   │   │   └── channel_client.rs
│   │   └── config.rs
│   └── presentation/
│       ├── mod.rs
│       ├── handler.rs       # HTTP handlers
│       └── middleware.rs    # Auth, logging
├── tests/
│   └── integration_tests.rs
├── Cargo.toml
└── Cargo.lock
```

## Core Patterns

### Use Cases (Services with Traits)

```rust
// Repository trait (abstraction)
#[async_trait::async_trait]
pub trait MessageRepository: Send + Sync {
  async fn find_by_id(&self, id: &str)
    -> Result<Option<Message>, String>;

  async fn save(&self, message: &Message) -> Result<(), String>;
}

// Service struct (composition)
pub struct SendMessageService<R: MessageRepository> {
  repo: Arc<R>,
  conversation_repo: Arc<dyn ConversationRepository>,
  channel_client: Arc<dyn ChannelClient>,
  event_publisher: Arc<dyn EventPublisher>,
}

// Implementation (associated function = constructor)
impl<R: MessageRepository> SendMessageService<R> {
  pub fn new(
    repo: Arc<R>,
    conversation_repo: Arc<dyn ConversationRepository>,
    channel_client: Arc<dyn ChannelClient>,
    event_publisher: Arc<dyn EventPublisher>,
  ) -> Self {
    Self {
      repo,
      conversation_repo,
      channel_client,
      event_publisher,
    }
  }

  // Use case method
  pub async fn execute(
    &self,
    company_id: &str,
    req: &SendMessageRequest,
  ) -> DomainResult<SendMessageResponse> {
    // 1. Validate input
    if req.content.is_empty() {
      return Err(DomainError::ValidationError(
        "content cannot be empty".to_string(),
      ));
    }

    // 2. Business rules (context isolation)
    let conversation = self.conversation_repo
      .find_by_id_and_company_id(&req.conversation_id, company_id)
      .await
      .map_err(|e| DomainError::DatabaseError(e))?
      .ok_or_else(|| DomainError::EntityNotFound {
        entity: "Conversation".to_string(),
        id: req.conversation_id.clone(),
      })?;

    // 3. External service (wrap errors)
    let channel_response = self.channel_client
      .send(&conversation.channel_id, req)
      .await
      .map_err(|e| DomainError::ExternalServiceError(e))?;

    // 4. Persist
    let message = Message {
      id: uuid::Uuid::new_v4().to_string(),
      content: req.content.clone(),
      external_id: channel_response.message_id,
      created_at: chrono::Utc::now(),
    };

    self.repo
      .save(&message)
      .await
      .map_err(|e| DomainError::DatabaseError(e))?;

    // 5. Publish event
    let _result = self.event_publisher
      .publish(&MessageSentEvent {
        message_id: message.id.clone(),
        company_id: company_id.to_string(),
        message: message.clone(),
      })
      .await;  // Async, ignore error

    // 6. Return (never error when successful)
    Ok(SendMessageResponse {
      message_id: message.id,
      content: message.content,
    })
  }
}
```

### Traits (Small & Focused)

```rust
// Repository trait
#[async_trait::async_trait]
pub trait ConversationRepository: Send + Sync {
  async fn find_by_id_and_company_id(
    &self,
    id: &str,
    company_id: &str,
  ) -> Result<Option<Conversation>, String>;
}

// External service trait
#[async_trait::async_trait]
pub trait ChannelClient: Send + Sync {
  async fn send(
    &self,
    channel_id: &str,
    req: &SendMessageRequest,
  ) -> Result<ChannelResponse, String>;
}
```

## Testing

```rust
#[cfg(test)]
mod tests {
  use super::*;
  use mockall::prelude::*;

  #[tokio::test]
  async fn test_send_message_valid_request() {
    let mut mock_repo = MockMessageRepository::new();
    mock_repo
      .expect_save()
      .with(Always)
      .times(1)
      .returning(|_| Ok(()));

    let service = SendMessageService::new(
      Arc::new(mock_repo),
      Arc::new(MockConversationRepository::new()),
      Arc::new(MockChannelClient::new()),
      Arc::new(MockEventPublisher::new()),
    );

    let req = SendMessageRequest {
      conversation_id: "conv-1".to_string(),
      content: "hello".to_string(),
    };

    let result = service.execute("company-1", &req).await;
    assert!(result.is_ok());
  }

  #[tokio::test]
  async fn test_send_message_empty_content_fails() {
    let req = SendMessageRequest {
      conversation_id: "conv-1".to_string(),
      content: "".to_string(),
    };

    let service = create_test_service();
    let result = service.execute("company-1", &req).await;
    assert!(result.is_err());
  }
}
```

## Common Commands

```bash
# Format & lint
cargo fmt --all
cargo clippy

# Test
cargo test
cargo test -- --nocapture  # Show println!
cargo test --doc           # Doc tests

# Build
cargo build --release

# Clean
cargo clean
```

## Quick Checklist

- [ ] No unwrap() unless debug
- [ ] Use `?` operator for error propagation
- [ ] Traits for dependencies (Arc<dyn Trait>)
- [ ] Run `cargo fmt` + `cargo clippy` before commit
- [ ] Validate `company_id` in use cases
- [ ] Result<T, E> instead of bool returns
- [ ] Publish events AFTER persistence
- [ ] Use #[async_trait] for async methods in traits
- [ ] Never clone large objects (use references)
- [ ] No unsafe unless absolutely necessary
