---
description: Iterative enterprise implementation focused on delivering single User Stories with continuous quality.
---

Follow this workflow during the execution of a specific User Story or task increment.

### 1. Story Scaffolding
- [ ] **Typed Contracts**: Implement DTOs and Interfaces specific to the story. No `any`.
- [ ] **Incremental Domain**: Update entities with only the domain logic required for this increment.

### 2. Iterative Development Cycle
- [ ] **Start Task**: Mark the current story/task as in-progress (`[/]`) in `task.md`.
- [ ] **Red-Green-Refactor**: Write unit tests for the story's acceptance criteria first, then implement the logic.
- [ ] **Repo Sync**: Ensure changes match the architecture and rules of the specific target repository.
- [ ] **Small Commits**: Commit or checkpoint frequently.
- [ ] **Complete Task**: Mark the task as done (`[x]`) in `task.md` before moving to the next.

### 3. Continuous Integration & Definition of Done (DoD)
- [ ] **Clean Refactoring**: Polish the code within the current scope; ensure it adheres to all architectural rules.
- [ ] **Strict Verification**: Run only the tests relevant to this story and ensure 100% pass rate.
- [ ] **DoD Check**: Verify that all Acceptance Criteria defined in the BA phase are met.

### 4. Incremental Feedback
- [ ] **Prompt Review**: Checkpoint with the user after completing a single story or major logic block to ensure alignment before moving to the next increment.
