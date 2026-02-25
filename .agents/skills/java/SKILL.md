---
name: java-backend-development
description: Expert in implementing enterprise Java applications (Spring/Quarkus) with Clean Architecture, strict typing, and multi-tenant design. Covers Gradle, Maven, and modern Java patterns.
---

# Skill: Java Backend Development

## Overview

This skill guides **enterprise Java development** (Spring Boot, Quarkus) with:

- Clean Architecture (Domain → Application → Presentation)
- Strict typing (use proper types, avoid Object/cast)
- Exception-based error handling
- Multi-tenant isolation via request context
- Gradle/Maven build automation

## Build & Dependency Management

### Gradle (Recommended)

```bash
# Build with tests
./gradlew build

# Run tests
./gradlew test

# Code quality
./gradlew spotlessApply  # Format code

# Development
./gradlew bootRun

# Production
./gradlew build -x test
java -jar build/libs/app.jar
```

### Maven (Alternative)

```bash
# Build
mvn clean package

# Run tests
mvn test

# Format
mvn spotless:apply

# Development
mvn spring-boot:run
```

**Rules**:

- ✅ Use `./gradlew` (gradle wrapper) or Maven
- ✅ Run formatting before commit
- ✅ No direct classes import (use interfaces)
- ✅ Dependency injection via constructor

## Type Safety

### Strongly Typed (No Raw Types)

```java
// ❌ WRONG: Raw types, Object casts
List users = userRepository.findAll();
User user = (User) users.get(0);
Map data = new HashMap();

// ✅ CORRECT: Generics everywhere
List<User> users = userRepository.findAll();
User user = users.get(0);
Map<String, User> data = new HashMap<>();

// ✅ CORRECT: Records for DTOs (Java 14+)
public record SendMessageRequest(
  String conversationId,
  String content
) {}

// ✅ CORRECT: Sealed classes for unions
public sealed class Message permits TextMessage, ImageMessage {}
public record TextMessage(String content) implements Message {}
public record ImageMessage(String url) implements Message {}
```

### Null Safety

```java
// ❌ WRONG: Unchecked nulls
String name = user.getName();
if (name.isEmpty()) { }  // NullPointerException risk

// ✅ CORRECT: Optional
Optional<User> user = userRepository.findById(userId);
String name = user.map(User::getName)
  .orElseThrow(() -> new UserNotFoundException(userId));
```

## Core Patterns

### Use Cases (Services)

```java
@Service
@RequiredArgsConstructor  // Lombok for final fields
public class SendMessageService {
  private final IMessageRepository messageRepository;
  private final IConversationRepository conversationRepository;
  private final ExternalChannelClient channelClient;
  private final EventPublisher eventPublisher;

  @Transactional  // Begin/Commit transaction
  public MessageResponse execute(String companyId, SendMessageRequest dto) {
    // 1. Validate input
    if (dto.content() == null || dto.content().isBlank()) {
      throw new InvalidMessageException("Content cannot be empty");
    }

    // 2. Business rules (context isolation)
    Conversation conversation = conversationRepository
      .findByIdAndCompanyId(dto.conversationId(), companyId)
      .orElseThrow(() -> new ConversationNotFoundException(dto.conversationId()));

    // 3. External service (catch & wrap)
    ExternalMessageResponse response;
    try {
      response = channelClient.send(conversation.getChannelId(), dto);
    } catch (Exception e) {
      throw new ExternalChannelException("Failed to send: " + e.getMessage(), e);
    }

    // 4. Persist
    Message message = Message.create(
      conversation.getId(),
      dto.content(),
      response.messageId()
    );
    message = messageRepository.save(message);

    // 5. Publish event
    eventPublisher.publish(new MessageSentEvent(message));

    // 6. Return (never throw when successful)
    return new MessageResponse(message.getId(), message.getContent());
  }
}
```

### Exceptions (Not HTTP Exceptions)

```java
// Domain exception (language-agnostic error codes)
public class DomainException extends RuntimeException {
  private final String errorCode;
  private final int httpStatus;
  private final Map<String, Object> details;

  public DomainException(
    String errorCode,
    String message,
    int httpStatus,
    Map<String, Object> details
  ) {
    super(message);
    this.errorCode = errorCode;
    this.httpStatus = httpStatus;
    this.details = details;
  }
}

// Specific exception
public class ConversationNotFoundException extends DomainException {
  public ConversationNotFoundException(String conversationId) {
    super(
      "BIZ_ENTITY_NOT_FOUND",
      "Conversation '" + conversationId + "' not found",
      404,
      Map.of("conversationId", conversationId)
    );
  }
}

// Global exception handler
@RestControllerAdvice
public class GlobalExceptionHandler {
  @ExceptionHandler(DomainException.class)
  public ResponseEntity<ErrorResponse> handle(DomainException ex) {
    return ResponseEntity
      .status(ex.getHttpStatus())
      .body(new ErrorResponse(
        ex.getErrorCode(),
        ex.getMessage(),
        ex.getHttpStatus(),
        ex.getDetails()
      ));
  }
}
```

