---
description: Technical requirement discovery, decomposition, and planning focused on iterative Agile delivery.
---

Follow this workflow to break down complex features into deliverable increments (MVP) and ensure a clear understanding of value.

### 1. User Story Mapping
- [ ] **Define Epic/Feature**: Briefly describe the high-level business goal.
- [ ] **Technical Story Decomposition**: Break the epic into small, independent User Stories (Invest: Independent, Negotiable, Valuable, Estimable, Small, Testable).
- [ ] **Identify MVP**: Select the absolute minimum set of stories required to deliver initial value.

### 2. Requirement Specification (per Story)
- [ ] **Acceptance Criteria (AC)**: Define clear, testable success criteria for each story. Use Gherkin (Given/When/Then) for complex logic.
- [ ] **Data & Schema Impact**: Document only the specific schema changes needed for the *current* iteration.
- [ ] **Interface Definitions**: Define specific API endpoints or internal interfaces required for the story.

### 3. Incremental Failure & Security Analysis
- [ ] **Story-Specific Risks**: Identify security or stability risks introduced by these specific changes.
- [ ] **Error Path Definition**: Define how the system should handle failures within the scope of the story.

### 4. Sprint Implementation Planning
- [ ] **Technical Breakdown**: List the files and layers (Presentation, Application, Domain, Infrastructure) affected.
- [ ] **Dependencies**: Identify if this story blocks or is blocked by other tasks.
- [ ] **Iterative Review**: Present the plan for the specific iteration/story to the user for quick sign-off.
