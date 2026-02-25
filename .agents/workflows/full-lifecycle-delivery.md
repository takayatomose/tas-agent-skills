---
description: End-to-end professional delivery lifecycle orchestrating BA, Dev, and QA phases.
---

Follow this master workflow for any new feature or project to ensure enterprise-grade quality and Agile compliance.

### Phase 1: Planning & Analysis (Business Analysis)
*Objective: Discover context, map user stories, and define repositories.*
- [ ] **Task Visibility**: Create a `task.md` file in the `@brain/` directory. This is the **source of truth** for tracking progress.
- [ ] **Repository Context**: Explicitly identify whether tasks belong to the Backend (e.g., `omi-channel-be`), Frontend (e.g., `findtourgoUI`), or both.
- [ ] **Execution**: Follow the [@ba-requirement-analysis.md] workflow.
- [ ] **Checkpoint**: Success is defined by an approved implementation plan and a populated `task.md` checklist.

### Phase 2: Iterative Implementation (Development)
*Objective: Deliver the feature increment through TDD and clean architecture.*
- [ ] **Execution**: Follow the [@dev-implementation.md] workflow for each story/increment.
- [ ] **Checkpoint**: Success is defined by code that meets all Architectural and Business Logic rules.

### Phase 3: Quality Assurance (Testing)
*Objective: Systematically verify functional and non-functional requirements.*
- [ ] **Execution**: Follow the [@qa-testing.md] workflow.
- [ ] **Checkpoint**: Success is defined by 100% green tests and a comprehensive walkthrough.

### Phase 4: Lifecycle Closure & Review
*Objective: Collect evidence, refine the system, and close the sprint.*
- [ ] **Documentation**: Finalize the `walkthrough.md` with all recordings and visual evidence.
- [ ] **Refinement**: Review any "technical debt" identified during the cycle and plan for future iterations.
- [ ] **Sign-off**: Present the final result to the user for project closure.