### Controllers (Thin)

```java
@RestController
@RequestMapping("/api/v1/{companyId}/messages")
@RequiredArgsConstructor
public class MessageController {
  private final SendMessageService sendMessageService;

  @PostMapping
  public ResponseEntity<MessageResponse> send(
    @PathVariable String companyId,
    @RequestBody @Valid SendMessageRequest request
  ) {
    // Use case returns or throws (no manual error handling)
    MessageResponse result = sendMessageService.execute(companyId, request);
    return ResponseEntity.status(HttpStatus.CREATED).body(result);
  }
}
```

### Dependency Injection

```java
// ✅ CORRECT: Constructor injection (immutable)
@Service
public class MyService {
  private final IRepository repository;
  private final ExternalClient client;

  public MyService(IRepository repository, ExternalClient client) {
    this.repository = repository;
    this.client = client;
  }
}

// ✅ CORRECT: Lombok shorthand
@Service
@RequiredArgsConstructor
public class MyService {
  private final IRepository repository;
  private final ExternalClient client;
  // Constructor auto-generated
}

// ❌ WRONG: Field injection (mutable, hard to test)
@Service
public class MyService {
  @Autowired
  private IRepository repository;
}
```

## File Structure

```
src/main/java/com/example/
├── config/
│   ├── DatabaseConfig.java
│   ├── SecurityConfig.java
│   └── AppConfig.java
├── infrastructure/
│   ├── persistence/
│   │   ├── repository/{Entity}Repository.java (interface)
│   │   └── repository/{Entity}RepositoryAdapter.java (impl)
│   ├── external/
│   │   └── {Service}Client.java
│   └── mapper/
│       └── {Entity}Mapper.java
├── application/
│   ├── dto/
│   │   └── {Action}{Entity}Request.java
│   ├── service/
│   │   └── {Action}{Entity}Service.java (use case)
│   └── event/
│       └── {Entity}{Action}Event.java
├── domain/
│   ├── entity/
│   │   └── {Entity}.java
│   ├── repository/
│   │   └── I{Entity}Repository.java (interface)
│   ├── exception/
│   │   └── {Entity}NotFound Exception.java
│   └── event/
│       └── I{Entity}EventPublisher.java
└── presentation/
    ├── controller/
    │   └── {Entity}Controller.java
    └── filter/
        └── DomainExceptionFilter.java
```

## Testing

```java
// Unit test (mocked dependencies)
@ExtendWith(MockitoExtension.class)
class SendMessageServiceTest {
  @Mock
  private IMessageRepository messageRepository;

  @InjectMocks
  private SendMessageService service;

  @Test
  void should_throw_exception_if_content_empty() {
    SendMessageRequest request = new SendMessageRequest(null, "");
    assertThrows(InvalidMessageException.class, () ->
      service.execute("company-id", request)
    );
  }

  @Test
  void should_save_and_publish_when_valid() {
    SendMessageRequest request = new SendMessageRequest("conv-1", "hello");
    when(conversationRepository.findByIdAndCompanyId(...))
      .thenReturn(Optional.of(conversation));
    when(messageRepository.save(...)).thenReturn(savedMessage);

    MessageResponse result = service.execute("company-id", request);
    assertEquals("msg-1", result.id());
    verify(messageRepository).save(any());
  }
}

// Integration test
@SpringBootTest
@Sql("/test-data.sql")
class SendMessageIntegrationTest {
  @Autowired
  private TestRestTemplate restTemplate;

  @Test
  void should_send_message_end_to_end() {
    SendMessageRequest request = new SendMessageRequest("conv-1", "test");
    ResponseEntity<MessageResponse> response = restTemplate.postForEntity(
      "/api/v1/company-1/messages",
      request,
      MessageResponse.class
    );
    assertEquals(HttpStatus.CREATED, response.getStatusCode());
  }
}
```

## Quick Checklist

- [ ] Use proper generics (no raw types)
- [ ] Constructor injection (not @Autowired on fields)
- [ ] Exceptions instead of error codes in return
- [ ] @Transactional on service methods
- [ ] Event publish AFTER persistence
- [ ] Validate companyId in service
- [ ] No Object casts
- [ ] External APIs wrapped with types
- [ ] Tests use mocks for units
- [ ] Gradle or Maven builds
