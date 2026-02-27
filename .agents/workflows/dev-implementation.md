---
description: Iterative enterprise implementation focused on delivering single User Stories with continuous quality.
---

Follow this workflow during the execution of a specific User Story or task increment.

### 🧩 Required Skills & Rules
- **Primary Skill**: Language-specific (e.g., `nestjs`, `java`)
- **Secondary Skills**: `architecture`, `development`, `database`, `general-patterns`
- **Optional Skill**: `ui-ux-pro-max` (if the story involves UI changes)
- **Global Rules**: `@general.instructions.md` (Language-Specific Rules section)

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
- [ ] **Update Technical Docs**: Update relevant technical documentation (API spec, Schema, Architecture) in the `docs/` folder.
- [ ] **Strict Verification**: Run only the tests relevant to this story and ensure 100% pass rate.
- [ ] **DoD Check**: Verify that all Acceptance Criteria and documentation requirements are met.

### 4. Incremental Feedback
- [ ] **Prompt Review**: Checkpoint with the user after completing a single story or major logic block to ensure alignment before moving to the next increment.
